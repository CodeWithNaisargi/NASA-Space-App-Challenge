import React, { useState, useEffect } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';
import StarsBackground from '../components/StarsBackground';
import './Explore.css';

interface PredictionResult {
  ground?: {
    prediction: number;
    confidence: number;
    model_name: string;
    data_type: string;
  };
  satellite?: {
    prediction: number;
    confidence: number;
    model_name: string;
    data_type: string;
  };
}

const Explore: React.FC = () => {
  // Sample data for automatic predictions
  const sampleData = {
    so2_mean: '8.9',
    so2_std: '2.1',
    so2_min: '5.2',
    so2_max: '12.8',
    so2_median: '8.5',
    year: new Date().getFullYear().toString(),
    month: (new Date().getMonth() + 1).toString(),
    day: new Date().getDate().toString(),
    day_of_week: new Date().getDay().toString(),
    hour: new Date().getHours().toString()
  };

  const [formData, setFormData] = useState(sampleData);
  const [prediction, setPrediction] = useState<PredictionResult | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showLoading, setShowLoading] = useState(false);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setShowLoading(true);
    
    // Start the actual prediction
    makePrediction();
  };

  const makePrediction = async () => {
    setLoading(true);

    try {
      const response = await fetch('http://localhost:8000/api/predict-custom/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          so2_mean: parseFloat(formData.so2_mean),
          so2_std: parseFloat(formData.so2_std),
          so2_min: parseFloat(formData.so2_min),
          so2_max: parseFloat(formData.so2_max),
          so2_median: parseFloat(formData.so2_median),
          year: parseInt(formData.year),
          month: parseInt(formData.month),
          day: parseInt(formData.day),
          day_of_week: parseInt(formData.day_of_week),
          hour: parseInt(formData.hour)
        }),
      });

      if (!response.ok) {
        throw new Error('Failed to get prediction');
      }

      const result = await response.json();
      setPrediction(result);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
      setShowLoading(false);
    }
  };

  const getAQIClass = (value: number) => {
    if (value < 10) return 'aqi-good';
    if (value < 20) return 'aqi-normal';
    if (value < 30) return 'aqi-bad';
    return 'aqi-very-bad';
  };

  const prepareChartData = () => {
    if (!prediction) return [];
    
    const data = [];
    if (prediction.ground) {
      data.push({
        name: 'Ground Sensor',
        value: prediction.ground.prediction,
        color: '#00d4ff'
      });
    }
    if (prediction.satellite) {
      data.push({
        name: 'Satellite',
        value: prediction.satellite.prediction,
        color: '#00ff88'
      });
    }
    return data;
  };

  const COLORS = ['#00ff00', '#ffff00', '#ff8800', '#ff0000'];

  return (
    <div className="page explore-page">
      <StarsBackground />
      
      {/* Loading Overlay */}
      {showLoading && (
        <div className="countdown-overlay">
          <div className="countdown-container">
            <div className="loading-circle">
              <div className="loading-text">Loading...</div>
            </div>
          </div>
        </div>
      )}

      <h1 className="page-title">Air Quality Prediction</h1>
      <p className="page-subtitle">
        Explore AI-powered air quality predictions with sample data or customize your own parameters
      </p>

      <div className={`explore-container ${prediction ? 'has-results' : ''}`}>
        <div className="prediction-form-container">
          <div className="card">
            <h2>Input Parameters</h2>
            <form onSubmit={handleSubmit} className="prediction-form">
              <div className="form-row">
                <div className="form-group">
                  <label className="form-label">SO2 Mean</label>
                  <input
                    type="number"
                    name="so2_mean"
                    value={formData.so2_mean}
                    onChange={handleInputChange}
                    className="form-input"
                    placeholder="Enter SO2 mean value"
                    step="0.01"
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">SO2 Standard Deviation</label>
                  <input
                    type="number"
                    name="so2_std"
                    value={formData.so2_std}
                    onChange={handleInputChange}
                    className="form-input"
                    placeholder="Enter SO2 std value"
                    step="0.01"
                    required
                  />
                </div>
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label className="form-label">SO2 Minimum</label>
                  <input
                    type="number"
                    name="so2_min"
                    value={formData.so2_min}
                    onChange={handleInputChange}
                    className="form-input"
                    placeholder="Enter SO2 min value"
                    step="0.01"
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">SO2 Maximum</label>
                  <input
                    type="number"
                    name="so2_max"
                    value={formData.so2_max}
                    onChange={handleInputChange}
                    className="form-input"
                    placeholder="Enter SO2 max value"
                    step="0.01"
                    required
                  />
                </div>
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label className="form-label">SO2 Median</label>
                  <input
                    type="number"
                    name="so2_median"
                    value={formData.so2_median}
                    onChange={handleInputChange}
                    className="form-input"
                    placeholder="Enter SO2 median value"
                    step="0.01"
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Year</label>
                  <input
                    type="number"
                    name="year"
                    value={formData.year}
                    onChange={handleInputChange}
                    className="form-input"
                    min="2020"
                    max="2030"
                    required
                  />
                </div>
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label className="form-label">Month (1-12)</label>
                  <input
                    type="number"
                    name="month"
                    value={formData.month}
                    onChange={handleInputChange}
                    className="form-input"
                    min="1"
                    max="12"
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Day (1-31)</label>
                  <input
                    type="number"
                    name="day"
                    value={formData.day}
                    onChange={handleInputChange}
                    className="form-input"
                    min="1"
                    max="31"
                    required
                  />
                </div>
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label className="form-label">Day of Week (0-6)</label>
                  <input
                    type="number"
                    name="day_of_week"
                    value={formData.day_of_week}
                    onChange={handleInputChange}
                    className="form-input"
                    min="0"
                    max="6"
                    required
                  />
                </div>
                <div className="form-group">
                  <label className="form-label">Hour (0-23)</label>
                  <input
                    type="number"
                    name="hour"
                    value={formData.hour}
                    onChange={handleInputChange}
                    className="form-input"
                    min="0"
                    max="23"
                    required
                  />
                </div>
              </div>

              <button type="submit" className="btn btn-primary" disabled={loading}>
                {loading ? (
                  <>
                    <span className="loading"></span>
                    Predicting...
                  </>
                ) : (
                  '🚀 Predict Air Quality'
                )}
              </button>
            </form>

            {error && (
              <div className="error">
                {error}
              </div>
            )}
          </div>
        </div>

        {prediction && (
          <div className="prediction-results">
            <div className="card prediction-card">
              <h2>7-Day SO2 Predictions</h2>
              
              <div className="predictions-grid">
                {prediction.ground && (
                  <div className="prediction-item">
                    <h3>Ground Sensor Prediction</h3>
                    <div className={`prediction-value ${getAQIClass(prediction.ground.prediction)}`}>
                      {prediction.ground.prediction.toFixed(2)} μg/m³
                    </div>
                    <div className="prediction-details">
                      <p><strong>Confidence:</strong> {Math.round(prediction.ground.confidence * 100)}%</p>
                      <p><strong>Model:</strong> {prediction.ground.model_name}</p>
                    </div>
                  </div>
                )}

                {prediction.satellite && (
                  <div className="prediction-item">
                    <h3>Satellite Prediction</h3>
                    <div className={`prediction-value ${getAQIClass(prediction.satellite.prediction)}`}>
                      {prediction.satellite.prediction.toFixed(2)} μg/m³
                    </div>
                    <div className="prediction-details">
                      <p><strong>Confidence:</strong> {Math.round(prediction.satellite.confidence * 100)}%</p>
                      <p><strong>Model:</strong> {prediction.satellite.model_name}</p>
                    </div>
                  </div>
                )}
              </div>

              <div className="chart-container">
                <h3>Prediction Comparison</h3>
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={prepareChartData()}>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.1)" />
                    <XAxis dataKey="name" stroke="#ffffff" />
                    <YAxis stroke="#ffffff" />
                    <Tooltip 
                      contentStyle={{
                        backgroundColor: 'rgba(0,0,0,0.8)',
                        border: '1px solid #00d4ff',
                        borderRadius: '8px',
                        color: '#ffffff'
                      }}
                    />
                    <Bar dataKey="value" fill="#00d4ff" />
                  </BarChart>
                </ResponsiveContainer>
              </div>

              <div className="chart-container">
                <h3>Data Source Comparison</h3>
                <ResponsiveContainer width="100%" height={300}>
                  <PieChart>
                    <Pie
                      data={prepareChartData()}
                      cx="50%"
                      cy="50%"
                      labelLine={false}
                      label={true}
                      outerRadius={80}
                      fill="#8884d8"
                      dataKey="value"
                    >
                      {prepareChartData().map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Explore;
