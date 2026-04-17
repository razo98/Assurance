const express = require('express');
const router = express.Router();
const multer = require('multer');
const Anthropic = require('@anthropic-ai/sdk');

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
  fileFilter: (req, file, cb) => {
    if (!file.mimetype.startsWith('image/')) {
      return cb(new Error('Seules les images sont acceptées.'));
    }
    cb(null, true);
  }
});

// POST /api/ocr/carte-grise
router.post('/carte-grise', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: 'Aucune image fournie.' });

    const apiKey = process.env.ANTHROPIC_API_KEY;
    if (!apiKey || apiKey === 'your_anthropic_api_key_here') {
      return res.status(503).json({ message: 'Clé API Anthropic non configurée. Ajoutez ANTHROPIC_API_KEY dans le fichier .env du serveur.' });
    }

    const anthropic = new Anthropic({ apiKey });

    const base64 = req.file.buffer.toString('base64');
    const mediaType = req.file.mimetype; // image/jpeg, image/png, image/webp

    const message = await anthropic.messages.create({
      model: 'claude-opus-4-6',
      max_tokens: 1024,
      messages: [{
        role: 'user',
        content: [
          {
            type: 'image',
            source: { type: 'base64', media_type: mediaType, data: base64 }
          },
          {
            type: 'text',
            text: `Tu es un expert en lecture de cartes grises de véhicules (certificats d'immatriculation).
Analyse cette image de carte grise et extrais les informations suivantes.
Retourne UNIQUEMENT un objet JSON valide, sans texte autour.

Champs à extraire :
{
  "immatriculation": "numéro d'immatriculation complet (ex: NI-1234-AB ou AB-123-CD)",
  "marque": "marque du véhicule (ex: Toyota, Honda, Peugeot)",
  "modele": "modèle/dénomination commerciale",
  "puissance": <nombre entier, puissance fiscale en CV - champ P.6 ou puissance administrative>,
  "energie": <0 si Essence/Petrol/SP, 1 si Gazoil/Diesel/GO>,
  "nombre_place": <nombre entier de places assises - champ S.1>,
  "vin": "numéro de châssis/VIN (champ E)",
  "date_mise_circulation": "date première mise en circulation (format JJ/MM/AAAA - champ B)"
}

Si un champ n'est pas visible ou lisible, mets null.
Ne retourne que le JSON, rien d'autre.`
          }
        ]
      }]
    });

    const text = message.content[0].text.trim();

    // Extraire le JSON de la réponse
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      return res.status(422).json({ message: 'Impossible de lire les données de la carte grise. Vérifiez la qualité de l\'image.' });
    }

    const data = JSON.parse(jsonMatch[0]);

    // Normaliser les valeurs numériques
    if (data.puissance !== null && data.puissance !== undefined) {
      data.puissance = parseInt(data.puissance) || null;
    }
    if (data.nombre_place !== null && data.nombre_place !== undefined) {
      data.nombre_place = parseInt(data.nombre_place) || null;
    }
    if (data.energie !== null && data.energie !== undefined) {
      data.energie = parseInt(data.energie);
    }

    res.json({ success: true, data });

  } catch (err) {
    console.error('OCR Error:', err.message);
    if (err.message.includes('Could not process image')) {
      return res.status(422).json({ message: 'Image illisible. Essayez avec une photo plus nette et mieux éclairée.' });
    }
    res.status(500).json({ message: err.message || 'Erreur lors de l\'analyse de la carte grise.' });
  }
});

module.exports = router;
