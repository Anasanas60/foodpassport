import React, { useState } from 'react';

const SettingsView = ({ settings, onSettingsChange, onGoBack }) => {
  const [inputValue, setInputValue] = useState('');

  const handleInputChange = (event) => {
    setInputValue(event.target.value);
  };

  const handleAddAllergy = () => {
    if (inputValue.trim()) {
      onSettingsChange([...settings, inputValue.trim()]);
      setInputValue(''); // Clear the input field
    }
  };

  const handleRemoveAllergy = (allergyToRemove) => {
    onSettingsChange(settings.filter(allergy => allergy !== allergyToRemove));
  };

  return (
    <div>
      <h1>Settings</h1>
      <h3>My Allergies & Restrictions</h3>
      <input
        type="text"
        value={inputValue}
        onChange={handleInputChange}
        placeholder="e.g., Peanuts, Dairy, Gluten"
      />
      <button onClick={handleAddAllergy}>Add</button>
      
      {settings.length > 0 && (
        <>
          <h4>My List:</h4>
          <ul>
            {settings.map((allergy, index) => (
              <li key={index}>
                {allergy}
                <button onClick={() => handleRemoveAllergy(allergy)} style={{ marginLeft: '10px' }}>
                  &times;
                </button>
              </li>
            ))}
          </ul>
        </>
      )}

      <br />
      <button onClick={onGoBack}>Go Back</button>
    </div>
  );
};

export default SettingsView;