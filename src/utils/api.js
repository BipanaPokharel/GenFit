const express = require('express');
const router = express.Router();
const fs = require('fs/promises'); // Use fs.promises for async file operations
const { parse } = require('csv-parse');

// Function to fetch meal recommendations from CSV file
const fetchMealRecommendations = async (ingredients) => {
    try {
        const filePath = "C:\\Users\\bpnap\\OneDrive\\Desktop\\meal\\test_recipes.csv";

        const fileContent = await fs.readFile(filePath, { encoding: 'utf8' });

        const records = await new Promise((resolve, reject) => {
            parse(fileContent, {
                columns: true,
                skip_empty_lines: true,
            }, (err, records) => {
                if (err) {
                    console.error("Error parsing CSV:", err);
                    reject(err);
                } else {
                    console.log("CSV parsed successfully.");
                    resolve(records);
                }
            });
        });

        console.log("Records:", records);

        const recommendedMeals = records.filter(recipe => {
            if (!recipe.ingredients) return false;
            
            const recipeIngredients = recipe.ingredients.split(',')
                .map(ing => ing.trim().toLowerCase());
            const searchIngredients = ingredients.map(ing => ing.trim().toLowerCase());

            // Check if any of the search ingredients are in the recipe's ingredients
            // This is a more lenient match than requiring all ingredients
            return searchIngredients.some(ingredient => 
                recipeIngredients.includes(ingredient)
            );
        }).map(recipe => ({
            meal: recipe.name,
            ingredients: recipe.ingredients.split(',').map(ing => ing.trim())
        }));

        console.log("Recommended meals:", recommendedMeals);

        return recommendedMeals;

    } catch (error) {
        console.error("Error processing meal recommendations:", error);
        throw error;
    }
};

// Endpoint to handle meal recommendation requests
router.post('/meals/suggestions', async (req, res) => {
    try {
        const ingredients = req.body.ingredients;
        const recommendations = await fetchMealRecommendations(ingredients);
        res.json(recommendations); // Send recommendations as response
    } catch (error) {
        console.error("Error handling /meals/suggestions request:", error);
        res.status(500).json({ error: "Failed to fetch recommendations" });
    }
});

module.exports = router;
