import pandas as pd
import numpy as np
import h5py
import os
from datetime import datetime, timedelta
import joblib
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import warnings
warnings.filterwarnings('ignore')

class AirQualityDataProcessor:
    def __init__(self):
        self.ground_data = None
        self.satellite_data = None
        self.ground_model = None
        self.satellite_model = None
        self.ground_scaler = StandardScaler()
        self.satellite_scaler = StandardScaler()
        
    def process_ground_data(self, csv_file_path):
        """Process ground sensor data - extract last 1 year and clean"""
        print("Processing ground sensor data...")
        
        # Read the CSV file
        df = pd.read_csv(csv_file_path)
        
        # Convert date column to datetime
        if 'date' in df.columns:
            df['date'] = pd.to_datetime(df['date'])
        elif 'Date' in df.columns:
            df['date'] = pd.to_datetime(df['Date'])
        else:
            # Try to find date column
            date_cols = [col for col in df.columns if 'date' in col.lower() or 'time' in col.lower()]
            if date_cols:
                df['date'] = pd.to_datetime(df[date_cols[0]])
            else:
                raise ValueError("No date column found in the dataset")
        
        # Sort by date
        df = df.sort_values('date')
        
        # Get the last 1 year of data
        latest_date = df['date'].max()
        one_year_ago = latest_date - timedelta(days=365)
        df = df[df['date'] >= one_year_ago].copy()
        
        print(f"Ground data shape after filtering: {df.shape}")
        print(f"Date range: {df['date'].min()} to {df['date'].max()}")
        
        # Clean the data
        # Remove rows with all NaN values
        df = df.dropna(how='all')
        
        # Handle missing values in numeric columns
        numeric_columns = df.select_dtypes(include=[np.number]).columns
        for col in numeric_columns:
            if col != 'date':
                # Fill missing values with median
                df[col] = df[col].fillna(df[col].median())
        
        # Create additional features
        df['year'] = df['date'].dt.year
        df['month'] = df['date'].dt.month
        df['day'] = df['date'].dt.day
        df['day_of_week'] = df['date'].dt.dayofweek
        df['hour'] = df['date'].dt.hour
        
        # Cyclical encoding for time features
        df['month_sin'] = np.sin(2 * np.pi * df['month'] / 12)
        df['month_cos'] = np.cos(2 * np.pi * df['month'] / 12)
        df['day_sin'] = np.sin(2 * np.pi * df['day'] / 31)
        df['day_cos'] = np.cos(2 * np.pi * df['day'] / 31)
        df['hour_sin'] = np.sin(2 * np.pi * df['hour'] / 24)
        df['hour_cos'] = np.cos(2 * np.pi * df['hour'] / 24)
        
        self.ground_data = df
        print("Ground data processing completed!")
        return df
    
    def process_satellite_data(self, h5_directory):
        """Process NASA satellite data - extract SO2, lat, lon, timestamps"""
        print("Processing satellite data...")
        
        satellite_data = []
        
        # Process all HDF5 files in the directory
        for filename in os.listdir(h5_directory):
            if filename.endswith('.h5'):
                file_path = os.path.join(h5_directory, filename)
                try:
                    with h5py.File(file_path, 'r') as f:
                        # Extract SO2 data and coordinates
                        if 'SO2' in f or 'so2' in f:
                            so2_key = 'SO2' if 'SO2' in f else 'so2'
                            so2_data = f[so2_key][:]
                            
                            # Extract latitude and longitude
                            lat_data = f['Latitude'][:] if 'Latitude' in f else f['lat'][:]
                            lon_data = f['Longitude'][:] if 'Longitude' in f else f['lon'][:]
                            
                            # Extract timestamps
                            time_data = f['Time'][:] if 'Time' in f else f['time'][:]
                            
                            # Create DataFrame for this file
                            file_data = pd.DataFrame({
                                'so2': so2_data.flatten(),
                                'latitude': lat_data.flatten(),
                                'longitude': lon_data.flatten(),
                                'timestamp': time_data.flatten()
                            })
                            
                            # Convert timestamp to datetime
                            file_data['date'] = pd.to_datetime(file_data['timestamp'], unit='s')
                            
                            satellite_data.append(file_data)
                            
                except Exception as e:
                    print(f"Error processing {filename}: {str(e)}")
                    continue
        
        if satellite_data:
            # Combine all satellite data
            df = pd.concat(satellite_data, ignore_index=True)
            
            # Clean the data
            df = df.dropna()
            
            # Remove outliers (SO2 values > 3 standard deviations from mean)
            so2_mean = df['so2'].mean()
            so2_std = df['so2'].std()
            df = df[abs(df['so2'] - so2_mean) <= 3 * so2_std]
            
            # Create additional features
            df['year'] = df['date'].dt.year
            df['month'] = df['date'].dt.month
            df['day'] = df['date'].dt.day
            df['day_of_week'] = df['date'].dt.dayofweek
            df['hour'] = df['date'].dt.hour
            
            # Cyclical encoding
            df['month_sin'] = np.sin(2 * np.pi * df['month'] / 12)
            df['month_cos'] = np.cos(2 * np.pi * df['month'] / 12)
            df['day_sin'] = np.sin(2 * np.pi * df['day'] / 31)
            df['day_cos'] = np.cos(2 * np.pi * df['day'] / 31)
            df['hour_sin'] = np.sin(2 * np.pi * df['hour'] / 24)
            df['hour_cos'] = np.cos(2 * np.pi * df['hour'] / 24)
            
            self.satellite_data = df
            print(f"Satellite data shape: {df.shape}")
            print(f"Date range: {df['date'].min()} to {df['date'].max()}")
            print("Satellite data processing completed!")
        else:
            print("No satellite data found!")
            
        return self.satellite_data
    
    def prepare_7day_prediction_data(self, data, target_column='so2'):
        """Prepare data for 7-day prediction using last 7 days to predict next 7 days"""
        print(f"Preparing 7-day prediction data for {target_column}...")
        
        # Sort by date
        data = data.sort_values('date')
        
        # Create features for 7-day prediction
        features = []
        targets = []
        
        # Use last 7 days to predict next 7 days
        window_size = 7
        prediction_days = 7
        
        for i in range(window_size, len(data) - prediction_days + 1):
            # Features: last 7 days of data
            window_data = data.iloc[i-window_size:i]
            
            # Create features from the window
            feature_vector = []
            
            # Statistical features from the window
            feature_vector.extend([
                window_data[target_column].mean(),
                window_data[target_column].std(),
                window_data[target_column].min(),
                window_data[target_column].max(),
                window_data[target_column].median()
            ])
            
            # Time features from the last day in window
            last_day = window_data.iloc[-1]
            feature_vector.extend([
                last_day['year'],
                last_day['month'],
                last_day['day'],
                last_day['day_of_week'],
                last_day['hour'],
                last_day['month_sin'],
                last_day['month_cos'],
                last_day['day_sin'],
                last_day['day_cos'],
                last_day['hour_sin'],
                last_day['hour_cos']
            ])
            
            # Target: next 7 days average
            next_7_days = data.iloc[i:i+prediction_days]
            target_value = next_7_days[target_column].mean()
            
            features.append(feature_vector)
            targets.append(target_value)
        
        return np.array(features), np.array(targets)
    
    def train_models(self):
        """Train models for both ground and satellite data"""
        print("Training models...")
        
        # Train ground data model
        if self.ground_data is not None:
            print("Training ground data model...")
            X_ground, y_ground = self.prepare_7day_prediction_data(self.ground_data, 'so2')
            
            if len(X_ground) > 0:
                # Scale features
                X_ground_scaled = self.ground_scaler.fit_transform(X_ground)
                
                # Split data
                X_train, X_test, y_train, y_test = train_test_split(
                    X_ground_scaled, y_ground, test_size=0.2, random_state=42
                )
                
                # Train multiple models and select the best
                models = {
                    'RandomForest': RandomForestRegressor(n_estimators=100, random_state=42),
                    'GradientBoosting': GradientBoostingRegressor(n_estimators=100, random_state=42),
                    'LinearRegression': LinearRegression()
                }
                
                best_model = None
                best_score = -np.inf
                best_name = ""
                
                for name, model in models.items():
                    model.fit(X_train, y_train)
                    y_pred = model.predict(X_test)
                    r2 = r2_score(y_test, y_pred)
                    
                    print(f"{name} - R² Score: {r2:.4f}")
                    
                    if r2 > best_score:
                        best_score = r2
                        best_model = model
                        best_name = name
                
                self.ground_model = best_model
                print(f"Best ground model: {best_name} with R² = {best_score:.4f}")
                
                # Save the model and scaler
                joblib.dump(self.ground_model, 'ground_model.pkl')
                joblib.dump(self.ground_scaler, 'ground_scaler.pkl')
        
        # Train satellite data model
        if self.satellite_data is not None:
            print("Training satellite data model...")
            X_satellite, y_satellite = self.prepare_7day_prediction_data(self.satellite_data, 'so2')
            
            if len(X_satellite) > 0:
                # Scale features
                X_satellite_scaled = self.satellite_scaler.fit_transform(X_satellite)
                
                # Split data
                X_train, X_test, y_train, y_test = train_test_split(
                    X_satellite_scaled, y_satellite, test_size=0.2, random_state=42
                )
                
                # Train multiple models and select the best
                models = {
                    'RandomForest': RandomForestRegressor(n_estimators=100, random_state=42),
                    'GradientBoosting': GradientBoostingRegressor(n_estimators=100, random_state=42),
                    'LinearRegression': LinearRegression()
                }
                
                best_model = None
                best_score = -np.inf
                best_name = ""
                
                for name, model in models.items():
                    model.fit(X_train, y_train)
                    y_pred = model.predict(X_test)
                    r2 = r2_score(y_test, y_pred)
                    
                    print(f"{name} - R² Score: {r2:.4f}")
                    
                    if r2 > best_score:
                        best_score = r2
                        best_model = model
                        best_name = name
                
                self.satellite_model = best_model
                print(f"Best satellite model: {best_name} with R² = {best_score:.4f}")
                
                # Save the model and scaler
                joblib.dump(self.satellite_model, 'satellite_model.pkl')
                joblib.dump(self.satellite_scaler, 'satellite_scaler.pkl')
    
    def predict_next_7_days(self, data_type='ground'):
        """Predict next 7 days using the last 7 days of data"""
        if data_type == 'ground' and self.ground_data is not None:
            data = self.ground_data
            model = self.ground_model
            scaler = self.ground_scaler
        elif data_type == 'satellite' and self.satellite_data is not None:
            data = self.satellite_data
            model = self.satellite_model
            scaler = self.satellite_scaler
        else:
            return None
        
        # Get the last 7 days of data
        last_7_days = data.tail(7)
        
        # Create feature vector
        feature_vector = []
        
        # Statistical features from the last 7 days
        feature_vector.extend([
            last_7_days['so2'].mean(),
            last_7_days['so2'].std(),
            last_7_days['so2'].min(),
            last_7_days['so2'].max(),
            last_7_days['so2'].median()
        ])
        
        # Time features from the last day
        last_day = last_7_days.iloc[-1]
        feature_vector.extend([
            last_day['year'],
            last_day['month'],
            last_day['day'],
            last_day['day_of_week'],
            last_day['hour'],
            last_day['month_sin'],
            last_day['month_cos'],
            last_day['day_sin'],
            last_day['day_cos'],
            last_day['hour_sin'],
            last_day['hour_cos']
        ])
        
        # Scale features and predict
        feature_vector = np.array(feature_vector).reshape(1, -1)
        feature_vector_scaled = scaler.transform(feature_vector)
        prediction = model.predict(feature_vector_scaled)[0]
        
        return prediction

def main():
    processor = AirQualityDataProcessor()
    
    # Process ground data (assuming you have a CSV file)
    # You'll need to provide the path to your ground sensor CSV file
    ground_csv_path = "ground_sensor_data.csv"  # Update this path
    
    if os.path.exists(ground_csv_path):
        processor.process_ground_data(ground_csv_path)
    else:
        print("Ground sensor data file not found. Please provide the correct path.")
    
    # Process satellite data
    satellite_data_path = "data/NASAdata"  # Update this path
    
    if os.path.exists(satellite_data_path):
        processor.process_satellite_data(satellite_data_path)
    else:
        print("Satellite data directory not found. Please provide the correct path.")
    
    # Train models
    processor.train_models()
    
    # Make predictions
    if processor.ground_model is not None:
        ground_prediction = processor.predict_next_7_days('ground')
        print(f"Ground data prediction for next 7 days: {ground_prediction:.4f}")
    
    if processor.satellite_model is not None:
        satellite_prediction = processor.predict_next_7_days('satellite')
        print(f"Satellite data prediction for next 7 days: {satellite_prediction:.4f}")

if __name__ == "__main__":
    main()
