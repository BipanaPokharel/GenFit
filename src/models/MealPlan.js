module.exports = (sequelize, DataTypes) => {
    const MealPlan = sequelize.define('MealPlan', {
      plan_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      user_id: DataTypes.INTEGER,
      meal_type: DataTypes.STRING(50),
      calories: DataTypes.DECIMAL(6,2),
      meal_name: DataTypes.STRING(255),
      ingredients: DataTypes.JSONB,
      prep_time: DataTypes.STRING(50),
      cook_time: DataTypes.STRING(50),
      meal_image_url: DataTypes.STRING(255),
      meal_date: DataTypes.DATEONLY
    }, {
      tableName: 'meal_plans',
      timestamps: true,
      createdAt: 'created_at',
      updatedAt: false
    });
  
    return MealPlan;
  };