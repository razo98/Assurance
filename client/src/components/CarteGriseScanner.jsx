import { useState, useRef } from 'react';
import Tesseract from 'tesseract.js';

// ─── Parseur texte OCR → champs carte grise Niger ───────────────────────────
function parseCarteGrise(text) {
  const t = text.toUpperCase().replace(/\|/g, 'I');
  const lines = t.split('\n').map(l => l.trim()).filter(Boolean);

  const find = (patterns) => {
    for (const pattern of patterns) {
      const m = t.match(pattern);
      if (m) return m[1]?.trim();
    }
    return null;
  };

  // Immatriculation — formats Niger: BA-2261 / NI-1234-AB / AB 123 CD
  const immat = find([
    /IMMAT[A-Z\s:\.]*([A-Z]{1,3}[-\s]\d{3,4}[-\s]?[A-Z]{0,2})/,
    /([A-Z]{2,3}[-\s]\d{3,4}[-\s]?[A-Z]{0,2})\b/,
  ]);

  // Marque
  let marque = find([
    /MARQUE\s*[:\-]?\s*([A-Z][A-Z0-9\s\-]{1,20}?)(?:\n|TYPE|GENRE|MODELE)/,
    /MARQUE\s*[:\-]?\s*([A-Z][A-Z0-9]{2,15})/,
  ]);
  // Chercher aussi dans les lignes
  if (!marque) {
    const MARQUES = ['TOYOTA','HONDA','PEUGEOT','RENAULT','NISSAN','MITSUBISHI','HYUNDAI','KIA','SUZUKI','YAMAHA','BAJAJ','TVS','DACIA','FORD','MERCEDES','BMW','VOLKSWAGEN','ISUZU','LAND ROVER','LAND','TATA','MAHINDRA'];
    for (const m of MARQUES) {
      if (t.includes(m)) { marque = m; break; }
    }
  }

  // Genre / type de véhicule
  const genre = find([
    /GENRE\s*[:\-]?\s*([A-Z][A-Z\s]{2,25}?)(?:\n|PTAC|PUISSANCE|PLACES)/,
    /GENRE\s*[:\-]?\s*([A-Z][A-Z\s]{2,20})/,
  ]);

  // Puissance fiscale (CV) — champ P.6 ou "Puissance" ou juste "CV"
  const puissanceRaw = find([
    /PUISSANCE\s*[:\-]?\s*(\d{1,3})\s*(?:CV|CH)?/,
    /(?:^|\s)(\d{1,3})\s*CV/,
    /CV\s*[:\-]?\s*(\d{1,3})/,
    /P\.?6\s*[:\-]?\s*(\d{1,3})/,
  ]);
  const puissance = puissanceRaw ? parseInt(puissanceRaw) : null;

  // Énergie : 0=Essence, 1=Gazoil
  let energie = null;
  if (/GAZOIL|DIESEL|GAZOLE|GO\b/.test(t)) energie = 1;
  else if (/ESSENCE|SP\b|PETROL|GASOLINE/.test(t)) energie = 0;

  // Nombre de places (S.1)
  const placesRaw = find([
    /PLACES?\s*[:\-]?\s*(\d{1,2})(?!\d)/,
    /S\.?1\s*[:\-]?\s*(\d{1,2})/,
    /NBRE?\s*(?:DE\s*)?PLACES?\s*[:\-]?\s*(\d{1,2})/,
    /SEATS?\s*[:\-]?\s*(\d{1,2})/,
  ]);
  const nombre_place = placesRaw ? parseInt(placesRaw) : null;

  // Nom du propriétaire
  let nomProprietaire = find([
    /NOM\s*[:\-]?\s*([A-Z][A-Z\s]{3,30})(?:\n|PRENOM|ADRESSE|N°)/,
    /NOM\s*[:\-]?\s*([A-Z][A-Z\s]{3,30})/,
  ]);

  // Cylindrée
  const cylindree = find([
    /CYLINDR[EÉ]{1,2}E?\s*[:\-]?\s*(\d{3,5})/,
    /P\.?1\s*[:\-]?\s*(\d{3,5})/,
  ]);

  // VIN / Numéro châssis
  const vin = find([
    /(?:CHASSIS|VIN|N°\s*ID|SERIE|IMMATR)\s*[:\-]?\s*([A-Z0-9]{6,20})/,
    /[A-Z]{2}\d[A-Z\d]{13}/,
  ]);

  return {
    immatriculation: immat || null,
    marque: marque ? marque.trim() : null,
    genre: genre ? genre.trim() : null,
    puissance: (puissance && puissance > 0 && puissance < 500) ? puissance : null,
    energie,
    nombre_place: (nombre_place && nombre_place > 0 && nombre_place < 100) ? nombre_place : null,
    cylindree: cylindree ? parseInt(cylindree) : null,
    vin: vin || null,
    nom_proprietaire: nomProprietaire ? nomProprietaire.trim() : null,
  };
}

