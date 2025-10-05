# AirScope - NASA Space Apps Challenge

A comprehensive air quality prediction system that combines ground sensor data and satellite data to provide 7-day SO2 predictions using machine learning.

## 🌟 Features

- **Dual Data Sources**: Ground sensor data and NASA satellite data integration
- **7-Day Predictions**: Predicts next 7 days of SO2 levels using last 7 days of data
- **Interactive Dashboard**: Beautiful React frontend with real-time visualizations
- **Machine Learning Models**: Multiple ML algorithms with automatic best model selection
- **Real-time API**: Django REST API for seamless frontend-backend communication
- **NASA Theme**: Space-inspired UI with falling star animations

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- Node.js 14+
- npm or yarn

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd air-quality-app
   ```

2. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Install Node.js dependencies**
   ```bash
   cd air-quality-frontend
   npm install
   ```

4. **Set up the database**
   ```bash
   cd air_quality_backend
   python manage.py makemigrations
   python manage.py migrate
   ```

5. **Process data and train models**
   ```bash
   python data_processing.py
   ```

6. **Start the servers**
   
   Backend (Terminal 1):
   ```bash
   cd air_quality_backend
   python manage.py runserver
   ```
   
   Frontend (Terminal 2):
   ```bash
   cd air-quality-frontend
   npm start
   ```

7. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000/api/

## 📊 Data Processing

### Ground Sensor Data
- Processes CSV files with air quality measurements
- Extracts last 1 year of data for training
- Creates statistical features (mean, std, min, max, median)
- Implements cyclical encoding for time features

### Satellite Data
- Processes NASA HDF5 files (OMPS_NPP_NMSO2_PCA_L2)
- Extracts SO2, latitude, longitude, and timestamps
- Handles missing values and outliers
- Creates similar feature engineering as ground data

### Model Training
- **Algorithms**: Random Forest, Gradient Boosting, Linear Regression
- **Automatic Selection**: Chooses best performing model based on R² score
- **7-Day Prediction**: Uses last 7 days to predict next 7 days average
- **Feature Engineering**: 16 features including statistical and cyclical time features

## 🎯 API Endpoints

### Predictions
- `GET /api/predictions/` - Get predictions for both data sources
- `POST /api/predict-custom/` - Make prediction with custom parameters
- `GET /api/data-points/` - Get recent data points for visualization
- `GET /api/model-info/` - Get information about available models

### Example API Usage

```python
import requests

# Get predictions
response = requests.get('http://localhost:8000/api/predictions/')
predictions = response.json()

# Custom prediction
data = {
    'so2_mean': 8.9,
    'so2_std': 2.1,
    'so2_min': 5.2,
    'so2_max': 12.8,
    'so2_median': 8.5,
    'year': 2024,
    'month': 1,
    'day': 15,
    'day_of_week': 1,
    'hour': 12
}
response = requests.post('http://localhost:8000/api/predict-custom/', json=data)
```

## 🎨 Frontend Features

### Pages
- **Home**: Landing page with key features and statistics
- **Explore**: Interactive prediction interface with sample data
- **About**: Project details and team information
- **Flowchart**: Technical architecture and model performance
- **Contact**: Contact information and project details

### Components
- **StarsBackground**: Animated falling stars for NASA theme
- **Interactive Charts**: Bar charts and pie charts for data visualization
- **Responsive Design**: Mobile-friendly interface
- **Loading Animations**: Smooth user experience

## 🔧 Technical Architecture

### Backend (Django)
- **Models**: DataPoint, PredictionResult
- **Views**: REST API endpoints with error handling
- **Serializers**: JSON data transformation
- **CORS**: Cross-origin resource sharing enabled

### Frontend (React + TypeScript)
- **Components**: Modular, reusable React components
- **State Management**: React hooks for local state
- **Styling**: CSS3 with animations and responsive design
- **Charts**: Recharts library for data visualization

### Machine Learning Pipeline
1. **Data Preprocessing**: Cleaning, normalization, feature engineering
2. **Model Training**: Multiple algorithms with cross-validation
3. **Model Selection**: Best performing model based on metrics
4. **Prediction**: Real-time predictions via API
5. **Model Persistence**: Saved models for production use

## 📈 Model Performance

The system automatically selects the best performing model based on R² score:

- **Linear Regression**: Often performs best for time series data
- **Random Forest**: Good for non-linear relationships
- **Gradient Boosting**: Handles complex patterns

## 🌍 Data Sources

### Ground Sensor Data
- Format: CSV files
- Frequency: Daily measurements
- Features: SO2, CO, NO2, O3, PM2.5, PM10, NH3
- Processing: Last 1 year extraction, statistical feature creation

### Satellite Data
- Format: HDF5 files (NASA OMPS)
- Frequency: Daily satellite passes
- Features: SO2, latitude, longitude, timestamps
- Processing: Outlier removal, coordinate extraction

## 🚀 Deployment

### Production Setup
1. Configure production database (PostgreSQL recommended)
2. Set up environment variables for security
3. Use production WSGI server (Gunicorn)
4. Configure reverse proxy (Nginx)
5. Set up SSL certificates

### Environment Variables
```bash
SECRET_KEY=your-secret-key
DEBUG=False
ALLOWED_HOSTS=your-domain.com
DATABASE_URL=postgresql://user:password@host:port/dbname
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is part of the NASA Space Apps Challenge and follows open-source principles.

## 👥 Team

- **Naisargi Patel** (Team Leader)
- **Divy Pattani**
- **Uday Chauhan**
- **Pragati Prajapati**
- **Jigar Paun**

## 🔮 Future Enhancements

- Real-time data streaming
- Additional air quality parameters
- Mobile application
- Advanced visualization features
- Integration with more satellite data sources
- Weather data integration
- Alert system for high pollution levels

## 📞 Support

For questions or support, please contact the development team or create an issue in the repository.

---

**Built with ❤️ for NASA Space Apps Challenge**