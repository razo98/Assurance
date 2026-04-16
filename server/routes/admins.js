const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const Admin = require('../models/Admin');
const { protect, isAdmin } = require('../middleware/auth');

// GET /api/admins - Tous les admins/agents
router.get('/', protect, isAdmin, async (req, res) => {
  try {
    const admins = await Admin.find().select('-password').sort({ createdAt: -1 });
    res.json(admins);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/admins/agents - Tous les agents seulement
router.get('/agents', protect, isAdmin, async (req, res) => {
  try {
    const agents = await Admin.find({ role: 'agent' }).select('-password').sort({ createdAt: -1 });
    res.json(agents);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/admins/profile - Profil de l'admin/agent connecté
router.get('/profile', protect, async (req, res) => {
  try {
    const admin = await Admin.findById(req.user.id).select('-password');
    if (!admin) return res.status(404).json({ message: 'Introuvable.' });
    res.json(admin);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/admins/:id
router.get('/:id', protect, isAdmin, async (req, res) => {
  try {
    const admin = await Admin.findById(req.params.id).select('-password');
    if (!admin) return res.status(404).json({ message: 'Introuvable.' });
    res.json(admin);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/admins - Créer un admin ou agent
router.post('/', protect, isAdmin, async (req, res) => {
  try {
    const { firstname, lastname, username, email, number, password, role, quartier } = req.body;
    if (!firstname || !lastname || !username || !email || !number || !password || !role)
      return res.status(400).json({ message: 'Champs obligatoires manquants.' });
    const exists = await Admin.findOne({ $or: [{ username }, { email }] });
    if (exists) return res.status(409).json({ message: 'Nom d\'utilisateur ou email déjà utilisé.' });
    const admin = await Admin.create({ firstname, lastname, username, email, number, password, role, quartier });
    const result = admin.toObject();
    delete result.password;
    res.status(201).json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT /api/admins/:id - Modifier un admin/agent
router.put('/:id', protect, async (req, res) => {
  try {
    if (req.user.role !== 'admin' && req.user.id !== req.params.id)
      return res.status(403).json({ message: 'Accès refusé.' });
    const { firstname, lastname, email, number, password, quartier } = req.body;
    const updateData = { firstname, lastname, email, number, quartier };
    if (password) {
      updateData.password = await bcrypt.hash(password, 12);
    }
    const admin = await Admin.findByIdAndUpdate(req.params.id, updateData, { new: true }).select('-password');
    if (!admin) return res.status(404).json({ message: 'Introuvable.' });
    res.json(admin);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// DELETE /api/admins/:id - Supprimer un admin/agent
router.delete('/:id', protect, isAdmin, async (req, res) => {
  try {
    await Admin.findByIdAndDelete(req.params.id);
    res.json({ message: 'Compte supprimé.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
