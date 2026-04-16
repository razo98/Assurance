const express = require('express');
const router = express.Router();
const Voiture = require('../models/Voiture');
const { protect, isAdmin } = require('../middleware/auth');

// GET /api/voitures - Toutes les marques
router.get('/', async (req, res) => {
  try {
    const voitures = await Voiture.find().sort({ marque: 1 });
    res.json(voitures);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/voitures - Ajouter une marque
router.post('/', protect, async (req, res) => {
  try {
    const { marque } = req.body;
    if (!marque) return res.status(400).json({ message: 'Marque obligatoire.' });
    const exists = await Voiture.findOne({ marque: { $regex: new RegExp(`^${marque}$`, 'i') } });
    if (exists) return res.status(409).json({ message: 'Marque déjà existante.' });
    const voiture = await Voiture.create({ marque });
    res.status(201).json(voiture);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT /api/voitures/:id - Modifier une marque (admin)
router.put('/:id', protect, isAdmin, async (req, res) => {
  try {
    const voiture = await Voiture.findByIdAndUpdate(req.params.id, { marque: req.body.marque }, { new: true });
    if (!voiture) return res.status(404).json({ message: 'Marque introuvable.' });
    res.json(voiture);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// DELETE /api/voitures/:id - Supprimer une marque (admin)
router.delete('/:id', protect, isAdmin, async (req, res) => {
  try {
    await Voiture.findByIdAndDelete(req.params.id);
    res.json({ message: 'Marque supprimée.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
