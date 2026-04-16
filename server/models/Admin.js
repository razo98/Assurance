const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const adminSchema = new mongoose.Schema({
  firstname:  { type: String, required: true, trim: true },
  lastname:   { type: String, required: true, trim: true },
  username:   { type: String, required: true, unique: true, trim: true },
  email:      { type: String, required: true, unique: true, trim: true, lowercase: true },
  number:     { type: String, required: true, trim: true },
  password:   { type: String, required: true },
  matricule:  { type: String, unique: true, trim: true },
  // role: 'admin' (ancien soleil) ou 'agent' (ancien lune)
  role:       { type: String, enum: ['admin', 'agent'], required: true },
  quartier:   { type: String, trim: true, default: '' }
}, { timestamps: true });

// Auto-génération du matricule avant sauvegarde
adminSchema.pre('save', async function(next) {
  if (this.isNew && !this.matricule) {
    const count = await this.constructor.countDocuments();
    const num = String(count + 1).padStart(5, '0');
    this.matricule = `ADM${num}`;
  }
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

adminSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('Admin', adminSchema);
