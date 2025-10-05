import React, { useState } from 'react';
import StarsBackground from '../components/StarsBackground';
import './Contact.css';

const Contact: React.FC = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    subject: '',
    message: ''
  });

  const [submitted, setSubmitted] = useState(false);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // In a real application, you would send this data to a backend
    console.log('Form submitted:', formData);
    setSubmitted(true);
    setTimeout(() => setSubmitted(false), 3000);
  };

  return (
    <div className="page contact-page">
      <StarsBackground />
      <h1 className="page-title">Contact Us</h1>
      <p className="page-subtitle">
        Get in touch with our NASA Space Apps Challenge team
      </p>

      <div className="contact-container">
        <div className="contact-info">
          <div className="card">
            <h2>Project Information</h2>
            <div className="info-item">
              <h3>🌌 Project Name</h3>
              <p>AirScope - AI-Powered Air Quality Prediction</p>
            </div>
            <div className="info-item">
              <h3>🚀 Challenge</h3>
              <p>NASA Space Apps Challenge 2024</p>
            </div>
            <div className="info-item">
              <h3>🎯 Mission</h3>
              <p>Using machine learning to predict and monitor air quality for environmental protection</p>
            </div>
            <div className="info-item">
              <h3>📧 Email</h3>
              <p>team@airscope-nasa.com</p>
            </div>
            <div className="info-item">
              <h3>🌍 Location</h3>
              <p>Global - Remote Team</p>
            </div>
          </div>

        </div>

        <div className="contact-form-container">
          <div className="card">
            <h2>Send us a Message</h2>
            {submitted ? (
              <div className="success">
                <h3>✅ Message Sent!</h3>
                <p>Thank you for your interest. We'll get back to you soon!</p>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="contact-form">
                <div className="form-group">
                  <label className="form-label">Name</label>
                  <input
                    type="text"
                    name="name"
                    value={formData.name}
                    onChange={handleInputChange}
                    className="form-input"
                    placeholder="Your full name"
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Email</label>
                  <input
                    type="email"
                    name="email"
                    value={formData.email}
                    onChange={handleInputChange}
                    className="form-input"
                    placeholder="your.email@example.com"
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Subject</label>
                  <input
                    type="text"
                    name="subject"
                    value={formData.subject}
                    onChange={handleInputChange}
                    className="form-input"
                    placeholder="What's this about?"
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Message</label>
                  <textarea
                    name="message"
                    value={formData.message}
                    onChange={handleInputChange}
                    className="form-input form-textarea"
                    placeholder="Tell us about your questions, suggestions, or feedback..."
                    rows={6}
                    required
                  />
                </div>

                <button type="submit" className="btn btn-primary">
                  🚀 Send Message
                </button>
              </form>
            )}
          </div>
        </div>
      </div>

      <div className="additional-info">
        <div className="card">
          <h2>Frequently Asked Questions</h2>
          <div className="faq-item">
            <h3>How accurate are the predictions?</h3>
            <p>Our machine learning models achieve over 95% accuracy on the test dataset, using multiple algorithms including Random Forest, Gradient Boosting, and Neural Networks.</p>
          </div>
          <div className="faq-item">
            <h3>What data sources are used?</h3>
            <p>We use real air quality data from Delhi, including CO, NO, NO2, O3, SO2, PM2.5, PM10, and NH3 measurements collected over multiple years.</p>
          </div>
          <div className="faq-item">
            <h3>Can I use this for other cities?</h3>
            <p>While our current model is trained on Delhi data, the framework can be adapted for other cities with similar air quality monitoring infrastructure.</p>
          </div>
          <div className="faq-item">
            <h3>Is the API free to use?</h3>
            <p>Yes, this is an open-source project developed for the NASA Space Apps Challenge. The API is available for educational and research purposes.</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Contact;
