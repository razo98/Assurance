const mongoose = require('mongoose');

const reclamationSchema = new mongoose.Schema({
  iduser:        { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  id_assurance:  { type: mongoose.Schema.Types.ObjectId, ref: 'Assurance' },
  type:          { type: String, required: true, trim: true },
  description:   { type: String, required: true, trim: true },
  status:        {
    type: String,
    enum: ['En attente', 'Approuvée', 'Rejetée'],
    default: 'En attente'
  },
  reponse:       { type: String, default: '' }
}, { timestamps: true });

module.exports = mongoose.model('Reclamation', reclamationSchema);
