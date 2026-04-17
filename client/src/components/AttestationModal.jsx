import { useRef } from 'react';

export default function AttestationModal({ assurance: a, onClose }) {
  const cardRef = useRef();

  const fmt = d => d ? new Date(d).toLocaleDateString('fr-FR') : '--/--/----';
  const policeNum = `NC/${new Date(a.date_debut || Date.now()).getFullYear()}/MBA`;
  const assureNum = `NC ${a._id?.slice(-6).toUpperCase()}`;
  const attestNum = a._id?.slice(-7).toUpperCase();
  const heureEffet = a.createdAt ? new Date(a.createdAt).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }) : '00:00';

  const handlePrint = () => {
    const win = window.open('', '_blank', 'width=900,height=700');
    win.document.write(`<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8"/>
  <title>Attestation — ${a.immatriculation}</title>
  <style>
    @page { size: A5 landscape; margin: 8mm; }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Arial, sans-serif; background: white; }
    .attest-card {
      background: #FFD600;
      border: 3px solid #111;
      padding: 10px 14px;
      width: 100%;
      min-height: 190mm;
      position: relative;
    }
    .attest-inner { border: 1.5px solid #111; padding: 8px 10px; height: 100%; }
    .top-row { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 10px; gap: 10px; }
    .company-info { font-size: 10px; line-height: 1.5; max-width: 220px; }
    .company-info strong { font-size: 11.5px; display: block; text-transform: uppercase; }
    .right-header { text-align: right; min-width: 260px; }
    .logo-box { display: inline-flex; align-items: center; gap: 6px; border: 2px solid #111; padding: 4px 8px; margin-bottom: 6px; background: white; }
    .logo-box img { width: 40px; height: 40px; object-fit: contain; }
    .logo-box span { font-size: 9px; font-weight: 700; color: #006652; line-height: 1.3; }
    .logo-box .niger { color: #e30000; font-size: 10px; font-weight: 900; }
    .repub { font-size: 9px; font-style: italic; text-align: right; display: block; margin-bottom: 4px; }
    .attest-title { border: 2px solid #111; padding: 5px 10px; display: inline-block; text-align: center; }
    .attest-title strong { font-size: 13px; font-weight: 900; display: block; text-transform: uppercase; }
    .attest-title small { font-size: 8.5px; display: block; }
    .attest-num { font-size: 18px; font-weight: 900; margin-top: 4px; letter-spacing: 1px; }
    .divider { border-top: 1.5px solid #111; margin: 8px 0; }
    .fields-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 4px 20px; margin-bottom: 8px; }
    .field-row { display: flex; flex-direction: column; border-bottom: 1px solid #555; padding-bottom: 2px; margin-bottom: 4px; }
    .field-label { font-size: 8.5px; font-weight: 700; text-transform: uppercase; color: #333; }
    .field-value { font-size: 11px; font-weight: 700; min-height: 14px; }
    .row-full { grid-column: 1/-1; }
    .remorque-row { display: flex; gap: 20px; font-size: 9px; font-weight: 700; }
    .remorque-row span { display: flex; align-items: center; gap: 4px; }
    .checkbox { width: 10px; height: 10px; border: 1.5px solid #111; display: inline-block; }
    .valid-row { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; font-size: 10px; margin-top: 6px; }
    .valid-row strong { font-size: 12px; }
    .underline { border-bottom: 1.5px solid #111; min-width: 80px; display: inline-block; padding: 0 4px; font-weight: 900; font-size: 12px; }
    .visa-row { font-size: 9.5px; margin-top: 6px; font-weight: 700; }
    .effet-row { display: flex; justify-content: space-between; align-items: flex-end; margin-top: 8px; }
    .effet-left { font-size: 10px; }
    .effet-left strong { font-size: 12px; }
    .pour-cie { font-size: 11px; font-weight: 900; text-transform: uppercase; border: 1.5px solid #111; padding: 4px 10px; }
    .note-box { border: 1.5px solid #111; padding: 5px 8px; font-size: 8px; margin-top: 8px; line-height: 1.5; background: rgba(255,255,255,0.3); }
    .footer-countries { font-size: 7.5px; margin-top: 6px; border-top: 1px solid #111; padding-top: 4px; }
    .footer-countries strong { font-size: 8px; }
  </style>
</head>
<body>
<div class="attest-card">
  <div class="attest-inner">

    <div class="top-row">
      <div class="company-info">
        <strong>MUTUAL BENEFITS</strong>
        <strong>ASSURANCE NIGER S.A</strong>
        <br/>
        <strong>SIÈGE SOCIAL :</strong><br/>
        Boulevard Tanimoune,<br/>
        quartier Bobiel, Niamey<br/>
        BP : 11924<br/>
        Tél : +227 88 88 81 11<br/>
        Email : info@mbaniger.com
      </div>

      <div class="right-header">
        <span class="repub">République du Niger</span>
        <div class="logo-box">
          <img src="/logo.jpg" alt="MBA"/>
          <div>
            <span>MBA</span><br/>
            <span class="niger">NIGER</span>
          </div>
        </div>
        <div class="attest-title">
          <strong>ATTESTATION D'ASSURANCE</strong>
          <small>(Article 214 du Code CIMA) N°</small>
          <div class="attest-num">${attestNum}</div>
        </div>
      </div>
    </div>

    <div class="divider"></div>

    <div class="fields-grid">
      <div class="field-row">
        <span class="field-label">N° de Police</span>
        <span class="field-value">${policeNum}</span>
      </div>
      <div class="field-row">
        <span class="field-label">N° Assuré</span>
        <span class="field-value">${assureNum}</span>
      </div>
      <div class="field-row row-full">
        <span class="field-label">Souscripteur</span>
        <span class="field-value">${a.clients || '-'}</span>
      </div>
      <div class="field-row row-full">
        <span class="field-label">Adresse</span>
        <span class="field-value">${a.quartier || 'Niamey, Niger'}</span>
      </div>

      <div class="field-row">
        <span class="field-label">Véhicule Genre</span>
        <span class="field-value">${a.id_categorie?.genre || '-'}</span>
      </div>
      <div class="field-row">
        <span class="field-label">Marque</span>
        <span class="field-value">${a.id_voiture?.marque || '-'}</span>
      </div>

      <div class="field-row row-full">
        <span class="field-label">Remorque</span>
        <div class="remorque-row">
          <span><span class="checkbox"></span> Semi-remorque</span>
          <span><span class="checkbox"></span> Appareil terrestre</span>
          <span style="margin-left:auto;">Marque : &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
        </div>
      </div>

      <div class="field-row">
        <span class="field-label">N° d'immatriculation <sup>(1)</sup></span>
        <span class="field-value">${a.immatriculation}</span>
      </div>
      <div class="field-row">
        <span class="field-label">N° d'immatriculation <sup>(2)</sup></span>
        <span class="field-value">&nbsp;</span>
      </div>
      <div class="field-row row-full">
        <span class="field-label">Profession <sup>(1)</sup></span>
        <span class="field-value">&nbsp;</span>
      </div>
    </div>

    <div class="valid-row">
      <strong>Valable du</strong>
      <span class="underline">${fmt(a.date_debut)}</span>
      <strong>au</strong>
      <span class="underline">${fmt(a.date_fin)}</span>
    </div>

    <div class="visa-row">
      Visa ministériel N° 2334 du 25 mai 1998
    </div>

    <div class="effet-row">
      <div class="effet-left">
        Prise d'effet le <strong class="underline">${fmt(a.date_debut)}</strong>
        &nbsp; à &nbsp; <strong class="underline">${heureEffet}</strong>
      </div>
      <div class="pour-cie">POUR LA COMPAGNIE</div>
    </div>

    <div class="note-box">
      <sup>(1)-(2)</sup> (voir VERSO)<br/>
      Sa présentation n'implique, selon les dispositions des Articles 213 et 215 du Code CIMA, qu'une présomption de garantie à la charge de l'assureur.
    </div>

    <div class="footer-countries">
      <strong>Valable dans les États suivants :</strong> Niger, Bénin, Burkina Faso, Cameroun, Centrafrique, Comores, Congo Brazzaville, Côte d'Ivoire, Gabon, Guinée Équatoriale, Mali, Sénégal, Tchad, Togo
    </div>

  </div>
</div>
<script>window.onload = () => { window.print(); }</script>
</body>
</html>`);
    win.document.close();
  };

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.7)', zIndex: 4000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20, backdropFilter: 'blur(4px)' }}>
      <div style={{ background: 'white', borderRadius: 16, width: '100%', maxWidth: 820, maxHeight: '95vh', display: 'flex', flexDirection: 'column', boxShadow: '0 30px 80px rgba(0,0,0,0.4)', animation: 'scaleIn 0.28s ease' }}>

        {/* Header */}
        <div style={{ background: 'linear-gradient(to right, #004d3d, #006652)', color: 'white', padding: '16px 24px', borderRadius: '16px 16px 0 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexShrink: 0 }}>
          <div>
            <div style={{ fontWeight: 800, fontSize: 17 }}>Attestation d'assurance</div>
            <div style={{ fontSize: 12, opacity: 0.8 }}>Contrat — {a.immatriculation}</div>
          </div>
          <div style={{ display: 'flex', gap: 10 }}>
            <button onClick={handlePrint} style={{ background: '#FF8C00', border: 'none', color: 'white', padding: '8px 18px', borderRadius: 8, fontWeight: 700, fontSize: 13, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 6 }}>
              <i className="fas fa-download"></i> Télécharger / Imprimer
            </button>
            <button onClick={onClose} style={{ background: 'rgba(255,255,255,0.15)', border: 'none', color: 'white', width: 36, height: 36, borderRadius: 8, fontSize: 20, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>×</button>
          </div>
        </div>

        {/* Attestation card (preview) */}
        <div style={{ overflowY: 'auto', padding: 24, flex: 1 }}>
          <div ref={cardRef} style={{ background: '#FFD600', border: '3px solid #111', padding: '12px 16px', fontFamily: 'Arial, sans-serif', fontSize: 13 }}>
            <div style={{ border: '1.5px solid #111', padding: '10px 12px' }}>

              {/* Top row */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 10, gap: 10 }}>
                {/* Company info */}
                <div style={{ fontSize: 10.5, lineHeight: 1.6 }}>
                  <strong style={{ display: 'block', fontSize: 12, textTransform: 'uppercase' }}>MUTUAL BENEFITS</strong>
                  <strong style={{ display: 'block', fontSize: 12, textTransform: 'uppercase' }}>ASSURANCE NIGER S.A</strong>
                  <strong style={{ display: 'block', marginTop: 4 }}>SIÈGE SOCIAL :</strong>
                  Boulevard Tanimoune,<br/>
                  quartier Bobiel, Niamey<br/>
                  BP : 11924<br/>
                  Tél : +227 88 88 81 11<br/>
                  Email : info@mbaniger.com
                </div>

                {/* Right: logo + title */}
                <div style={{ textAlign: 'right', minWidth: 280 }}>
                  <div style={{ fontSize: 9, fontStyle: 'italic', marginBottom: 5 }}>République du Niger</div>
                  <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, border: '2px solid #111', padding: '4px 10px', background: 'white', marginBottom: 8 }}>
                    <img src="/logo.jpg" alt="MBA" style={{ width: 38, height: 38, objectFit: 'contain' }} />
                    <div style={{ textAlign: 'left', lineHeight: 1.3 }}>
                      <div style={{ fontSize: 11, fontWeight: 800, color: '#006652' }}>MBA</div>
                      <div style={{ fontSize: 12, fontWeight: 900, color: '#e30000' }}>NIGER</div>
                    </div>
                  </div>
                  <div style={{ border: '2px solid #111', padding: '6px 12px', display: 'inline-block', textAlign: 'center' }}>
                    <div style={{ fontWeight: 900, fontSize: 13, textTransform: 'uppercase' }}>ATTESTATION D'ASSURANCE</div>
                    <div style={{ fontSize: 9 }}>(Article 214 du Code CIMA) N°</div>
                    <div style={{ fontSize: 22, fontWeight: 900, letterSpacing: 1, marginTop: 2 }}>{attestNum}</div>
                  </div>
                </div>
              </div>

              <div style={{ borderTop: '1.5px solid #111', margin: '8px 0' }} />

              {/* Fields grid */}
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '4px 24px', marginBottom: 8 }}>
                {[
                  ['N° de Police', policeNum, false],
                  ['N° Assuré', assureNum, false],
                  ['Souscripteur', a.clients || '-', true],
                  ['Adresse', a.quartier || 'Niamey, Niger', true],
                  ['Véhicule Genre', a.id_categorie?.genre || '-', false],
                  ['Marque', a.id_voiture?.marque || '-', false],
                ].map(([label, value, full]) => (
                  <div key={label} style={{ gridColumn: full ? '1/-1' : undefined, borderBottom: '1px solid #555', paddingBottom: 3, marginBottom: 2 }}>
                    <div style={{ fontSize: 8.5, fontWeight: 700, textTransform: 'uppercase', color: '#444' }}>{label}</div>
                    <div style={{ fontSize: 12, fontWeight: 700, minHeight: 16 }}>{value}</div>
                  </div>
                ))}
                <div style={{ gridColumn: '1/-1', borderBottom: '1px solid #555', paddingBottom: 3, marginBottom: 2 }}>
                  <div style={{ fontSize: 8.5, fontWeight: 700, textTransform: 'uppercase', color: '#444' }}>Remorque</div>
                  <div style={{ display: 'flex', gap: 20, fontSize: 9.5, fontWeight: 700, marginTop: 2 }}>
                    <span style={{ display: 'flex', alignItems: 'center', gap: 4 }}><span style={{ width: 10, height: 10, border: '1.5px solid #111', display: 'inline-block' }}></span> Semi-remorque</span>
                    <span style={{ display: 'flex', alignItems: 'center', gap: 4 }}><span style={{ width: 10, height: 10, border: '1.5px solid #111', display: 'inline-block' }}></span> Appareil terrestre</span>
                    <span style={{ marginLeft: 'auto', fontSize: 9 }}>Marque : ___________________</span>
                  </div>
                </div>
                <div style={{ borderBottom: '1px solid #555', paddingBottom: 3, marginBottom: 2 }}>
                  <div style={{ fontSize: 8.5, fontWeight: 700, textTransform: 'uppercase', color: '#444' }}>N° d'immatriculation <sup>(1)</sup></div>
                  <div style={{ fontSize: 12, fontWeight: 700 }}>{a.immatriculation}</div>
                </div>
                <div style={{ borderBottom: '1px solid #555', paddingBottom: 3, marginBottom: 2 }}>
                  <div style={{ fontSize: 8.5, fontWeight: 700, textTransform: 'uppercase', color: '#444' }}>N° d'immatriculation <sup>(2)</sup></div>
                  <div style={{ fontSize: 12, fontWeight: 700 }}>&nbsp;</div>
                </div>
                <div style={{ gridColumn: '1/-1', borderBottom: '1px solid #555', paddingBottom: 3, marginBottom: 2 }}>
                  <div style={{ fontSize: 8.5, fontWeight: 700, textTransform: 'uppercase', color: '#444' }}>Profession <sup>(1)</sup></div>
                  <div style={{ fontSize: 12, fontWeight: 700 }}>&nbsp;</div>
                </div>
              </div>

              {/* Validity */}
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap', fontSize: 11, margin: '6px 0' }}>
                <strong style={{ fontSize: 13 }}>Valable du</strong>
                <span style={{ borderBottom: '1.5px solid #111', minWidth: 90, padding: '0 4px', fontWeight: 900, fontSize: 13 }}>{fmt(a.date_debut)}</span>
                <strong style={{ fontSize: 13 }}>au</strong>
                <span style={{ borderBottom: '1.5px solid #111', minWidth: 90, padding: '0 4px', fontWeight: 900, fontSize: 13 }}>{fmt(a.date_fin)}</span>
              </div>

              <div style={{ fontSize: 10, fontWeight: 700, margin: '4px 0' }}>
                Visa ministériel N° 2334 du 25 mai 1998
              </div>

              {/* Prise d'effet + Pour la compagnie */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginTop: 8 }}>
                <div style={{ fontSize: 11 }}>
                  Prise d'effet le <strong style={{ borderBottom: '1.5px solid #111', padding: '0 4px', fontSize: 12 }}>{fmt(a.date_debut)}</strong>
                  &nbsp;à&nbsp; <strong style={{ borderBottom: '1.5px solid #111', padding: '0 4px', fontSize: 12 }}>{heureEffet}</strong>
                </div>
                <div style={{ border: '1.5px solid #111', padding: '4px 12px', fontWeight: 900, fontSize: 11, textTransform: 'uppercase' }}>POUR LA COMPAGNIE</div>
              </div>

              {/* Note */}
              <div style={{ border: '1.5px solid #111', padding: '5px 8px', fontSize: 8.5, marginTop: 8, lineHeight: 1.5, background: 'rgba(255,255,255,0.3)' }}>
                <sup>(1)-(2)</sup> (voir VERSO)<br/>
                Sa présentation n'implique, selon les dispositions des Articles 213 et 215 du Code CIMA, qu'une présomption de garantie à la charge de l'assureur.
              </div>

              {/* Footer countries */}
              <div style={{ fontSize: 8, marginTop: 6, borderTop: '1px solid #111', paddingTop: 4, lineHeight: 1.5 }}>
                <strong>Valable dans les États suivants :</strong> Niger, Bénin, Burkina Faso, Cameroun, Centrafrique, Comores, Congo Brazzaville, Côte d'Ivoire, Gabon, Guinée Équatoriale, Mali, Sénégal, Tchad, Togo
              </div>

            </div>
          </div>
        </div>

        {/* Footer */}
        <div style={{ padding: '12px 24px', borderTop: '1px solid #f0f0f0', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexShrink: 0, background: '#fafafa', borderRadius: '0 0 16px 16px' }}>
          <div style={{ fontSize: 12, color: '#888' }}>
            <i className="fas fa-info-circle me-1"></i>
            Puissance : <strong>{a.puissance} CV</strong> &nbsp;|&nbsp;
            Énergie : <strong>{a.energie === 0 ? 'Essence' : 'Gazoil'}</strong> &nbsp;|&nbsp;
            Durée : <strong>{a.nombre_mois} mois</strong> &nbsp;|&nbsp;
            Prix TTC : <strong>{(a.prix_ttc || 0).toLocaleString()} FCFA</strong>
          </div>
          <button onClick={onClose} style={{ background: '#f0f0f0', border: 'none', padding: '8px 20px', borderRadius: 8, fontWeight: 600, cursor: 'pointer', fontSize: 13 }}>Fermer</button>
        </div>

      </div>
    </div>
  );
}
