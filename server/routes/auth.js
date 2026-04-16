const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Admin = require('../models/Admin');

const signToken = (payload) =>
  jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { username, password, isAdmin } = req.body;
    if (!username || !password)
      return res.status(400).json({ message: 'Champs obligatoires manquants.' });

    if (isAdmin) {
      // Connexion admin ou agent
      const admin = await Admin.findOne({
        $or: [{ username }, { email: username }, { matricule: username }]
      });
      if (!admin) return res.status(401).json({ message: 'Identifiants incorrects.' });
      const match = await admin.comparePassword(password);
      if (!match) return res.status(401).json({ message: 'Mot de passe incorrect.' });

      const token = signToken({
        id: admin._id,
        role: admin.role,
        matricule: admin.matricule,
        firstname: admin.firstname,
        lastname: admin.lastname
      });
      return res.json({
        token,
        user: {
          id: admin._id,
          firstname: admin.firstname,
          lastname: admin.lastname,
          email: admin.email,
          username: admin.username,
          number: admin.number,
          matricule: admin.matricule,
          quartier: admin.quartier,
          role: admin.role
        }
      });
    } else {
      // Connexion client
      const user = await User.findOne({
        $or: [{ username }, { email: username }]
      });
      if (!user) return res.status(401).json({ message: 'Identifiants incorrects.' });
      const match = await user.comparePassword(password);
      if (!match) return res.status(401).json({ message: 'Mot de passe incorrect.' });

      const token = signToken({
        id: user._id,
        role: 'client',
        firstname: user.firstname,
        lastname: user.lastname
      });
      return res.json({
        token,
        user: {
          id: user._id,
          firstname: user.firstname,
          lastname: user.lastname,
          email: user.email,
          username: user.username,
          number: user.number,
          role: 'client'
        }
      });
    }
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur.', error: err.message });
  }
});

// POST /api/auth/register (inscription client)
router.post('/register', async (req, res) => {
  try {
    const { firstname, lastname, username, email, number, password } = req.body;
    if (!firstname || !lastname || !username || !email || !number || !password)
      return res.status(400).json({ message: 'Tous les champs sont obligatoires.' });

    const exists = await User.findOne({ $or: [{ username }, { email }] });
    if (exists) return res.status(409).json({ message: 'Nom d\'utilisateur ou email déjà utilisé.' });

    const user = await User.create({ firstname, lastname, username, email, number, password });
    const token = signToken({ id: user._id, role: 'client', firstname: user.firstname, lastname: user.lastname });

    res.status(201).json({
      token,
      user: {
        id: user._id,
        firstname: user.firstname,
        lastname: user.lastname,
        email: user.email,
        username: user.username,
        number: user.number,
        role: 'client'
      }
    });
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur.', error: err.message });
  }
});

module.exports = router;
