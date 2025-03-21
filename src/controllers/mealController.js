const fs = require('fs/promises');
const { parse } = require('csv-parse');

// Helper function to parse CSV
const fetchMealRecommendations = async (ingredients) => {
    try {
        const filePath = "C:\\Users\\bpnap\\OneDrive\\Desktop\\meal\\test_recipes.csv";
        const fileContent = await fs.readFile(filePath, { encoding: 'utf8' });

        const records = await new Promise((resolve, reject) => {
            parse(fileContent, {
                columns: true,
                skip_empty_lines: true,
                relax_column_count: true
            }, (err, records) => {
                if (err) reject(err);
                else resolve(records);
            });
        });

        return records.filter(recipe => {
            if (!recipe.Ingredients) return false;
            
            const recipeIngredients = recipe.Ingredients.split(',')
                .map(ing => ing.trim().toLowerCase());
            const searchIngredients = ingredients.map(ing => ing.trim().toLowerCase());

            return searchIngredients.some(searchIng => 
                recipeIngredients.some(recipeIng => 
                    recipeIng.includes(searchIng)
                )
            );
        }).map(recipe => ({
            meal: recipe.Name,
            ingredients: recipe.Ingredients.split(',').map(ing => ing.trim()),
            details: {
                prepTime: recipe['Prep Time'],
                cookTime: recipe['Cook Time'],
                url: recipe.url
            }
        }));

    } catch (error) {
        console.error("Error in fetchMealRecommendations:", error);
        throw error;
    }
};

// Controller function
const getMealSuggestions = async (req, res) => {
    try {
        if (!req.body.ingredients || !Array.isArray(req.body.ingredients)) {
            return res.status(400).json({ error: "Please provide an array of ingredients" });
        }

        if (req.body.ingredients.length === 0) {
            return res.status(400).json({ error: "Ingredients array cannot be empty" });
        }

        const recommendations = await fetchMealRecommendations(req.body.ingredients);
        
        if (recommendations.length === 0) {
            return res.status(200).json({
                count: 0,
                matches: [],
                message: "No recipes found with those ingredients"
            });
        }

        res.json({
            count: recommendations.length,
            matches: recommendations
        });

    } catch (error) {
        console.error("Error in meal suggestions:", error);
        res.status(500).json({ 
            error: "Failed to process request",
            details: error.message
        });
    }
};

module.exports = {
    getMealSuggestions
};