"""
Data Processing and Feature Engineering for Air Quality Prediction
NASA Space Apps Challenge - Air Quality Prediction Project
"""

import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
import seaborn as sns
import warnings

warnings.filterwarnings("ignore")


class AirQualityProcessor:
    def __init__(self, csv_path):
        """Initialize the processor with CSV data path"""
        self.csv_path = csv_path
        self.df = None
        self.scaler = StandardScaler()
        self.label_encoder = LabelEncoder()

    def load_data(self):
        """Load and explore the dataset"""
        print("Loading dataset...")
        self.df = pd.read_csv(self.csv_path)
        print(f"Dataset shape: {self.df.shape}")
        print(f"Columns: {self.df.columns.tolist()}")
        print(f"Missing values:\n{self.df.isnull().sum()}")
        return self.df

    def create_aqi_labels(self):
        """
        Create air quality classification labels based on AQI standards
        Using PM2.5 as primary indicator for AQI calculation
        """
        print("Creating AQI classification labels...")

        def calculate_aqi_pm25(pm25):
            """Calculate AQI based on PM2.5 values"""
            if pm25 <= 25:
                return 0  # Good
            elif pm25 <= 50:
                return 1  # Normal
            elif pm25 <= 100:
                return 2  # Bad
            else:
                return 3  # Very Bad

        def calculate_aqi_pm10(pm10):
            """Calculate AQI based on PM10 values"""
            if pm10 <= 50:
                return 0  # Good
            elif pm10 <= 100:
                return 1  # Normal
            elif pm10 <= 200:
                return 2  # Bad
            else:
                return 3  # Very Bad

        # Calculate AQI for both PM2.5 and PM10, take the maximum
        aqi_pm25 = self.df["pm2_5"].apply(calculate_aqi_pm25)
        aqi_pm10 = self.df["pm10"].apply(calculate_aqi_pm10)

        # Take the maximum AQI value (worst air quality)
        self.df["aqi_class"] = np.maximum(aqi_pm25, aqi_pm10)

        # Create readable labels
        aqi_labels = {0: "Good", 1: "Normal", 2: "Bad", 3: "Very Bad"}
        self.df["aqi_label"] = self.df["aqi_class"].map(aqi_labels)

        print("AQI Classification Distribution:")
        print(self.df["aqi_label"].value_counts())
        print(f"\nAQI Class Distribution:")
        print(self.df["aqi_class"].value_counts().sort_index())

        return self.df

    def feature_engineering(self):
        """Create additional features for better prediction"""
        print("Creating additional features...")

        # Convert date to datetime
        self.df["date"] = pd.to_datetime(self.df["date"])

        # Extract time-based features
        self.df["hour"] = self.df["date"].dt.hour
        self.df["day_of_week"] = self.df["date"].dt.dayofweek
        self.df["month"] = self.df["date"].dt.month
        self.df["day_of_year"] = self.df["date"].dt.dayofyear

        # Create cyclical features for time
        self.df["hour_sin"] = np.sin(2 * np.pi * self.df["hour"] / 24)
        self.df["hour_cos"] = np.cos(2 * np.pi * self.df["hour"] / 24)
        self.df["day_sin"] = np.sin(2 * np.pi * self.df["day_of_week"] / 7)
        self.df["day_cos"] = np.cos(2 * np.pi * self.df["day_of_week"] / 7)
        self.df["month_sin"] = np.sin(2 * np.pi * self.df["month"] / 12)
        self.df["month_cos"] = np.cos(2 * np.pi * self.df["month"] / 12)

        # Create pollutant ratios
        self.df["pm_ratio"] = self.df["pm2_5"] / (
            self.df["pm10"] + 1e-8
        )  # Avoid division by zero
        self.df["nox_ratio"] = self.df["no2"] / (self.df["no"] + 1e-8)

        # Create rolling averages (if we had more data, we'd use this)
        # For now, we'll create some statistical features
        self.df["co_log"] = np.log1p(self.df["co"])
        self.df["pm2_5_log"] = np.log1p(self.df["pm2_5"])
        self.df["pm10_log"] = np.log1p(self.df["pm10"])

        print("Additional features created successfully!")
        return self.df

    def prepare_features(self):
        """Prepare features for machine learning"""
        print("Preparing features for ML...")

        # Select features for training
        feature_columns = [
            "co",
            "no",
            "no2",
            "o3",
            "so2",
            "pm2_5",
            "pm10",
            "nh3",
            "hour",
            "day_of_week",
            "month",
            "day_of_year",
            "hour_sin",
            "hour_cos",
            "day_sin",
            "day_cos",
            "month_sin",
            "month_cos",
            "pm_ratio",
            "nox_ratio",
            "co_log",
            "pm2_5_log",
            "pm10_log",
        ]

        self.X = self.df[feature_columns]
        self.y = self.df["aqi_class"]

        print(f"Feature matrix shape: {self.X.shape}")
        print(f"Target vector shape: {self.y.shape}")
        print(f"Features: {feature_columns}")

        return self.X, self.y

    def split_and_scale_data(self, test_size=0.2, random_state=42):
        """Split data into train/test sets and scale features"""
        print("Splitting and scaling data...")

        # Split the data
        self.X_train, self.X_test, self.y_train, self.y_test = train_test_split(
            self.X,
            self.y,
            test_size=test_size,
            random_state=random_state,
            stratify=self.y,
        )

        # Scale the features
        self.X_train_scaled = self.scaler.fit_transform(self.X_train)
        self.X_test_scaled = self.scaler.transform(self.X_test)

        print(f"Training set shape: {self.X_train_scaled.shape}")
        print(f"Test set shape: {self.X_test_scaled.shape}")

        return (
            self.X_train_scaled,
            self.X_test_scaled,
            self.y_train,
            self.y_test,
            self.scaler,
        )

    def visualize_data(self):
        """Create visualizations for data exploration"""
        print("Creating data visualizations...")

        # Set up the plotting style
        plt.style.use("dark_background")
        fig, axes = plt.subplots(2, 2, figsize=(15, 12))
        fig.suptitle("Air Quality Data Analysis", fontsize=16, color="white")

        # AQI Distribution
        axes[0, 0].pie(
            self.df["aqi_label"].value_counts().values,
            labels=self.df["aqi_label"].value_counts().index,
            autopct="%1.1f%%",
            colors=["green", "yellow", "orange", "red"],
        )
        axes[0, 0].set_title("AQI Classification Distribution", color="white")

        # PM2.5 vs PM10 scatter plot
        scatter = axes[0, 1].scatter(
            self.df["pm2_5"],
            self.df["pm10"],
            c=self.df["aqi_class"],
            cmap="RdYlGn_r",
            alpha=0.6,
        )
        axes[0, 1].set_xlabel("PM2.5 (μg/m³)", color="white")
        axes[0, 1].set_ylabel("PM10 (μg/m³)", color="white")
        axes[0, 1].set_title("PM2.5 vs PM10 by AQI Class", color="white")
        axes[0, 1].tick_params(colors="white")
        plt.colorbar(scatter, ax=axes[0, 1])

        # Hourly distribution
        hourly_aqi = self.df.groupby("hour")["aqi_class"].mean()
        axes[1, 0].plot(hourly_aqi.index, hourly_aqi.values, marker="o", color="cyan")
        axes[1, 0].set_xlabel("Hour of Day", color="white")
        axes[1, 0].set_ylabel("Average AQI Class", color="white")
        axes[1, 0].set_title("Average AQI by Hour", color="white")
        axes[1, 0].tick_params(colors="white")
        axes[1, 0].grid(True, alpha=0.3)

        # Monthly distribution
        monthly_aqi = self.df.groupby("month")["aqi_class"].mean()
        axes[1, 1].bar(monthly_aqi.index, monthly_aqi.values, color="lightblue")
        axes[1, 1].set_xlabel("Month", color="white")
        axes[1, 1].set_ylabel("Average AQI Class", color="white")
        axes[1, 1].set_title("Average AQI by Month", color="white")
        axes[1, 1].tick_params(colors="white")

        plt.tight_layout()
        plt.savefig(
            "data_analysis.png",
            dpi=300,
            bbox_inches="tight",
            facecolor="black",
            edgecolor="none",
        )
        plt.show()

        print("Visualizations saved as 'data_analysis.png'")

    def get_processed_data(self):
        """Get all processed data for model training"""
        return {
            "X_train": self.X_train_scaled,
            "X_test": self.X_test_scaled,
            "y_train": self.y_train,
            "y_test": self.y_test,
            "scaler": self.scaler,
            "feature_names": self.X.columns.tolist(),
            "aqi_labels": {0: "Good", 1: "Normal", 2: "Bad", 3: "Very Bad"},
        }


def main():
    """Main function to process the data"""
    # Initialize processor
    processor = AirQualityProcessor("delhi_aqi.csv")

    # Load and process data
    processor.load_data()
    processor.create_aqi_labels()
    processor.feature_engineering()
    processor.prepare_features()
    processor.split_and_scale_data()
    processor.visualize_data()

    # Get processed data
    processed_data = processor.get_processed_data()

    print("\nData processing completed successfully!")
    print(f"Training samples: {processed_data['X_train'].shape[0]}")
    print(f"Test samples: {processed_data['X_test'].shape[0]}")
    print(f"Number of features: {processed_data['X_train'].shape[1]}")

    return processed_data


if __name__ == "__main__":
    processed_data = main()
