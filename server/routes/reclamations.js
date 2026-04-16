const express = require('express');
const router = express.Router();
const Reclamation = require('../models/Reclamation');
const { protect, isAdmin, isAdminOrAgent } = require('../middleware/auth');

// GET /api/reclamations
router.get('/', protect, async (req, res) => {
  try {
    let filter = {};
    if (req.user.role === 'client') filter.iduser = req.user.id;
    const reclamations = await Reclamation.find(filter)
      .populate('iduser', 'firstname lastname email')
      .populate('id_assurance', 'immatriculation status')
      .sort({ createdAt: -1 });
    res.json(reclamations);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/reclamations/:id
router.get('/:id', protect, async (req, res) => {
  try {
    const r = await Reclamation.findById(req.params.id)
      .populate('iduser', 'firstname lastname email')
      .populate('id_assurance', 'immatriculation status');
    if (!r) return res.status(404).json({ message: 'Réclamation introuvable.' });
    res.json(r);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/reclamations - Soumettre une réclamation (client)
router.post('/', protect, async (req, res) => {
  try {
    const { id_assurance, type, description } = req.body;
    if (!type || !description) return res.status(400).json({ message: 'Type et description obligatoires.' });
    const r = await Reclamation.create({
      iduser: req.user.id,
      id_assurance,
      type,
      description
    });
    res.status(201).json(r);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT /api/reclamations/:id - Traiter une réclamation (admin/agent)
router.put('/:id', protect, isAdminOrAgent, async (req, res) => {
  try {
    const { status, reponse } = req.body;
    const r = await Reclamation.findByIdAndUpdate(
      req.params.id,
      { status, reponse },
      { new: true }
    );
    if (!r) return res.status(404).json({ message: 'Réclamation introuvable.' });
    res.json(r);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
