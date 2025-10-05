import React from 'react';
import StarsBackground from '../components/StarsBackground';
import './Flowchart.css';

const Flowchart: React.FC = () => {
  return (
    <div className="page flowchart-page">
      <StarsBackground />
      <h1 className="page-title">System Architecture</h1>
      <p className="page-subtitle">
        Understanding how our AI-powered air quality prediction system works
      </p>

      <div className="flowchart-container">
        <div className="flowchart-diagram">
          <div className="flow-step data-collection">
            <div className="step-icon">📊</div>
            <h3>Data Collection</h3>
            <p>Real-time air quality data from sensors</p>
            <div className="step-details">
              <ul>
                <li>CO, NO, NO2, O3, SO2</li>
                <li>PM2.5, PM10, NH3</li>
                <li>Temporal features (hour, day, month)</li>
                <li>18,776+ data points</li>
              </ul>
            </div>
          </div>

          <div className="flow-arrow">↓</div>

          <div className="flow-step data-processing">
            <div className="step-icon">🔧</div>
            <h3>Data Processing</h3>
            <p>Cleaning and feature engineering</p>
            <div className="step-details">
              <ul>
                <li>Missing value handling</li>
                <li>Feature scaling & normalization</li>
                <li>Cyclical encoding</li>
                <li>23 engineered features</li>
              </ul>
            </div>
          </div>

          <div className="flow-arrow">↓</div>

          <div className="flow-step model-training">
            <div className="step-icon">🤖</div>
            <h3>Model Training</h3>
            <p>Multiple ML algorithms</p>
            <div className="step-details">
              <ul>
                <li>Random Forest</li>
                <li>Gradient Boosting</li>
                <li>Logistic Regression</li>
                <li>SVM & Decision Tree</li>
              </ul>
            </div>
          </div>

          <div className="flow-arrow">↓</div>

          <div className="flow-step model-selection">
            <div className="step-icon">⚡</div>
            <h3>Model Selection</h3>
            <p>Best performing model chosen</p>
            <div className="step-details">
              <ul>
                <li>Cross-validation</li>
                <li>Hyperparameter tuning</li>
                <li>Performance metrics</li>
                <li>95%+ accuracy achieved</li>
              </ul>
            </div>
          </div>

          <div className="flow-arrow">↓</div>

          <div className="flow-step api-deployment">
            <div className="step-icon">🌐</div>
            <h3>API Deployment</h3>
            <p>Django REST API</p>
            <div className="step-details">
              <ul>
                <li>RESTful endpoints</li>
                <li>Real-time predictions</li>
                <li>Batch processing</li>
                <li>CORS enabled</li>
              </ul>
            </div>
          </div>

          <div className="flow-arrow">↓</div>

          <div className="flow-step frontend">
            <div className="step-icon">💻</div>
            <h3>Frontend Interface</h3>
            <p>React TypeScript app</p>
            <div className="step-details">
              <ul>
                <li>Interactive forms</li>
                <li>Data visualization</li>
                <li>Real-time results</li>
                <li>NASA space theme</li>
              </ul>
            </div>
          </div>
        </div>

        <div className="architecture-details">
          <div className="card">
            <h2>Technology Stack</h2>
            <div className="tech-category">
              <h3>Backend</h3>
              <div className="tech-items">
                <span className="tech-item">Python</span>
                <span className="tech-item">Django</span>
                <span className="tech-item">Django REST Framework</span>
                <span className="tech-item">scikit-learn</span>
                <span className="tech-item">pandas</span>
                <span className="tech-item">numpy</span>
              </div>
            </div>
            <div className="tech-category">
              <h3>Frontend</h3>
              <div className="tech-items">
                <span className="tech-item">React</span>
                <span className="tech-item">TypeScript</span>
                <span className="tech-item">Recharts</span>
                <span className="tech-item">CSS3</span>
                <span className="tech-item">Axios</span>
              </div>
            </div>
            <div className="tech-category">
              <h3>ML/AI</h3>
              <div className="tech-items">
                <span className="tech-item">Random Forest</span>
                <span className="tech-item">Gradient Boosting</span>
                <span className="tech-item">Logistic Regression</span>
                <span className="tech-item">SVM</span>
                <span className="tech-item">Decision Tree</span>
                <span className="tech-item">Cross-validation</span>
              </div>
            </div>
          </div>

          <div className="card">
            <h2>Data Pipeline</h2>
            <div className="pipeline-step">
              <div className="pipeline-number">1</div>
              <div className="pipeline-content">
                <h4>Raw Data Ingestion</h4>
                <p>CSV files with air quality measurements</p>
              </div>
            </div>
            <div className="pipeline-step">
              <div className="pipeline-number">2</div>
              <div className="pipeline-content">
                <h4>Data Validation</h4>
                <p>Quality checks and outlier detection</p>
              </div>
            </div>
            <div className="pipeline-step">
              <div className="pipeline-number">3</div>
              <div className="pipeline-content">
                <h4>Feature Engineering</h4>
                <p>Creating derived features and transformations</p>
              </div>
            </div>
            <div className="pipeline-step">
              <div className="pipeline-number">4</div>
              <div className="pipeline-content">
                <h4>Model Training</h4>
                <p>Training multiple algorithms and evaluation</p>
              </div>
            </div>
            <div className="pipeline-step">
              <div className="pipeline-number">5</div>
              <div className="pipeline-content">
                <h4>Model Deployment</h4>
                <p>API endpoints for real-time predictions</p>
              </div>
            </div>
          </div>

          <div className="card">
            <h2>Performance Metrics</h2>
            <div className="metrics-grid">
              <div className="metric-item">
                <div className="metric-value">95%+</div>
                <div className="metric-label">Accuracy</div>
              </div>
              <div className="metric-item">
                <div className="metric-value">&lt;100ms</div>
                <div className="metric-label">Response Time</div>
              </div>
              <div className="metric-item">
                <div className="metric-value">23</div>
                <div className="metric-label">Features</div>
              </div>
              <div className="metric-item">
                <div className="metric-value">5</div>
                <div className="metric-label">ML Models</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Flowchart;
