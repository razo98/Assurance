const mongoose = require('mongoose');

const voitureSchema = new mongoose.Schema({
  marque: { type: String, required: true, trim: true, unique: true }
}, { timestamps: true });

module.exports = mongoose.model('Voiture', voitureSchema);
