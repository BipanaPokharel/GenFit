const { DataTypes } = require("sequelize");
const { sequelize } = require("../config/dbINIT");
const bcrypt = require("bcryptjs");

const User = sequelize.define(
  "User",
  {
    user_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    username: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        len: [3, 30]
      }
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true
      }
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    profile_pic: {
      type: DataTypes.STRING,
      get() {
        const rawValue = this.getDataValue('profile_pic');
        return rawValue ? `${process.env.BASE_URL}${rawValue}` : null;
      }
    },
    settings: {
      type: DataTypes.JSON,
      defaultValue: {
        theme: 'light',
        emailNotifications: true,
        pushNotifications: true
      }
    }
  },
  {
    tableName: "User",
    timestamps: false, 
    hooks: {
      beforeSave: async (user) => {
        if (user.changed('password')) {
          user.password = await bcrypt.hash(user.password, 10);
        }
      }
    }
  }
);

// Associations
User.associate = function(models) {
  User.hasMany(models.Post, { foreignKey: 'user_id', onDelete: 'CASCADE' });
  User.hasMany(models.Comment, { foreignKey: 'user_id', onDelete: 'CASCADE' });
  User.hasMany(models.Reaction, { foreignKey: 'user_id', onDelete: 'CASCADE' });
};

module.exports = User;