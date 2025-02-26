import fetch from "node-fetch";
require("dotenv").config(); 

const fetchMealRecommendations = async (ingredients) => {
  try {
    const apiKey = process.env.SPOONACULAR_API_KEY; 
    const response = await fetch(
      `https://api.spoonacular.com/recipes/findByIngredients?ingredients=${ingredients.join(
        ","
      )}&apiKey=${apiKey}`
    );
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();

    return data.map((meal) => ({
      meal: meal.title,
      ingredients: meal.usedIngredients.map((ing) => ing.name),
    }));
  } catch (error) {
    console.error("Error fetching meal recommendations:", error);
    throw error;
  }
};

export { fetchMealRecommendations };
