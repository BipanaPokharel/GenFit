import fetch from "node-fetch"; // Use ES module import

const fetchMealRecommendations = async (ingredients) => {
  const apiKey = "dc6c0d6e55bc484687f192d48ffdaed0"; // Your API key
  const response = await fetch(
    `https://api.spoonacular.com/recipes/findByIngredients?ingredients=${ingredients.join(
      ","
    )}&apiKey=${apiKey}`
  );
  const data = await response.json();

  return data.map((meal) => ({
    meal: meal.title,
    ingredients: meal.usedIngredients.map((ing) => ing.name),
  }));
};

export { fetchMealRecommendations };
