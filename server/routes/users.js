const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const { protect, isAdmin } = require('../middleware/auth');

// GET /api/users - Tous les clients (admin seulement)
router.get('/', protect, isAdmin, async (req, res) => {
  try {
    const users = await User.find().select('-password').sort({ createdAt: -1 });
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/users/profile - Profil connecté (client)
router.get('/profile', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) return res.status(404).json({ message: 'Utilisateur introuvable.' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/users/:id - Un client (admin ou lui-même)
router.get('/:id', protect, async (req, res) => {
  try {
    if (req.user.role !== 'admin' && req.user.id !== req.params.id)
      return res.status(403).json({ message: 'Accès refusé.' });
    const user = await User.findById(req.params.id).select('-password');
    if (!user) return res.status(404).json({ message: 'Client introuvable.' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT /api/users/:id - Modifier un client
router.put('/:id', protect, async (req, res) => {
  try {
    if (req.user.role !== 'admin' && req.user.id !== req.params.id)
      return res.status(403).json({ message: 'Accès refusé.' });
    const { firstname, lastname, email, number, password } = req.body;
    const updateData = { firstname, lastname, email, number };
    if (password) {
      updateData.password = await bcrypt.hash(password, 12);
    }
    const user = await User.findByIdAndUpdate(req.params.id, updateData, { new: true }).select('-password');
    if (!user) return res.status(404).json({ message: 'Client introuvable.' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// DELETE /api/users/:id - Supprimer un client (admin)
router.delete('/:id', protect, isAdmin, async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.json({ message: 'Client supprimé.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/users - Créer un client (admin)
router.post('/', protect, isAdmin, async (req, res) => {
  try {
    const { firstname, lastname, username, email, number, password } = req.body;
    const exists = await User.findOne({ $or: [{ username }, { email }] });
    if (exists) return res.status(409).json({ message: 'Nom d\'utilisateur ou email déjà utilisé.' });
    const user = await User.create({ firstname, lastname, username, email, number, password });
    res.status(201).json({ ...user.toObject(), password: undefined });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
