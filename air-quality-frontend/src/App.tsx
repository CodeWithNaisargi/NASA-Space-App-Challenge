import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import './App.css';
import Navbar from './components/Navbar';
import Home from './pages/Home';
import Explore from './pages/Explore';
import Contact from './pages/Contact';
import Flowchart from './pages/Flowchart';
import About from './pages/About';

function App() {
  return (
    <Router>
      <div className="App">
        <Navbar />
        <div className="stars"></div>
        <div className="twinkling"></div>
        <main className="main-content">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/explore" element={<Explore />} />
            <Route path="/contact" element={<Contact />} />
            <Route path="/flowchart" element={<Flowchart />} />
            <Route path="/about" element={<About />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;