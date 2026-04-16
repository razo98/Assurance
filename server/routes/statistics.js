const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Admin = require('../models/Admin');
const Assurance = require('../models/Assurance');
const Reclamation = require('../models/Reclamation');
const { protect, isAdmin, isAdminOrAgent } = require('../middleware/auth');

// GET /api/statistics/dashboard - Statistiques admin
router.get('/dashboard', protect, isAdmin, async (req, res) => {
  try {
    const now = new Date();
    const [
      totalClients, totalAgents,
      totalAssurances, assurancesActives,
      assurancesAttente, assurancesExpirees,
      assurancesResiliees, assurancesSuspendues,
      totalReclamations, reclamationsAttente,
      capitalTotal
    ] = await Promise.all([
      User.countDocuments(),
      Admin.countDocuments({ role: 'agent' }),
      Assurance.countDocuments(),
      Assurance.countDocuments({ status: 'Active' }),
      Assurance.countDocuments({ status: 'En attente' }),
      Assurance.countDocuments({ status: 'Expirée' }),
      Assurance.countDocuments({ status: 'Résiliée' }),
      Assurance.countDocuments({ status: 'Suspendue' }),
      Reclamation.countDocuments(),
      Reclamation.countDocuments({ status: 'En attente' }),
      Assurance.aggregate([{ $group: { _id: null, total: { $sum: '$prix_ttc' } } }])
    ]);

    res.json({
      totalClients,
      totalAgents,
      totalAssurances,
      assurancesActives,
      assurancesAttente,
      assurancesExpirees,
      assurancesResiliees,
      assurancesSuspendues,
      totalReclamations,
      reclamationsAttente,
      capitalTotal: capitalTotal[0]?.total || 0
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/statistics/agent-dashboard
router.get('/agent-dashboard', protect, isAdminOrAgent, async (req, res) => {
  try {
    const filter = req.user.role === 'agent' ? { matricule: req.user.matricule } : {};
    const [total, actives, attente, expirees] = await Promise.all([
      Assurance.countDocuments(filter),
      Assurance.countDocuments({ ...filter, status: 'Active' }),
      Assurance.countDocuments({ ...filter, status: 'En attente' }),
      Assurance.countDocuments({ ...filter, status: 'Expirée' })
    ]);
    res.json({ total, actives, attente, expirees });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/statistics/client-dashboard
router.get('/client-dashboard', protect, async (req, res) => {
  try {
    const filter = { iduser: req.user.id };
    const [total, actives, attente, expirees] = await Promise.all([
      Assurance.countDocuments(filter),
      Assurance.countDocuments({ ...filter, status: 'Active' }),
      Assurance.countDocuments({ ...filter, status: 'En attente' }),
      Assurance.countDocuments({ ...filter, status: 'Expirée' })
    ]);
    res.json({ total, actives, attente, expirees });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/statistics/advanced?dateDebut=&dateFin=&type=agent|categorie|temps
router.get('/advanced', protect, isAdmin, async (req, res) => {
  try {
    const { dateDebut, dateFin, type } = req.query;
    const matchFilter = {};
    if (dateDebut) matchFilter.date_debut = { $gte: new Date(dateDebut) };
    if (dateFin) matchFilter.date_debut = { ...matchFilter.date_debut, $lte: new Date(dateFin) };

    let pipeline = [{ $match: matchFilter }];

    if (type === 'agent') {
      pipeline.push(
        { $group: { _id: '$agents', total: { $sum: 1 }, capital: { $sum: '$prix_ttc' } } },
        { $sort: { total: -1 } }
      );
    } else if (type === 'categorie') {
      pipeline.push(
        { $lookup: { from: 'categories', localField: 'id_categorie', foreignField: '_id', as: 'cat' } },
        { $unwind: { path: '$cat', preserveNullAndEmptyArrays: true } },
        { $group: { _id: '$cat.genre', total: { $sum: 1 }, capital: { $sum: '$prix_ttc' } } },
        { $sort: { total: -1 } }
      );
    } else {
      // Par mois
      pipeline.push(
        { $group: {
          _id: { year: { $year: '$date_debut' }, month: { $month: '$date_debut' } },
          total: { $sum: 1 },
          capital: { $sum: '$prix_ttc' }
        }},
        { $sort: { '_id.year': 1, '_id.month': 1 } }
      );
    }

    const data = await Assurance.aggregate(pipeline);
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
