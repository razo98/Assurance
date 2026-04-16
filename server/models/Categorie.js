const mongoose = require('mongoose');

const categorieSchema = new mongoose.Schema({
  genre: { type: String, required: true, trim: true, unique: true }
}, { timestamps: true });

module.exports = mongoose.model('Categorie', categorieSchema);
