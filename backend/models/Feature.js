const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Feature = sequelize.define('Feature', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
    validate: {
      notEmpty: true,
      len: [1, 255],
    },
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  votes: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    validate: {
      min: 0,
    },
  },
}, {
  tableName: 'features',
  indexes: [
    {
      fields: ['votes'],
    },
  ],
});

module.exports = Feature;
