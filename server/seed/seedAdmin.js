const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '../.env') });

const Admin = require('../models/Admin');
const Categorie = require('../models/Categorie');
const Voiture = require('../models/Voiture');

const categories = [
  { genre: 'VP' },
  { genre: 'Taxiville_4p' },
  { genre: 'Taxibrousse' },
  { genre: 'Camionmarchand' },
  { genre: 'Vehiculeutilitaire' },
  { genre: 'Taxiville_19p' },
  { genre: 'Moto' }
];

const voitures = [
  'Toyota', 'Nissan', 'Renault', 'Peugeot', 'Mercedes', 'BMW',
  'Honda', 'Hyundai', 'Kia', 'Ford', 'Volkswagen', 'Mitsubishi',
  'Suzuki', 'Mazda', 'Isuzu', 'Land Rover', 'Chevrolet', 'Fiat'
];

async function seed() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connecté à MongoDB Atlas');

    // Créer l'admin
    const existingAdmin = await Admin.findOne({ username: 'admin' });
    if (!existingAdmin) {
      const admin = await Admin.create({
        firstname: 'Admin',
        lastname: 'MBA Niger',
        username: 'admin',
        email: 'admin@mbaniger.com',
        number: '+22799897842',
        password: 'Admin@2024',
        role: 'admin',
        matricule: 'ADM00001',
        quartier: 'Plateau'
      });
      console.log('✅ Admin créé:');
      console.log('   Matricule :', admin.matricule);
      console.log('   Username  :', admin.username);
      console.log('   Email     :', admin.email);
      console.log('   Mot de passe: Admin@2024');
    } else {
      console.log('ℹ️  Admin déjà existant (username: admin)');
    }

    // Créer les catégories
    for (const cat of categories) {
      const exists = await Categorie.findOne({ genre: { $regex: new RegExp(`^${cat.genre}$`, 'i') } });
      if (!exists) {
        await Categorie.create(cat);
        console.log(`✅ Catégorie créée: ${cat.genre}`);
      }
    }

    // Créer les marques de voiture
    for (const marque of voitures) {
      const exists = await Voiture.findOne({ marque: { $regex: new RegExp(`^${marque}$`, 'i') } });
      if (!exists) {
        await Voiture.create({ marque });
        console.log(`✅ Marque créée: ${marque}`);
      }
    }

    console.log('\n🎉 Seed terminé avec succès!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('CONNEXION ADMIN:');
    console.log('  Username    : admin');
    console.log('  Mot de passe: Admin@2024');
    console.log('  Matricule   : ADM00001');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    process.exit(0);
  } catch (err) {
    console.error('❌ Erreur:', err.message);
    process.exit(1);
  }
}

seed();
