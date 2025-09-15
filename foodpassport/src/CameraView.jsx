import React, { useRef, useState, useEffect } from 'react';
import { mockResponse } from './mockData';
import ResultsView from './ResultsView';
import SettingsView from './SettingsView';

const CameraView = () => {
  const videoRef = useRef(null);
  const photoRef = useRef(null);
  const fileInputRef = useRef(null);
  const [stream, setStream] = useState(null);
  const [capturedImage, setCapturedImage] = useState(null);
  const [aiResponse, setAiResponse] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [view, setView] = useState('welcome');
  const [dietarySettings, setDietarySettings] = useState([]);

  useEffect(() => {
    if (videoRef.current && stream) {
      videoRef.current.srcObject = stream;
    }
  }, [stream]);

  const startCamera = async () => {
    try {
      const videoStream = await navigator.mediaDevices.getUserMedia({ video: true });
      setStream(videoStream);
      setView('camera');
    } catch (err) {
      console.error("Error accessing camera: ", err);
      alert("Failed to access camera. Please make sure you have given permission and no other apps are using it.");
    }
  };

  const stopCamera = () => {
    if (stream) {
      stream.getTracks().forEach(track => {
        track.stop();
      });
      setStream(null);
    }
  };

  const takeAnotherPhoto = () => {
    setCapturedImage(null);
    setAiResponse(null);
    startCamera();
  };

  const handleFileChange = (event) => {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setCapturedImage(reader.result);
        setView('photo-preview');
      };
      reader.readAsDataURL(file);
    }
  };

  const takePhoto = () => {
    const width = 414;
    const height = width / (16/9);

    const photo = photoRef.current;
    photo.width = width;
    photo.height = height;
    const ctx = photo.getContext('2d');

    ctx.drawImage(videoRef.current, 0, 0, width, height);

    const photoDataUrl = photo.toDataURL('image/jpeg');
    setCapturedImage(photoDataUrl);
    stopCamera();
    setView('photo-preview');
  };

  const analyzePhoto = () => {
    setIsLoading(true);
    setTimeout(() => {
      console.log('Mock response received:', mockResponse);
      setAiResponse(mockResponse);
      setIsLoading(false);
      setView('results');
    }, 1000);
  };
  
  if (isLoading) {
    return <h1>Analyzing photo... <span className="spinner">⚙️</span></h1>;
  }

  if (view === 'results') {
    return <ResultsView response={aiResponse} capturedImage={capturedImage} onGoBack={takeAnotherPhoto} dietarySettings={dietarySettings} />;
  }
  
  switch (view) {
    case 'welcome':
      return (
        <div>
          <button className="settings-icon" onClick={() => setView('settings')}>⚙️</button>
          <h1>AI Food Passport</h1>
          <p>This app uses AI to identify food and provide dietary information.</p>
          <button onClick={startCamera}>Start Camera</button>
          <button onClick={() => fileInputRef.current.click()}>Upload from Gallery</button>
          <input 
            type="file" 
            accept="image/*" 
            onChange={handleFileChange} 
            ref={fileInputRef} 
            style={{ display: 'none' }} 
          />
        </div>
      );
    case 'camera':
      return (
        <div>
          <h1>AI Food Passport</h1>
          <video ref={videoRef} autoPlay playsInline muted style={{ width: '100%', maxWidth: '500px' }} />
          <br />
          <button onClick={takePhoto}>Take Picture</button>
          <button onClick={stopCamera}>Stop Camera</button>
        </div>
      );
    case 'photo-preview':
      return (
        <div>
          <h1>AI Food Passport</h1>
          <h2>Captured Photo</h2>
          <img src={capturedImage} alt="Captured" style={{ width: '100%', maxWidth: '500px' }} />
          <br />
          <button onClick={analyzePhoto} disabled={isLoading}>Analyze Photo</button>
          <button onClick={() => setView('camera')}>Take Another Photo</button>
        </div>
      );
    case 'settings':
      return (
        <SettingsView
          settings={dietarySettings}
          onSettingsChange={setDietarySettings}
          onGoBack={() => setView('welcome')}
        />
      );
    default:
      return null;
  }
};

export default CameraView;