const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

async function test() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ MongoDB connecté\n');

    const Admin = require('./models/Admin');

    // 1. Chercher l'admin
    const admin = await Admin.findOne({ username: 'admin' });
    if (!admin) {
      console.log('❌ Admin introuvable en base de données!');
      console.log('   → Lance: node seed/seedAdmin.js');
      process.exit(1);
    }

    console.log('✅ Admin trouvé:');
    console.log('   Username :', admin.username);
    console.log('   Email    :', admin.email);
    console.log('   Matricule:', admin.matricule);
    console.log('   Role     :', admin.role);
    console.log('   Password hash:', admin.password.substring(0, 20) + '...');

    // 2. Tester le mot de passe
    const match = await bcrypt.compare('Admin@2024', admin.password);
    console.log('\n' + (match ? '✅' : '❌') + ' Comparaison mot de passe "Admin@2024":', match);

    if (!match) {
      console.log('\n🔧 Réinitialisation du mot de passe...');
      admin.password = await bcrypt.hash('Admin@2024', 12);
      await admin.save({ validateBeforeSave: false });
      // verify
      const updated = await Admin.findOne({ username: 'admin' });
      const match2 = await bcrypt.compare('Admin@2024', updated.password);
      console.log('✅ Nouveau hash testé:', match2);
    }

    console.log('\n━━━━━━━━━━━━━━━━━━━━');
    console.log('Résultat: tout est OK, tu peux te connecter avec:');
    console.log('  username : admin');
    console.log('  password : Admin@2024');
    console.log('  checkbox : ✅ coché (administrateur)');

  } catch (err) {
    console.error('❌ Erreur:', err.message);
  } finally {
    await mongoose.disconnect();
  }
}

test();
