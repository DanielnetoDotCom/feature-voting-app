const express = require('express');
const { body, param, validationResult } = require('express-validator');
const Feature = require('../models/Feature');

const router = express.Router();

// Validation middleware
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array()
    });
  }
  next();
};

// GET /features - List all features with vote counts
router.get('/', async (req, res) => {
  try {
    const features = await Feature.findAll({
      order: [['votes', 'DESC'], ['createdAt', 'DESC']],
    });
    
    res.json({
      success: true,
      data: features,
      count: features.length
    });
  } catch (error) {
    console.error('Error fetching features:', error);
    res.status(500).json({
      error: 'Failed to fetch features',
      message: error.message
    });
  }
});

// POST /features - Create a new feature
router.post('/',
  [
    body('title')
      .trim()
      .notEmpty()
      .withMessage('Title is required')
      .isLength({ min: 1, max: 255 })
      .withMessage('Title must be between 1 and 255 characters'),
    body('description')
      .optional()
      .trim()
      .isLength({ max: 1000 })
      .withMessage('Description must not exceed 1000 characters'),
  ],
  handleValidationErrors,
  async (req, res) => {
    try {
      const { title, description } = req.body;
      
      const feature = await Feature.create({
        title,
        description: description || null,
        votes: 0
      });
      
      res.status(201).json({
        success: true,
        message: 'Feature created successfully',
        data: feature
      });
    } catch (error) {
      console.error('Error creating feature:', error);
      res.status(500).json({
        error: 'Failed to create feature',
        message: error.message
      });
    }
  }
);

// POST /features/:id/vote - Upvote a feature
router.post('/:id/vote',
  [
    param('id')
      .isInt({ min: 1 })
      .withMessage('Feature ID must be a positive integer'),
  ],
  handleValidationErrors,
  async (req, res) => {
    try {
      const featureId = parseInt(req.params.id);
      
      const feature = await Feature.findByPk(featureId);
      
      if (!feature) {
        return res.status(404).json({
          error: 'Feature not found',
          message: `Feature with ID ${featureId} does not exist`
        });
      }
      
      // Increment the vote count
      feature.votes += 1;
      await feature.save();
      
      res.json({
        success: true,
        message: 'Vote recorded successfully',
        data: feature
      });
    } catch (error) {
      console.error('Error voting for feature:', error);
      res.status(500).json({
        error: 'Failed to record vote',
        message: error.message
      });
    }
  }
);

// GET /features/:id - Get a specific feature (bonus endpoint)
router.get('/:id',
  [
    param('id')
      .isInt({ min: 1 })
      .withMessage('Feature ID must be a positive integer'),
  ],
  handleValidationErrors,
  async (req, res) => {
    try {
      const featureId = parseInt(req.params.id);
      
      const feature = await Feature.findByPk(featureId);
      
      if (!feature) {
        return res.status(404).json({
          error: 'Feature not found',
          message: `Feature with ID ${featureId} does not exist`
        });
      }
      
      res.json({
        success: true,
        data: feature
      });
    } catch (error) {
      console.error('Error fetching feature:', error);
      res.status(500).json({
        error: 'Failed to fetch feature',
        message: error.message
      });
    }
  }
);

module.exports = router;
