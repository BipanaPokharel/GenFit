const { sequelize } = require("../config/dbINIT");
const { DataTypes } = require("sequelize");

module.exports = (sequelize, DataTypes) => {
    const MealPlan = sequelize.define('MealPlan', {
        plan_id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },
        user_id: {
            type: DataTypes.INTEGER,
            allowNull: true 
        },
        meal_type: {
            type: DataTypes.STRING(50),
            allowNull: false 
        },
        calories: {
            type: DataTypes.DECIMAL(6, 2),
            allowNull: true 
        },
        meal_name: {
            type: DataTypes.STRING(255),
            allowNull: false 
        },
        ingredients: {
            type: DataTypes.JSONB,
            allowNull: false 
        },
        prep_time: {
            type: DataTypes.STRING(50),
            allowNull: true 
        },
        cook_time: {
            type: DataTypes.STRING(50),
            allowNull: true 
        },
        meal_image_url: {
            type: DataTypes.STRING(255),
            allowNull: true 
        },
        meal_date: {
            type: DataTypes.DATEONLY,
            allowNull: false 
        },
        created_at: {
            type: DataTypes.DATE,
            defaultValue: DataTypes.NOW
        }
    }, {
        tableName: 'meal_plans',
        timestamps: false, 
        createdAt: 'created_at',
        updatedAt: false 
    });

    return MealPlan;
};
