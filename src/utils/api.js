// const express = require('express');
// const router = express.Router();
// const fs = require('fs/promises');
// const { parse } = require('csv-parse');

// const fetchMealRecommendations = async (ingredients) => {
//     try {
//         const filePath = "C:\\Users\\bpnap\\OneDrive\\Desktop\\meal\\test_recipes.csv";

//         console.log("Reading CSV file from:", filePath);
//         const fileContent = await fs.readFile(filePath, { encoding: 'utf8' });

//         const records = await new Promise((resolve, reject) => {
//             parse(fileContent, {
//                 columns: true,
//                 skip_empty_lines: true,
//                 relax_column_count: true
//             }, (err, records) => {
//                 if (err) reject(err);
//                 else resolve(records);
//             });
//         });

//         console.log("Successfully parsed", records.length, "recipes");

//         const recommendedMeals = records.filter(recipe => {
//             if (!recipe.Ingredients) {
//                 console.log("Skipping recipe with missing ingredients:", recipe.Name);
//                 return false;
//             }

//             const recipeIngredients = recipe.Ingredients.split(',')
//                 .map(ing => ing.trim().toLowerCase());
                
//             const searchIngredients = ingredients.map(ing => ing.trim().toLowerCase());

//             // Check for partial matches (e.g., "chicken" matches "boneless chicken breast")
//             return searchIngredients.some(searchIng => 
//                 recipeIngredients.some(recipeIng => 
//                     recipeIng.includes(searchIng)
//                 )
//             );
//         }).map(recipe => ({
//             meal: recipe.Name,
//             ingredients: recipe.Ingredients.split(',').map(ing => ing.trim()),
//             details: {
//                 prepTime: recipe['Prep Time'],
//                 cookTime: recipe['Cook Time'],
//                 url: recipe.url
//             }
//         }));

//         console.log("Found", recommendedMeals.length, "matching meals");
//         return recommendedMeals;

//     } catch (error) {
//         console.error("Error in fetchMealRecommendations:", error);
//         throw error;
//     }
// };

// router.post('/meals/suggestions', async (req, res) => {
//     try {
//         console.log("Received request with ingredients:", req.body.ingredients);

//         if (!req.body.ingredients || !Array.isArray(req.body.ingredients)) {
//             return res.status(400).json({ error: "Please provide an array of ingredients" });
//         }

//         if (req.body.ingredients.length === 0) {
//             return res.status(400).json({ error: "Ingredients array cannot be empty" });
//         }

//         const recommendations = await fetchMealRecommendations(req.body.ingredients);
        
//         if (recommendations.length === 0) {
//             console.log("No matches found for:", req.body.ingredients);
//             return res.status(404).json({ 
//                 message: "No recipes found with those ingredients",
//                 suggestedIngredients: ["chicken", "garlic", "onion", "tomato"] // Example fallback
//             });
//         }

//         res.json({
//             count: recommendations.length,
//             matches: recommendations
//         });

//     } catch (error) {
//         console.error("Error in POST /meals/suggestions:", error);
//         res.status(500).json({ 
//             error: "Failed to process request",
//             details: error.message
//         });
//     }
// });

// module.exports = router;