import React from 'react';
import StarsBackground from '../components/StarsBackground';
import './About.css';

const About: React.FC = () => {
  return (
    <div className="page about-page">
      <StarsBackground />
      <h1 className="page-title">About AirScope</h1>
      <p className="page-subtitle">
        NASA Space Apps Challenge 2024 - AI-Powered Air Quality Prediction
      </p>

      <div className="about-content">
        <div className="mission-section">
          <div className="card">
            <h2>🌍 Our Mission</h2>
            <p>
              AirScope is an innovative AI-powered air quality prediction system developed for the 
              NASA Space Apps Challenge 2024. Our mission is to leverage machine learning and 
              real-time data to predict air quality conditions, helping communities make informed 
              decisions about environmental health and safety.
            </p>
            <p>
              By combining advanced data science techniques with user-friendly interfaces, we aim 
              to democratize access to air quality information and contribute to global environmental 
              protection efforts.
            </p>
          </div>
        </div>

        <div className="project-details">
          <div className="card">
            <h2>🚀 Project Overview</h2>
            <div className="detail-grid">
              <div className="detail-item">
                <h3>Challenge Theme</h3>
                <p>NASA Space Apps Challenge 2024 - Environmental Monitoring</p>
              </div>
              <div className="detail-item">
                <h3>Technology Focus</h3>
                <p>Machine Learning, AI, Data Science, Web Development</p>
              </div>
              <div className="detail-item">
                <h3>Data Source</h3>
                <p>Real air quality data from Delhi, India (18,776+ measurements)</p>
              </div>
              <div className="detail-item">
                <h3>Target Users</h3>
                <p>Environmental scientists, researchers, public health officials, citizens</p>
              </div>
            </div>
          </div>
        </div>

        <div className="technical-approach">
          <div className="card">
            <h2>🔬 Technical Approach</h2>
            <div className="approach-steps">
              <div className="approach-step">
                <div className="step-number">1</div>
                <div className="step-content">
                  <h3>Data Collection & Preprocessing</h3>
                  <p>
                    We collected comprehensive air quality data including CO, NO, NO2, O3, SO2, 
                    PM2.5, PM10, and NH3 measurements. The data was cleaned, validated, and 
                    preprocessed to ensure quality and consistency.
                  </p>
                </div>
              </div>
              <div className="approach-step">
                <div className="step-number">2</div>
                <div className="step-content">
                  <h3>Feature Engineering</h3>
                  <p>
                    We created 23 engineered features including temporal features (hour, day, month), 
                    cyclical encodings, pollutant ratios, and logarithmic transformations to improve 
                    model performance.
                  </p>
                </div>
              </div>
              <div className="approach-step">
                <div className="step-number">3</div>
                <div className="step-content">
                  <h3>Model Development</h3>
                  <p>
                    We trained and evaluated 5 different machine learning algorithms: Random Forest, 
                    Gradient Boosting, Logistic Regression, SVM, and Decision Tree. Cross-validation 
                    and hyperparameter tuning were used to optimize performance.
                  </p>
                </div>
              </div>
              <div className="approach-step">
                <div className="step-number">4</div>
                <div className="step-content">
                  <h3>Model Deployment</h3>
                  <p>
                    The best-performing model was deployed as a RESTful API using Django, providing 
                    real-time predictions and batch processing capabilities for scalable usage.
                  </p>
                </div>
              </div>
              <div className="approach-step">
                <div className="step-number">5</div>
                <div className="step-content">
                  <h3>User Interface</h3>
                  <p>
                    A modern React TypeScript frontend with NASA space theme provides an intuitive 
                    interface for data input, prediction visualization, and result interpretation.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="results-section">
          <div className="card">
            <h2>📊 Results & Achievements</h2>
            <div className="results-grid">
              <div className="result-item">
                <div className="result-icon">🎯</div>
                <div className="result-content">
                  <h3>High Accuracy</h3>
                  <p>Achieved 95%+ accuracy on test dataset using ensemble methods</p>
                </div>
              </div>
              <div className="result-item">
                <div className="result-icon">⚡</div>
                <div className="result-content">
                  <h3>Fast Predictions</h3>
                  <p>Real-time predictions in under 100ms for single queries</p>
                </div>
              </div>
              <div className="result-item">
                <div className="result-icon">📈</div>
                <div className="result-content">
                  <h3>Scalable Architecture</h3>
                  <p>RESTful API supports both single and batch predictions</p>
                </div>
              </div>
              <div className="result-item">
                <div className="result-icon">🌐</div>
                <div className="result-content">
                  <h3>User-Friendly Interface</h3>
                  <p>Intuitive web interface with data visualization and charts</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="impact-section">
          <div className="card">
            <h2>🌱 Environmental Impact</h2>
            <p>
              AirScope contributes to environmental protection by providing accurate air quality 
              predictions that can help:
            </p>
            <ul className="impact-list">
              <li>Enable early warning systems for poor air quality conditions</li>
              <li>Support public health initiatives and policy making</li>
              <li>Help individuals make informed decisions about outdoor activities</li>
              <li>Contribute to research on air quality patterns and trends</li>
              <li>Support urban planning and environmental monitoring efforts</li>
            </ul>
          </div>
        </div>

        <div className="future-work">
          <div className="card">
            <h2>🔮 Future Enhancements</h2>
            <div className="future-grid">
              <div className="future-item">
                <h3>Geographic Expansion</h3>
                <p>Extend the model to other cities and regions worldwide</p>
              </div>
              <div className="future-item">
                <h3>Real-time Data Integration</h3>
                <p>Connect to live sensor networks for real-time predictions</p>
              </div>
              <div className="future-item">
                <h3>Advanced Visualizations</h3>
                <p>Interactive maps and 3D visualizations of air quality data</p>
              </div>
              <div className="future-item">
                <h3>Mobile Application</h3>
                <p>Native mobile app for on-the-go air quality monitoring</p>
              </div>
              <div className="future-item">
                <h3>Machine Learning Improvements</h3>
                <p>Deep learning models and ensemble techniques</p>
              </div>
              <div className="future-item">
                <h3>API Ecosystem</h3>
                <p>Public API for third-party integrations and research</p>
              </div>
            </div>
          </div>
        </div>

        <div className="team-section">
          <div className="card">
            <h2>👥 Development Team</h2>
            <p>
              This project was developed by a dedicated team of data scientists, software engineers, 
              and environmental researchers participating in the NASA Space Apps Challenge 2024.
            </p>
            
            <div className="team-members">
              <div className="team-member">
                <div className="member-photo">
                  <div className="photo-placeholder">
                    <span>👩‍💼</span>
                  </div>
                </div>
                <div className="member-info">
                  <h3>Naisargi Patel</h3>
                  <p className="member-role">Team Leader</p>
                  <p className="member-bio">Leading the project vision and coordinating team efforts for the NASA Space Apps Challenge.</p>
                </div>
              </div>
              
              <div className="team-member">
                <div className="member-photo">
                  <div className="photo-placeholder">
                    <span>👨‍💻</span>
                  </div>
                </div>
                <div className="member-info">
                  <h3>Divy Pattani</h3>
                  <p className="member-role">Data Scientist</p>
                  <p className="member-bio">Specialized in machine learning algorithms and data preprocessing for air quality prediction.</p>
                </div>
              </div>
              
              <div className="team-member">
                <div className="member-photo">
                  <div className="photo-placeholder">
                    <span>👨‍🔬</span>
                  </div>
                </div>
                <div className="member-info">
                  <h3>Uday Chauhan</h3>
                  <p className="member-role">ML Engineer</p>
                  <p className="member-bio">Focused on model optimization and performance tuning for accurate predictions.</p>
                </div>
              </div>
              
              <div className="team-member">
                <div className="member-photo">
                  <div className="photo-placeholder">
                    <span>👩‍💻</span>
                  </div>
                </div>
                <div className="member-info">
                  <h3>Pragati Prajapati</h3>
                  <p className="member-role">Frontend Developer</p>
                  <p className="member-bio">Creating intuitive user interfaces and interactive data visualizations.</p>
                </div>
              </div>
              
              <div className="team-member">
                <div className="member-photo">
                  <div className="photo-placeholder">
                    <span>👨‍💼</span>
                  </div>
                </div>
                <div className="member-info">
                  <h3>Jigar Paun</h3>
                  <p className="member-role">Backend Developer</p>
                  <p className="member-bio">Building robust APIs and managing the server infrastructure for the application.</p>
                </div>
              </div>
            </div>
            
            <div className="team-skills">
              <div className="skill-category">
                <h3>Data Science & ML</h3>
                <p>Python, scikit-learn, pandas, numpy, matplotlib, seaborn</p>
              </div>
              <div className="skill-category">
                <h3>Backend Development</h3>
                <p>Django, Django REST Framework, Python, SQLite</p>
              </div>
              <div className="skill-category">
                <h3>Frontend Development</h3>
                <p>React, TypeScript, CSS3, Recharts, Axios</p>
              </div>
              <div className="skill-category">
                <h3>DevOps & Deployment</h3>
                <p>Git, npm, pip, joblib, CORS</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default About;
