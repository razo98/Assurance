# MBA Niger SA - Démarrage du projet React + Node.js + MongoDB Atlas

## Structure du projet
```
assurance/
├── server/     ← API Node.js (Express + MongoDB Atlas)
└── client/     ← Application React (Vite)
```

## ÉTAPE 1 : Autoriser votre IP sur MongoDB Atlas

1. Allez sur https://cloud.mongodb.com
2. Connectez-vous → choisissez votre projet "assurance"
3. Dans le menu gauche → **Network Access**
4. Cliquez **+ ADD IP ADDRESS**
5. Choisissez **ADD CURRENT IP ADDRESS** (ou entrez 0.0.0.0/0 pour tout autoriser)
6. Cliquez **Confirm**

## ÉTAPE 2 : Créer l'admin et les données initiales

```bash
cd server
node seed/seedAdmin.js
```

Cela crée :
- Un admin avec username: `admin`, mot de passe: `Admin@2024`, matricule: `ADM00001`
- Les catégories d'assurance (VP, Moto, Taxi, etc.)
- Les marques de voitures courantes

## ÉTAPE 3 : Démarrer les serveurs

### Terminal 1 - Démarrer le serveur API (port 5000)
```bash
cd server
npm run dev
```

### Terminal 2 - Démarrer l'application React (port 5173)
```bash
cd client
npm run dev
```

## ÉTAPE 4 : Accéder à l'application

Ouvrez votre navigateur sur : http://localhost:5173

## Connexion Admin
- **Username** : admin
- **Mot de passe** : Admin@2024
- **Matricule** : ADM00001
- Cocher "Je suis un administrateur / agent"

## Comptes de test

### Client
Inscrivez-vous directement via le formulaire d'inscription.

### Agent
Créez un agent depuis le panneau admin → Gestion des agents.

## Variables d'environnement (server/.env)

```
PORT=5000
MONGODB_URI=mongodb+srv://abdoulrazaksouleye:Razak19981@assurance.v875wrs.mongodb.net/assurance?appName=assurance
JWT_SECRET=mba_niger_assurance_jwt_secret_key_2024_secure
NODE_ENV=development
```

## Technologies utilisées
- **Frontend** : React 18 + Vite + React Router + Axios + Chart.js + Bootstrap 5
- **Backend** : Node.js + Express.js + Mongoose
- **Base de données** : MongoDB Atlas
- **Auth** : JWT (JSON Web Tokens) + bcryptjs
