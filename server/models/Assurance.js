const mongoose = require('mongoose');

const assuranceSchema = new mongoose.Schema({
  iduser:         { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
  id_voiture:     { type: mongoose.Schema.Types.ObjectId, ref: 'Voiture' },
  id_categorie:   { type: mongoose.Schema.Types.ObjectId, ref: 'Categorie' },
  immatriculation:{ type: String, required: true, trim: true },
  quartier:       { type: String, trim: true },
  puissance:      { type: Number },
  nombre_place:   { type: Number },
  energie:        { type: Number, enum: [0, 1] }, // 0=Essence, 1=Gazoil
  nombre_mois:    { type: Number, enum: [3, 6, 12] },
  prix_ht:        { type: Number, default: 0 },
  prix_ttc:       { type: Number, default: 0 },
  date_debut:     { type: Date },
  date_fin:       { type: Date },
  valider:        { type: Boolean, default: false },
  status:         {
    type: String,
    enum: ['En attente', 'Active', 'Expirée', 'Suspendue', 'Résiliée'],
    default: 'En attente'
  },
  agents:         { type: String, default: '' },
  matricule:      { type: String, default: '' }, // matricule de l'agent
  clients:        { type: String, default: '' }, // nom complet du client
  telephone:      { type: String, default: '' },
  mode_paiement:  { type: String, default: '' },
  code_transaction:{ type: String, default: '' },
  resiliation:    { type: Boolean, default: false },
  suspension:     { type: Boolean, default: false },
  nom_assure:     { type: String, default: '' },  // nom tel qu'il figure sur la carte grise
  carte_grise:    { type: String, default: '' }   // chemin vers l'image de la carte grise
}, { timestamps: true });

module.exports = mongoose.model('Assurance', assuranceSchema);
