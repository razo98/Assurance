const express = require('express');
const router = express.Router();

// Tarifs par catégorie, durée, puissance et énergie
// Reproduit fidèlement la logique de calculprix.jsp
function calculerPrixHT(genre, energie, puissance, nombre_mois) {
  const g = genre.toLowerCase().replace(/ /g, '_');
  let prix_ht = 0;

  if (g === 'vp') {
    if (nombre_mois === 3) {
      if ((energie === 0 && puissance >= 3 && puissance <= 6) || (energie === 1 && puissance >= 2 && puissance <= 4)) prix_ht = 13080;
      else if ((energie === 0 && puissance >= 7 && puissance <= 10) || (energie === 1 && puissance >= 5 && puissance <= 7)) prix_ht = 14852;
      else if ((energie === 0 && puissance >= 11 && puissance <= 14) || (energie === 1 && puissance >= 8 && puissance <= 10)) prix_ht = 19195;
      else if ((energie === 0 && puissance >= 15 && puissance <= 23) || (energie === 1 && puissance >= 11 && puissance <= 16)) prix_ht = 25483;
      else if ((energie === 0 && puissance >= 23) || (energie === 1 && puissance >= 17)) prix_ht = 31066;
    } else if (nombre_mois === 6) {
      if ((energie === 0 && puissance >= 3 && puissance <= 6) || (energie === 1 && puissance >= 2 && puissance <= 4)) prix_ht = 25660;
      else if ((energie === 0 && puissance >= 7 && puissance <= 10) || (energie === 1 && puissance >= 5 && puissance <= 7)) prix_ht = 29204;
      else if ((energie === 0 && puissance >= 11 && puissance <= 14) || (energie === 1 && puissance >= 8 && puissance <= 10)) prix_ht = 37890;
      else if ((energie === 0 && puissance >= 15 && puissance <= 23) || (energie === 1 && puissance >= 11 && puissance <= 16)) prix_ht = 50466;
      else if ((energie === 0 && puissance >= 23) || (energie === 1 && puissance >= 17)) prix_ht = 61633;
    } else if (nombre_mois === 12) {
      if ((energie === 0 && puissance >= 3 && puissance <= 6) || (energie === 1 && puissance >= 2 && puissance <= 4)) prix_ht = 42433;
      else if ((energie === 0 && puissance >= 7 && puissance <= 10) || (energie === 1 && puissance >= 5 && puissance <= 7)) prix_ht = 48340;
      else if ((energie === 0 && puissance >= 11 && puissance <= 14) || (energie === 1 && puissance >= 8 && puissance <= 10)) prix_ht = 62817;
      else if ((energie === 0 && puissance >= 15 && puissance <= 23) || (energie === 1 && puissance >= 11 && puissance <= 16)) prix_ht = 83777;
      else if ((energie === 0 && puissance >= 23) || (energie === 1 && puissance >= 17)) prix_ht = 102388;
    }
  } else if (g === 'moto') {
    if (nombre_mois === 3) {
      if (puissance === 0) prix_ht = 4044;
      else if (puissance === 1) prix_ht = 7588;
      else if (puissance >= 2 && puissance <= 3) prix_ht = 13789;
    } else if (nombre_mois === 6) {
      if (puissance === 0) prix_ht = 7587;
      else if (puissance === 1) prix_ht = 14675;
      else if (puissance >= 2 && puissance <= 3) prix_ht = 27078;
    } else if (nombre_mois === 12) {
      if (puissance === 0) prix_ht = 12312;
      else if (puissance === 1) prix_ht = 24125;
      else if (puissance >= 2 && puissance <= 3) prix_ht = 44796;
    }
  } else if (g === 'taxiville_4p') {
    if (nombre_mois === 3) {
      if ((energie === 0 && puissance >= 3 && puissance <= 6) || (energie === 1 && puissance >= 2 && puissance <= 4)) prix_ht = 28834;
      else if ((energie === 0 && puissance >= 7 && puissance <= 10) || (energie === 1 && puissance >= 5 && puissance <= 7)) prix_ht = 34138;
      else if ((energie === 0 && puissance >= 11 && puissance <= 14) || (energie === 1 && puissance >= 8 && puissance <= 10)) prix_ht = 48313;
    } else if (nombre_mois === 6) {
      if ((energie === 0 && puissance >= 3 && puissance <= 6) || (energie === 1 && puissance >= 2 && puissance <= 4)) prix_ht = 57667;
      else if ((energie === 0 && puissance >= 7 && puissance <= 10) || (energie === 1 && puissance >= 5 && puissance <= 7)) prix_ht = 67775;
      else if ((energie === 0 && puissance >= 11 && puissance <= 14) || (energie === 1 && puissance >= 8 && puissance <= 10)) prix_ht = 96125;
    } else if (nombre_mois === 12) {
      if ((energie === 0 && puissance >= 3 && puissance <= 6) || (energie === 1 && puissance >= 2 && puissance <= 4)) prix_ht = 71389;
      else if ((energie === 0 && puissance >= 7 && puissance <= 10) || (energie === 1 && puissance >= 5 && puissance <= 7)) prix_ht = 84200;
      else if ((energie === 0 && puissance >= 11 && puissance <= 14) || (energie === 1 && puissance >= 8 && puissance <= 10)) prix_ht = 122000;
    }
  } else if (g === 'taxiville_19p') {
    if (nombre_mois === 3) {
      if ((energie === 0 && puissance >= 7 && puissance <= 10) || (energie === 1 && puissance >= 5 && puissance <= 7)) prix_ht = 67834;
      else if ((energie === 0 && puissance >= 11 && puissance <= 14) || (energie === 1 && puissance >= 8 && puissance <= 10)) prix_ht = 82063;
    } else if (nombre_mois === 6) {
      if ((energie === 0 && puissance >= 7 && puissance <= 10) || (energie === 1 && puissance >= 5 && puissance <= 7)) prix_ht = 135275;
      else if ((energie === 0 && puissance >= 11 && puissance <= 14) || (energie === 1 && puissance >= 8 && puissance <= 10)) prix_ht = 163625;
    } else if (nombre_mois === 12) {
      if ((energie === 0 && puissance >= 7 && puissance <= 10) || (energie === 1 && puissance >= 5 && puissance <= 7)) prix_ht = 186200;
      else if ((energie === 0 && puissance >= 11 && puissance <= 14) || (energie === 1 && puissance >= 8 && puissance <= 10)) prix_ht = 218000;
    }
  }

  return prix_ht;
}

// GET /api/prix/calculer?genre=vp&energie=0&puissance=7&nombre_mois=12
router.get('/calculer', (req, res) => {
  try {
    const { genre, energie, puissance, nombre_mois } = req.query;
    if (!genre || energie === undefined || !puissance || !nombre_mois)
      return res.status(400).json({ success: false, message: 'Paramètres manquants.', prix: 0 });

    const e = parseInt(energie);
    const p = parseInt(puissance);
    const m = parseInt(nombre_mois);

    const prix_ht = calculerPrixHT(genre, e, p, m);

    if (prix_ht <= 0)
      return res.json({ success: false, message: `Aucun tarif pour: genre=${genre}, puissance=${p}, énergie=${e}, durée=${m}mois`, prix: 0 });

    // TVA 12% + 300 FCFA
    const prix_ttc = Math.round(prix_ht * 1.12 + 300);
    res.json({ success: true, message: 'Prix calculé avec succès.', prix: prix_ttc, prix_ht });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message, prix: 0 });
  }
});

module.exports = router;
module.exports.calculerPrixHT = calculerPrixHT;
