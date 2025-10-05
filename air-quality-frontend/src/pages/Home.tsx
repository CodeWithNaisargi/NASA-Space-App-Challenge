import React from 'react';
import { Link } from 'react-router-dom';
import StarsBackground from '../components/StarsBackground';
import './Home.css';

const Home: React.FC = () => {
  return (
    <div className="page home-page">
      <StarsBackground />
      <div className="hero-section">
        <h1 className="hero-title">
          <span className="title-line">AirScope</span>
          <span className="title-subtitle">NASA Space Apps Challenge</span>
        </h1>
        <p className="hero-description">
          Advanced AI-powered air quality prediction system using machine learning 
          to forecast atmospheric conditions and help protect our planet's environment.
        </p>
        <div className="hero-buttons">
          <Link to="/explore" className="btn btn-primary">
            🚀 Explore Now
          </Link>
          <Link to="/about" className="btn btn-secondary">
            Learn More
          </Link>
        </div>
      </div>

      <div className="features-section">
        <h2 className="section-title">Key Features</h2>
        <div className="features-grid">
          <div className="feature-card">
            <div className="feature-icon">🤖</div>
            <h3>AI Prediction</h3>
            <p>Advanced machine learning models trained on real air quality data to provide accurate predictions.</p>
          </div>
          <div className="feature-card">
            <div className="feature-icon">📊</div>
            <h3>Real-time Analysis</h3>
            <p>Get instant air quality assessments based on current atmospheric conditions and pollutants.</p>
          </div>
          <div className="feature-card">
            <div className="feature-icon">🌍</div>
            <h3>Environmental Impact</h3>
            <p>Help make informed decisions to protect our environment and public health.</p>
          </div>
          <div className="feature-card">
            <div className="feature-icon">📈</div>
            <h3>Data Visualization</h3>
            <p>Beautiful charts and graphs to understand air quality trends and patterns.</p>
          </div>
        </div>
      </div>

      <div className="stats-section">
        <h2 className="section-title">Project Statistics</h2>
        <div className="stats-grid">
          <div className="stat-item">
            <div className="stat-number">18,776</div>
            <div className="stat-label">Data Points</div>
          </div>
          <div className="stat-item">
            <div className="stat-number">5</div>
            <div className="stat-label">ML Models</div>
          </div>
          <div className="stat-item">
            <div className="stat-number">23</div>
            <div className="stat-label">Features</div>
          </div>
          <div className="stat-item">
            <div className="stat-number">95%+</div>
            <div className="stat-label">Accuracy</div>
          </div>
        </div>
      </div>

      <div className="cta-section">
        <h2 className="cta-title">Ready to Explore Air Quality?</h2>
        <p className="cta-description">
          Start predicting air quality conditions and contribute to environmental protection.
        </p>
        <Link to="/explore" className="btn btn-primary btn-large">
          🌟 Start Predicting
        </Link>
      </div>
    </div>
  );
};

export default Home;
