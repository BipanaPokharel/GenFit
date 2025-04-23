// controllers/mealController.js
const fs = require('fs').promises;
const { parse } = require('csv-parse');
const MealPlan = require('../models/mealPlan'); 

// ==================== CSV Meal Suggestions ====================
const fetchMealRecommendations = async (ingredients, exclude = [], dietary) => {
    try {
        const filePath = "C:\\Users\\bpnap\\OneDrive\\Desktop\\meal\\test_recipes.csv";
        const fileContent = await fs.readFile(filePath, { encoding: 'utf8' });

        const records = await new Promise((resolve, reject) => {
            parse(fileContent, {
                columns: true,
                skip_empty_lines: true,
                relax_column_count: true
            }, (err, records) => {
                err ? reject(err) : resolve(records);
            });
        });

        return records.filter(recipe => {
            if (!recipe.Ingredients) return false;

            const recipeIngredients = recipe.Ingredients.split(',')
                .map(ing => ing.trim().toLowerCase());
            const searchIngredients = ingredients.map(ing => ing.trim().toLowerCase());
            const excludeIngredients = exclude.map(ing => ing.trim().toLowerCase());

            // Exclusion check
            if (excludeIngredients.some(ex => recipeIngredients.some(ri => ri.includes(ex)))) {
                return false;
            }

            // Dietary checks
            if (dietary) {
                const containsMeat = recipeIngredients.some(ing =>
                    ['chicken', 'meat', 'beef', 'pork', 'fish'].includes(ing)
                );
                
                if (dietary === 'vegetarian' && containsMeat) return false;
                if (dietary === 'vegan' && (containsMeat || recipeIngredients.includes('dairy'))) return false;
            }

            // Ingredient matching
            return searchIngredients.some(si => 
                recipeIngredients.some(ri => ri.includes(si))
            );
        }).map(recipe => ({
            meal: recipe.Name,
            ingredients: recipe.Ingredients.split(',').map(ing => ing.trim()),
            vegetarian: !recipe.Ingredients.split(',').some(ing =>
                ['chicken', 'meat', 'beef', 'pork', 'fish'].includes(ing.trim().toLowerCase())
            ),
            details: {
                prepTime: recipe['Prep Time'],
                cookTime: recipe['Cook Time'],
                url: recipe.url
            }
        }));

    } catch (error) {
        console.error("Meal Recommendation Error:", error);
        throw error;
    }
};

const getMealSuggestions = async (req, res) => {
    try {
        const { ingredients, exclude = [], dietary, max_results = 5 } = req.body;
        
        if (!Array.isArray(ingredients) || ingredients.length === 0) {
            return res.status(400).json({ 
                success: false,
                error: "Please provide a non-empty array of ingredients" 
            });
        }

        const recommendations = await fetchMealRecommendations(ingredients, exclude, dietary);
        const results = recommendations.slice(0, max_results);

        res.json({
            success: true,
            count: results.length,
            matches: results
        });

    } catch (error) {
        console.error("Suggestion Error:", error);
        res.status(500).json({
            success: false,
            error: "Failed to generate suggestions",
            details: error.message
        });
    }
};

// ==================== Meal Plan CRUD Operations ====================
const createMealPlan = async (req, res) => {
    try {
        // Debug: Log the incoming request body
        console.log("Request Body:", req.body);

        // Validate the required fields (basic validation)
        const { user_id, meal_type, calories, meal_name, ingredients, prep_time, cook_time, meal_image_url, meal_date } = req.body;
        
        if (!user_id || !meal_name || !ingredients || !meal_type) {
            return res.status(400).json({
                success: false,
                error: "Missing required fields."
            });
        }

        // Create a new meal plan in the database
        const mealPlan = await MealPlan.create({
            user_id,
            meal_type,
            calories,
            meal_name,
            ingredients,
            prep_time,
            cook_time,
            meal_image_url,
            meal_date
        });

        res.status(201).json({
            success: true,
            data: mealPlan
        });

    } catch (error) {
        console.error("Create Meal Plan Error:", error);
        res.status(400).json({
            success: false,
            error: `Validation failed: ${error.message}`
        });
    }
};


const getMealPlans = async (req, res) => {
    try {
        const { user_id, date, page = 1, limit = 10 } = req.query;
        const where = {};
        
        if (user_id) where.user_id = user_id;
        if (date) where.meal_date = date;

        const offset = (page - 1) * limit;

        const { count, rows } = await MealPlan.findAndCountAll({
            where,
            limit: parseInt(limit),
            offset: offset,
            order: [['meal_date', 'DESC']]
        });

        res.json({
            success: true,
            total: count,
            page: parseInt(page),
            totalPages: Math.ceil(count / limit),
            data: rows
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            error: "Failed to fetch meal plans"
        });
    }
};

const updateMealPlan = async (req, res) => {
    try {
        const { id } = req.params;
        const [updated] = await MealPlan.update(req.body, {
            where: { plan_id: id }
        });
        
        if (!updated) {
            return res.status(404).json({
                success: false,
                error: "Meal plan not found"
            });
        }

        const updatedPlan = await MealPlan.findByPk(id);
        res.json({
            success: true,
            data: updatedPlan
        });

    } catch (error) {
        res.status(400).json({
            success: false,
            error: `Update failed: ${error.message}`
        });
    }
};

const deleteMealPlan = async (req, res) => {
    try {
        const { id } = req.params;
        const deleted = await MealPlan.destroy({
            where: { plan_id: id }
        });
        
        if (!deleted) {
            return res.status(404).json({
                success: false,
                error: "Meal plan not found"
            });
        }

        res.status(204).send();

    } catch (error) {
        res.status(500).json({
            success: false,
            error: "Deletion failed"
        });
    }
};

module.exports = { 
    getMealSuggestions,
    createMealPlan,
    getMealPlans,
    updateMealPlan,
    deleteMealPlan
};