// ─── Composant ────────────────────────────────────────────────────────────────
export default function CarteGriseScanner({ onApply, voitures }) {
  const [preview, setPreview] = useState(null);
  const [file, setFile] = useState(null);
  const [scanning, setScanning] = useState(false);
  const [progress, setProgress] = useState(0);
  const [result, setResult] = useState(null);
  const [rawText, setRawText] = useState('');
  const [error, setError] = useState('');
  const [dragging, setDragging] = useState(false);
  const [showRaw, setShowRaw] = useState(false);
  const inputRef = useRef();

  const handleFile = f => {
    if (!f || !f.type.startsWith('image/')) { setError('Fichier invalide. Sélectionnez une image.'); return; }
    setFile(f);
    setResult(null);
    setRawText('');
    setError('');
    setProgress(0);
    const reader = new FileReader();
    reader.onload = e => setPreview(e.target.result);
    reader.readAsDataURL(f);
  };

  const handleDrop = e => {
    e.preventDefault(); setDragging(false);
    handleFile(e.dataTransfer.files[0]);
  };

  const handleScan = async () => {
    if (!file) return;
    setScanning(true); setError(''); setResult(null); setProgress(0);
    try {
      const { data } = await Tesseract.recognize(file, 'fra+eng', {
        logger: m => {
          if (m.status === 'recognizing text') {
            setProgress(Math.round(m.progress * 100));
          }
        }
      });
      const text = data.text || '';
      setRawText(text);
      const parsed = parseCarteGrise(text);
      setResult(parsed);
    } catch (err) {
      setError('Erreur lors de la lecture OCR : ' + err.message);
    } finally {
      setScanning(false);
    }
  };

  const handleApply = () => {
    if (!result) return;
    const marqueMatch = voitures?.find(v =>
      v.marque?.toLowerCase() === result.marque?.toLowerCase()
    );
    onApply({
      immatriculation: result.immatriculation || '',
      id_voiture:      marqueMatch?._id || '',
      puissance:       result.puissance?.toString() || '',
      energie:         result.energie !== null && result.energie !== undefined ? result.energie.toString() : '',
      nombre_place:    result.nombre_place?.toString() || '',
      nom_assure:      result.nom_proprietaire || '',
      _marque_scan:    result.marque || '',
      _file:           file,  // fichier image pour upload serveur
    });
  };

  const FIELDS = [
    { key: 'immatriculation',   label: 'Immatriculation',  icon: 'fa-id-card' },
    { key: 'marque',            label: 'Marque',            icon: 'fa-car' },
    { key: 'genre',             label: 'Genre véhicule',    icon: 'fa-tag' },
    { key: 'puissance',         label: 'Puissance (CV)',    icon: 'fa-tachometer-alt' },
    { key: 'energie',           label: 'Énergie',           icon: 'fa-gas-pump',
      format: v => v === 0 ? 'Essence' : v === 1 ? 'Gazoil' : null },
    { key: 'nombre_place',      label: 'Nb de places',      icon: 'fa-users' },
    { key: 'cylindree',         label: 'Cylindrée (cm³)',   icon: 'fa-cogs' },
    { key: 'nom_proprietaire',  label: 'Propriétaire',      icon: 'fa-user' },
  ];

  const hasAny = result && Object.values(result).some(v => v !== null && v !== undefined);

  return (
    <div style={{ background: 'white', borderRadius: 14, border: '2px dashed #006652', padding: '20px 22px', marginBottom: 24 }}>
      {/* En-tête */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 16 }}>
        <div style={{ width: 38, height: 38, background: 'linear-gradient(135deg,#006652,#008a6e)', borderRadius: 9, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
          <i className="fas fa-id-card" style={{ color: 'white', fontSize: 16 }}></i>
        </div>
        <div>
          <div style={{ fontWeight: 700, fontSize: 15, color: '#006652' }}>Scanner la carte grise</div>
          <div style={{ fontSize: 12, color: '#888' }}>Lecture optique automatique — 100% gratuit, fonctionne hors ligne</div>
        </div>
      </div>

      <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
        {/* Zone upload + bouton scan */}
        <div style={{ flex: '1 1 260px' }}>
          <div
            onClick={() => inputRef.current.click()}
            onDragOver={e => { e.preventDefault(); setDragging(true); }}
            onDragLeave={() => setDragging(false)}
            onDrop={handleDrop}
            style={{
              border: `2px dashed ${dragging ? '#FF8C00' : '#ccc'}`,
              borderRadius: 10, padding: '14px 10px', textAlign: 'center',
              cursor: 'pointer', background: dragging ? 'rgba(255,140,0,0.05)' : '#fafafa',
              transition: 'all 0.2s', minHeight: 130,
              display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8
            }}
          >
            {preview
              ? <img src={preview} alt="carte grise" style={{ maxHeight: 120, maxWidth: '100%', borderRadius: 6, objectFit: 'contain' }} />
              : <>
                  <i className="fas fa-cloud-upload-alt" style={{ fontSize: 32, color: '#bbb' }}></i>
                  <div style={{ fontSize: 13, color: '#888' }}>Glissez ou cliquez pour importer</div>
                  <div style={{ fontSize: 11, color: '#aaa' }}>JPG, PNG — prenez une photo nette et bien éclairée</div>
                </>
            }
          </div>
          <input ref={inputRef} type="file" accept="image/*" style={{ display: 'none' }}
            onChange={e => handleFile(e.target.files[0])} />

          {/* Barre de progression */}
          {scanning && (
            <div style={{ marginTop: 10 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12, color: '#666', marginBottom: 4 }}>
                <span><i className="fas fa-cog fa-spin me-1"></i>Lecture en cours...</span>
                <span>{progress}%</span>
              </div>
              <div style={{ height: 6, background: '#e0e0e0', borderRadius: 3, overflow: 'hidden' }}>
                <div style={{ height: '100%', width: `${progress}%`, background: 'linear-gradient(to right,#006652,#008a6e)', borderRadius: 3, transition: 'width 0.3s' }} />
              </div>
            </div>
          )}

          <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
            {preview && (
              <button type="button" onClick={() => { setPreview(null); setFile(null); setResult(null); setError(''); setRawText(''); }}
                style={{ flex: 1, padding: '8px', border: '1.5px solid #ddd', background: 'white', borderRadius: 7, fontSize: 12, cursor: 'pointer', color: '#666' }}>
                <i className="fas fa-times me-1"></i>Effacer
              </button>
            )}
            <button type="button" onClick={handleScan} disabled={!file || scanning}
              style={{ flex: 2, padding: '9px', background: (!file || scanning) ? '#ddd' : 'linear-gradient(to right,#006652,#008a6e)', color: (!file || scanning) ? '#aaa' : 'white', border: 'none', borderRadius: 7, fontWeight: 700, fontSize: 13, cursor: (!file || scanning) ? 'not-allowed' : 'pointer' }}>
              {scanning ? <><i className="fas fa-spinner fa-spin me-1"></i>Analyse...</> : <><i className="fas fa-magic me-2"></i>Lire la carte</>}
            </button>
          </div>

          {error && (
            <div style={{ marginTop: 10, background: '#fff2f2', border: '1px solid #ffcccc', borderRadius: 7, padding: '8px 12px', fontSize: 12.5, color: '#c0392b' }}>
              <i className="fas fa-exclamation-triangle me-1"></i>{error}
            </div>
          )}

          {/* Conseils photo */}
          {!preview && (
            <div style={{ marginTop: 12, background: '#f0f9f6', borderRadius: 8, padding: '10px 12px', fontSize: 11.5, color: '#555', lineHeight: 1.7 }}>
              <strong style={{ color: '#006652' }}>Conseils pour une bonne lecture :</strong><br />
              📷 Photo nette, bien éclairée (pas de reflets)<br />
              📐 Carte bien cadrée, texte horizontal<br />
              🔍 Résolution correcte (pas floue)
            </div>
          )}
        </div>

        {/* Résultats */}
        {result && (
          <div style={{ flex: '1 1 280px' }}>
            <div style={{ background: hasAny ? '#f0f9f6' : '#fff8e1', borderRadius: 10, padding: '14px 16px', border: `1px solid ${hasAny ? '#c3e6d8' : '#ffe082'}` }}>
              <div style={{ fontWeight: 700, fontSize: 13, color: hasAny ? '#006652' : '#7c5e00', marginBottom: 10, display: 'flex', alignItems: 'center', gap: 6 }}>
                <i className={`fas ${hasAny ? 'fa-check-circle' : 'fa-exclamation-circle'}`}></i>
                {hasAny ? 'Données extraites' : 'Peu de données détectées'}
              </div>

              {!hasAny && (
                <div style={{ fontSize: 12, color: '#7c5e00', marginBottom: 10 }}>
                  La photo est peut-être floue ou peu éclairée. Réessayez avec une meilleure image.
                </div>
              )}

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '5px 10px' }}>
                {FIELDS.map(({ key, label, icon, format }) => {
                  const val = result[key];
                  const display = format ? format(val) : val;
                  const ok = display !== null && display !== undefined && display !== '';
                  return (
                    <div key={key} style={{ background: ok ? 'white' : 'rgba(0,0,0,0.03)', borderRadius: 6, padding: '6px 8px', border: `1px solid ${ok ? '#c3e6d8' : '#eee'}` }}>
                      <div style={{ fontSize: 9, color: '#888', textTransform: 'uppercase', fontWeight: 600, marginBottom: 2 }}>
                        <i className={`fas ${icon} me-1`} style={{ color: ok ? '#006652' : '#ccc' }}></i>{label}
                      </div>
                      <div style={{ fontWeight: 700, fontSize: 12, color: ok ? '#1a1a1a' : '#ccc' }}>
                        {ok ? display.toString() : '—'}
                      </div>
                    </div>
                  );
                })}
              </div>

              <button type="button" onClick={handleApply}
                style={{ width: '100%', marginTop: 12, padding: '10px', background: 'linear-gradient(to right,#FF8C00,#e07a00)', color: 'white', border: 'none', borderRadius: 8, fontWeight: 700, fontSize: 13, cursor: 'pointer' }}>
                <i className="fas fa-check-double me-2"></i>Appliquer dans le formulaire
              </button>

              {/* Texte brut OCR (debug) */}
              {rawText && (
                <div style={{ marginTop: 10 }}>
                  <button type="button" onClick={() => setShowRaw(s => !s)}
                    style={{ background: 'none', border: 'none', fontSize: 11, color: '#999', cursor: 'pointer', padding: 0, textDecoration: 'underline' }}>
                    {showRaw ? 'Masquer' : 'Voir'} le texte brut OCR
                  </button>
                  {showRaw && (
                    <pre style={{ marginTop: 6, background: '#f5f5f5', borderRadius: 6, padding: '8px', fontSize: 10, maxHeight: 120, overflowY: 'auto', whiteSpace: 'pre-wrap', color: '#555' }}>
                      {rawText}
                    </pre>
                  )}
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
