import { useState, useRef } from 'react';
import api from '../api/axios';

export default function CarteGriseScanner({ onApply, voitures }) {
  const [preview, setPreview] = useState(null);
  const [file, setFile] = useState(null);
  const [scanning, setScanning] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState('');
  const [dragging, setDragging] = useState(false);
  const inputRef = useRef();

  const handleFile = f => {
    if (!f || !f.type.startsWith('image/')) { setError('Fichier invalide. Sélectionnez une image.'); return; }
    setFile(f);
    setResult(null);
    setError('');
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
    setScanning(true); setError(''); setResult(null);
    try {
      const fd = new FormData();
      fd.append('image', file);
      const { data } = await api.post('/ocr/carte-grise', fd, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      if (data.success) setResult(data.data);
      else setError(data.message || 'Analyse échouée.');
    } catch (err) {
      setError(err.response?.data?.message || 'Erreur lors de l\'analyse.');
    } finally {
      setScanning(false);
    }
  };

  const handleApply = () => {
    if (!result) return;
    // Trouver la voiture correspondante par marque
    const marqueMatch = voitures?.find(v =>
      v.marque?.toLowerCase() === result.marque?.toLowerCase()
    );
    onApply({
      immatriculation: result.immatriculation || '',
      id_voiture: marqueMatch?._id || '',
      puissance: result.puissance?.toString() || '',
      energie: result.energie !== null && result.energie !== undefined ? result.energie.toString() : '',
      nombre_place: result.nombre_place?.toString() || '',
      _marque_scan: result.marque || '',
      _modele_scan: result.modele || '',
    });
  };

  const FIELD_LABELS = [
    { key: 'immatriculation', label: 'Immatriculation', icon: 'fa-id-card' },
    { key: 'marque',          label: 'Marque',          icon: 'fa-car' },
    { key: 'modele',          label: 'Modèle',          icon: 'fa-tag' },
    { key: 'puissance',       label: 'Puissance (CV)',  icon: 'fa-tachometer-alt' },
    { key: 'energie',         label: 'Énergie',         icon: 'fa-gas-pump',
      format: v => v === 0 ? 'Essence' : v === 1 ? 'Gazoil' : '-' },
    { key: 'nombre_place',    label: 'Nb places',       icon: 'fa-users' },
    { key: 'vin',             label: 'N° Châssis (VIN)',icon: 'fa-barcode' },
    { key: 'date_mise_circulation', label: 'Mise en circulation', icon: 'fa-calendar' },
  ];

  return (
    <div style={{ background: 'white', borderRadius: 14, border: '2px dashed #006652', padding: '20px 22px', marginBottom: 24 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 16 }}>
        <div style={{ width: 36, height: 36, background: 'linear-gradient(135deg,#006652,#008a6e)', borderRadius: 9, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <i className="fas fa-id-card" style={{ color: 'white', fontSize: 16 }}></i>
        </div>
        <div>
          <div style={{ fontWeight: 700, fontSize: 15, color: '#006652' }}>Scanner la carte grise</div>
          <div style={{ fontSize: 12, color: '#888' }}>Importez une photo — les champs seront remplis automatiquement</div>
        </div>
      </div>

      <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
        {/* Zone upload */}
        <div style={{ flex: '1 1 280px' }}>
          <div
            onClick={() => inputRef.current.click()}
            onDragOver={e => { e.preventDefault(); setDragging(true); }}
            onDragLeave={() => setDragging(false)}
            onDrop={handleDrop}
            style={{
              border: `2px dashed ${dragging ? '#FF8C00' : '#ccc'}`,
              borderRadius: 10, padding: '18px 12px', textAlign: 'center',
              cursor: 'pointer', background: dragging ? 'rgba(255,140,0,0.05)' : '#fafafa',
              transition: 'all 0.2s', minHeight: 130,
              display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 8
            }}
          >
            {preview ? (
              <img src={preview} alt="carte grise" style={{ maxHeight: 120, maxWidth: '100%', borderRadius: 6, objectFit: 'contain' }} />
            ) : (
              <>
                <i className="fas fa-cloud-upload-alt" style={{ fontSize: 32, color: '#bbb' }}></i>
                <div style={{ fontSize: 13, color: '#888' }}>Glissez ou cliquez pour sélectionner</div>
                <div style={{ fontSize: 11, color: '#aaa' }}>JPG, PNG, WEBP — max 10 Mo</div>
              </>
            )}
          </div>
          <input ref={inputRef} type="file" accept="image/*" style={{ display: 'none' }}
            onChange={e => handleFile(e.target.files[0])} />

          <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
            {preview && (
              <button type="button" onClick={() => { setPreview(null); setFile(null); setResult(null); setError(''); }}
                style={{ flex: 1, padding: '8px', border: '1.5px solid #ddd', background: 'white', borderRadius: 7, fontSize: 12, cursor: 'pointer', color: '#666' }}>
                <i className="fas fa-times me-1"></i>Effacer
              </button>
            )}
            <button type="button" onClick={handleScan} disabled={!file || scanning}
              style={{ flex: 2, padding: '9px', background: (!file || scanning) ? '#ddd' : 'linear-gradient(to right,#006652,#008a6e)', color: (!file || scanning) ? '#aaa' : 'white', border: 'none', borderRadius: 7, fontWeight: 700, fontSize: 13, cursor: (!file || scanning) ? 'not-allowed' : 'pointer', transition: 'all 0.2s' }}>
              {scanning
                ? <><span className="spinner me-2"></span>Analyse en cours...</>
                : <><i className="fas fa-magic me-2"></i>Analyser</>}
            </button>
          </div>

          {error && (
            <div style={{ marginTop: 10, background: '#fff2f2', border: '1px solid #ffcccc', borderRadius: 7, padding: '8px 12px', fontSize: 12.5, color: '#c0392b' }}>
              <i className="fas fa-exclamation-triangle me-1"></i>{error}
            </div>
          )}
        </div>

        {/* Résultats */}
        {result && (
          <div style={{ flex: '1 1 280px' }}>
            <div style={{ background: '#f0f9f6', borderRadius: 10, padding: '14px 16px', border: '1px solid #c3e6d8' }}>
              <div style={{ fontWeight: 700, fontSize: 13, color: '#006652', marginBottom: 10, display: 'flex', alignItems: 'center', gap: 6 }}>
                <i className="fas fa-check-circle"></i> Données extraites
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '6px 12px' }}>
                {FIELD_LABELS.map(({ key, label, icon, format }) => {
                  const val = result[key];
                  const display = format ? format(val) : (val ?? '-');
                  const hasValue = val !== null && val !== undefined && val !== '';
                  return (
                    <div key={key} style={{ background: hasValue ? 'white' : 'rgba(0,0,0,0.03)', borderRadius: 6, padding: '6px 8px', border: `1px solid ${hasValue ? '#c3e6d8' : '#eee'}` }}>
                      <div style={{ fontSize: 9.5, color: '#888', textTransform: 'uppercase', fontWeight: 600, marginBottom: 2 }}>
                        <i className={`fas ${icon} me-1`} style={{ color: hasValue ? '#006652' : '#ccc' }}></i>{label}
                      </div>
                      <div style={{ fontWeight: 700, fontSize: 12.5, color: hasValue ? '#1a1a1a' : '#bbb' }}>
                        {display?.toString() || '—'}
                      </div>
                    </div>
                  );
                })}
              </div>

              <button type="button" onClick={handleApply}
                style={{ width: '100%', marginTop: 12, padding: '10px', background: 'linear-gradient(to right,#FF8C00,#e07a00)', color: 'white', border: 'none', borderRadius: 8, fontWeight: 700, fontSize: 13, cursor: 'pointer' }}>
                <i className="fas fa-check-double me-2"></i>Appliquer dans le formulaire
              </button>
            </div>
          </div>
        )}

        {scanning && !result && (
          <div style={{ flex: '1 1 280px', display: 'flex', alignItems: 'center', justifyContent: 'center', flexDirection: 'column', gap: 12, color: '#888', padding: 20 }}>
            <div style={{ width: 48, height: 48, border: '4px solid #e0e0e0', borderTopColor: '#006652', borderRadius: '50%', animation: 'spin 0.8s linear infinite' }}></div>
            <div style={{ fontSize: 13 }}>Lecture de la carte grise...</div>
          </div>
        )}
      </div>
    </div>
  );
}
