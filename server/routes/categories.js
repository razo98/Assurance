const express = require('express');
const router = express.Router();
const Categorie = require('../models/Categorie');
const { protect, isAdmin } = require('../middleware/auth');

// GET /api/categories
router.get('/', async (req, res) => {
  try {
    const categories = await Categorie.find().sort({ genre: 1 });
    res.json(categories);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/categories (admin)
router.post('/', protect, isAdmin, async (req, res) => {
  try {
    const { genre } = req.body;
    if (!genre) return res.status(400).json({ message: 'Genre obligatoire.' });
    const exists = await Categorie.findOne({ genre: { $regex: new RegExp(`^${genre}$`, 'i') } });
    if (exists) return res.status(409).json({ message: 'Catégorie déjà existante.' });
    const cat = await Categorie.create({ genre });
    res.status(201).json(cat);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT /api/categories/:id (admin)
router.put('/:id', protect, isAdmin, async (req, res) => {
  try {
    const cat = await Categorie.findByIdAndUpdate(req.params.id, { genre: req.body.genre }, { new: true });
    if (!cat) return res.status(404).json({ message: 'Catégorie introuvable.' });
    res.json(cat);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// DELETE /api/categories/:id (admin)
router.delete('/:id', protect, isAdmin, async (req, res) => {
  try {
    await Categorie.findByIdAndDelete(req.params.id);
    res.json({ message: 'Catégorie supprimée.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
