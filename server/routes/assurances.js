const express = require('express');
const router = express.Router();
const Assurance = require('../models/Assurance');
const Categorie = require('../models/Categorie');
const Admin = require('../models/Admin');
const { protect, isAdmin, isAdminOrAgent } = require('../middleware/auth');
const { calculerPrixHT } = require('./prix');

// GET /api/assurances
router.get('/', protect, async (req, res) => {
  try {
    let filter = {};
    if (req.user.role === 'client') filter.iduser = req.user.id;
    if (req.user.role === 'agent') filter.matricule = req.user.matricule;

    const assurances = await Assurance.find(filter)
      .populate('iduser', 'firstname lastname email number')
      .populate('id_voiture', 'marque')
      .populate('id_categorie', 'genre')
      .sort({ createdAt: -1 });
    res.json(assurances);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/assurances/attente
router.get('/attente', protect, isAdminOrAgent, async (req, res) => {
  try {
    const filter = { status: 'En attente' };
    if (req.user.role === 'agent') filter.matricule = req.user.matricule;
    const assurances = await Assurance.find(filter)
      .populate('iduser', 'firstname lastname email')
      .populate('id_voiture', 'marque')
      .populate('id_categorie', 'genre')
      .sort({ createdAt: -1 });
    res.json(assurances);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/assurances/:id
router.get('/:id', protect, async (req, res) => {
  try {
    const assurance = await Assurance.findById(req.params.id)
      .populate('iduser', 'firstname lastname email number')
      .populate('id_voiture', 'marque')
      .populate('id_categorie', 'genre');
    if (!assurance) return res.status(404).json({ message: 'Assurance introuvable.' });
    res.json(assurance);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/assurances - Créer une assurance
router.post('/', protect, async (req, res) => {
  try {
    const {
      id_voiture, id_categorie, immatriculation, quartier, puissance,
      nombre_place, energie, nombre_mois, date_debut,
      clients, telephone, mode_paiement, code_transaction,
      valider, prenom_client, nom_client, iduser: bodyIduser
    } = req.body;

    // Calcul du prix
    const cat = await Categorie.findById(id_categorie);
    const genre = cat ? cat.genre : '';
    const prix_ht = calculerPrixHT(genre, parseInt(energie), parseInt(puissance), parseInt(nombre_mois));
    const prix_ttc = Math.round(prix_ht * 1.12 + 300);

    // Date de fin
    const debut = new Date(date_debut);
    const fin = new Date(debut);
    fin.setMonth(fin.getMonth() + parseInt(nombre_mois));

    let agentNom = '';
    let matricule = '';
    let clientNom = clients || '';
    let statusVal = 'En attente';
    let validerBool = false;
    let iduserVal = null;

    if (req.user.role === 'client') {
      // Client crée une assurance → liée à son compte
      iduserVal = req.user.id;
      statusVal = 'En attente';
      validerBool = false;
    } else {
      // Admin ou Agent → crée directement sans compte client
      const adminDoc = await Admin.findById(req.user.id);
      if (adminDoc) {
        agentNom = `${adminDoc.firstname} ${adminDoc.lastname}`;
        matricule = adminDoc.matricule;
      }
      // Nom du client fourni dans le formulaire
      if (prenom_client && nom_client) {
        clientNom = `${prenom_client} ${nom_client}`;
      }
      // Admin/agent peuvent marquer directement comme payé
      validerBool = valider === true || valider === 'true' || valider === 1 || valider === '1';
      statusVal = validerBool ? 'Active' : 'En attente';
      // Peut être lié à un utilisateur ou pas
      iduserVal = bodyIduser || null;
    }

    const assurance = await Assurance.create({
      iduser: iduserVal,
      id_voiture, id_categorie, immatriculation, quartier,
      puissance: parseInt(puissance),
      nombre_place: parseInt(nombre_place),
      energie: parseInt(energie),
      nombre_mois: parseInt(nombre_mois),
      prix_ht, prix_ttc,
      date_debut: debut, date_fin: fin,
      clients: clientNom,
      telephone,
      mode_paiement: mode_paiement || '',
      code_transaction: code_transaction || '',
      agents: agentNom,
      matricule,
      valider: validerBool,
      status: statusVal
    });

    res.status(201).json(assurance);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/assurances/:id/valider
router.post('/:id/valider', protect, isAdminOrAgent, async (req, res) => {
  try {
    const adminDoc = await Admin.findById(req.user.id);
    const updateData = {
      valider: true,
      status: 'Active'
    };
    if (adminDoc) {
      updateData.agents = `${adminDoc.firstname} ${adminDoc.lastname}`;
      updateData.matricule = adminDoc.matricule;
    }
    const assurance = await Assurance.findByIdAndUpdate(req.params.id, updateData, { new: true });
    if (!assurance) return res.status(404).json({ message: 'Assurance introuvable.' });
    res.json(assurance);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/assurances/:id/resilier
router.post('/:id/resilier', protect, isAdminOrAgent, async (req, res) => {
  try {
    const assurance = await Assurance.findByIdAndUpdate(
      req.params.id,
      { resiliation: true, status: 'Résiliée' },
      { new: true }
    );
    if (!assurance) return res.status(404).json({ message: 'Assurance introuvable.' });
    res.json(assurance);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/assurances/:id/suspendre
router.post('/:id/suspendre', protect, isAdminOrAgent, async (req, res) => {
  try {
    const assurance = await Assurance.findByIdAndUpdate(
      req.params.id,
      { suspension: true, status: 'Suspendue' },
      { new: true }
    );
    if (!assurance) return res.status(404).json({ message: 'Assurance introuvable.' });
    res.json(assurance);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/assurances/:id/restaurer
router.post('/:id/restaurer', protect, isAdminOrAgent, async (req, res) => {
  try {
    const assurance = await Assurance.findByIdAndUpdate(
      req.params.id,
      { resiliation: false, suspension: false, status: 'Active' },
      { new: true }
    );
    if (!assurance) return res.status(404).json({ message: 'Assurance introuvable.' });
    res.json(assurance);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/assurances/:id/renouveler
router.post('/:id/renouveler', protect, async (req, res) => {
  try {
    const old = await Assurance.findById(req.params.id).populate('id_categorie', 'genre');
    if (!old) return res.status(404).json({ message: 'Assurance introuvable.' });

    const { nombre_mois, date_debut, mode_paiement, code_transaction } = req.body;
    const newMois = parseInt(nombre_mois || old.nombre_mois);
    const debut = new Date(date_debut || old.date_fin);
    const fin = new Date(debut);
    fin.setMonth(fin.getMonth() + newMois);

    // Recalcul du prix avec la nouvelle durée
    const genre = old.id_categorie ? old.id_categorie.genre : '';
    const new_prix_ht = calculerPrixHT(genre, old.energie, old.puissance, newMois);
    const new_prix_ttc = Math.round(new_prix_ht * 1.12 + 300);

    let agentNom = old.agents;
    let matricule = old.matricule;
    if (req.user.role === 'admin' || req.user.role === 'agent') {
      const adminDoc = await Admin.findById(req.user.id);
      if (adminDoc) {
        agentNom = `${adminDoc.firstname} ${adminDoc.lastname}`;
        matricule = adminDoc.matricule;
      }
    }

    const isClient = req.user.role === 'client';
    const nouvelle = await Assurance.create({
      iduser: old.iduser,
      id_voiture: old.id_voiture,
      id_categorie: old.id_categorie._id || old.id_categorie,
      immatriculation: old.immatriculation,
      quartier: old.quartier,
      puissance: old.puissance,
      nombre_place: old.nombre_place,
      energie: old.energie,
      nombre_mois: newMois,
      prix_ht: new_prix_ht,
      prix_ttc: new_prix_ttc,
      date_debut: debut,
      date_fin: fin,
      clients: old.clients,
      telephone: old.telephone,
      agents: agentNom,
      matricule,
      mode_paiement: mode_paiement || old.mode_paiement || '',
      code_transaction: code_transaction || '',
      valider: !isClient,
      status: isClient ? 'En attente' : 'Active'
    });

    res.status(201).json({ assurance: nouvelle, prix_ttc: new_prix_ttc });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
