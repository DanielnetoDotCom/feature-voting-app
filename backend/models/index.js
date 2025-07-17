const { sequelize } = require('../config/database');
const Feature = require('./Feature');

// Initialize models
const models = {
  Feature,
};

// Set up associations if needed
Object.keys(models).forEach(modelName => {
  if (models[modelName].associate) {
    models[modelName].associate(models);
  }
});

module.exports = {
  ...models,
  sequelize,
};
