import React from 'react';

const ResultsView = ({ response, onGoBack, capturedImage, dietarySettings }) => {
  const { title, summary, translation, calories, macronutrients, ingredients } = response;
  const warnings = response.warnings || [];
  
  const matches = dietarySettings.filter(allergy => {
    return ingredients.some(ingredient => ingredient.toLowerCase().includes(allergy.toLowerCase()));
  });

  return (
    <div>
      <button onClick={onGoBack}>Go Back</button>
      <h2>Results for: {title}</h2>
      
      {matches.length > 0 && (
        <div style={{ backgroundColor: '#ffcccc', padding: '10px', borderRadius: '5px' }}>
          <h3>⚠️ Warning: Potential Allergies!</h3>
          <p>This dish may contain ingredients that you are allergic to. Please double check the list below.</p>
          <ul>
            {matches.map((allergy, index) => (
              <li key={index}>**Possible match found for: {allergy}**</li>
            ))}
          </ul>
        </div>
      )}

      <img src={capturedImage} alt="Captured" style={{ maxWidth: '100%', height: 'auto' }} />
      <p>{summary}</p>
      
      <h3>Macronutrients (per 100g)</h3>
      <ul>
        <li>**Calories:** {calories} kcal</li>
        <li>**Protein:** {macronutrients.protein}g</li>
        <li>**Carbohydrates:** {macronutrients.carbohydrates}g</li>
        <li>**Fats:** {macronutrients.fats}g</li>
      </ul>

      <h3>Translations</h3>
      <ul>
        {Object.entries(translation).map(([lang, text]) => (
          <li key={lang}>**{lang.charAt(0).toUpperCase() + lang.slice(1)}:** {text}</li>
        ))}
      </ul>

      <h3>Warnings</h3>
      <ul>
        {warnings.map((warning, index) => (
          <li key={index}>{warning}</li>
        ))}
      </ul>
    </div>
  );
};

export default ResultsView;