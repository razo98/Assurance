import { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../api/axios';

const QUARTIERS = ['Francophonie','Bobiel','Sonuci','Tchangarey','Ryad','Dar As Salam','Plateau','Recasement','Cite Chinoise'];

export default function DevisForm({ mode = 'client' }) {
  const { user } = useAuth();
  const navigate = useNavigate();
  const fileRef = useRef();

  const [voitures, setVoitures] = useState([]);
  const [categories, setCategories] = useState([]);
  const [form, setForm] = useState({
    nom_assure: '', telephone: '',
    id_voiture: '', id_categorie: '', immatriculation: '', quartier: '',
    puissance: '', nombre_place: '', energie: '', nombre_mois: '', date_debut: '',
    valider: '0', mode_paiement: '', code_transaction: '',
  });
  const [carteGriseFile, setCarteGriseFile] = useState(null);
  const [carteGrisePreview, setCarteGrisePreview] = useState(null);

  const [prix, setPrix] = useState(null);
  const [prixHT, setPrixHT] = useState(null);
  const [loading, setLoading] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const [showAddBrand, setShowAddBrand] = useState(false);
  const [newMarque, setNewMarque] = useState('');
  const [error, setError] = useState('');
  const [puissanceHelp, setPuissanceHelp] = useState('');

  useEffect(() => {
    Promise.all([api.get('/voitures'), api.get('/categories')])
      .then(([v, c]) => { setVoitures(v.data); setCategories(c.data); });
  }, []);

  const handleChange = e => {
    const { name, value } = e.target;
    setForm(f => ({ ...f, [name]: value }));
    setPrix(null); setError('');
    if (name === 'id_categorie' || name === 'energie') updatePuissanceHelp(
      name === 'id_categorie' ? value : form.id_categorie,
      name === 'energie' ? value : form.energie
    );
  };

  const handleCarteGriseFile = f => {
    if (!f || !f.type.startsWith('image/')) return;
    setCarteGriseFile(f);
    const reader = new FileReader();
    reader.onload = e => setCarteGrisePreview(e.target.result);
    reader.readAsDataURL(f);
  };

  const updatePuissanceHelp = (catId, energie) => {
    const cat = categories.find(c => c._id === catId);
    if (!cat || energie === '') { setPuissanceHelp(''); return; }
    const g = cat.genre.toLowerCase();
    if (g === 'vp') {
      setPuissanceHelp(energie === '0' ? 'VP Essence : 3 CV minimum' : 'VP Gazoil : 2 CV minimum');
    } else if (g === 'taxiville_4p') {
      setPuissanceHelp(energie === '0' ? 'Taxi 4p Essence : 3 à 14 CV' : 'Taxi 4p Gazoil : 2 à 10 CV');
    } else if (g === 'moto') {
      setPuissanceHelp('Moto : 0 à 3 CV');
    } else if (g === 'taxiville_19p') {
      setPuissanceHelp(energie === '0' ? 'Taxi 19p Essence : 7 à 14 CV' : 'Taxi 19p Gazoil : 5 à 10 CV');
    } else setPuissanceHelp('');
  };

  const calculerPrix = async () => {
    const { id_categorie, energie, puissance, nombre_mois } = form;
    if (!id_categorie || energie === '' || !puissance || !nombre_mois) {
      setError('Remplissez catégorie, énergie, puissance et durée.'); return false;
    }
    const cat = categories.find(c => c._id === id_categorie);
    setLoading(true);
    try {
      const { data } = await api.get(`/prix/calculer?genre=${encodeURIComponent(cat?.genre || '')}&energie=${energie}&puissance=${puissance}&nombre_mois=${nombre_mois}`);
      if (data.success) { setPrix(data.prix); setPrixHT(data.prix_ht); return true; }
      setError(data.message); return false;
    } catch { setError('Erreur lors du calcul du prix.'); return false; }
    finally { setLoading(false); }
  };

  const handleCalculer = async e => {
    e.preventDefault();
    setError('');
    const required = ['nom_assure','telephone','id_voiture','id_categorie','immatriculation','quartier','puissance','nombre_place','energie','nombre_mois','date_debut'];
    if (required.some(k => !form[k])) { setError('Veuillez remplir tous les champs obligatoires.'); return; }
    const ok = await calculerPrix();
    if (ok) setShowModal(true);
  };

  const handleConfirm = async () => {
    if (mode === 'client' && (!form.mode_paiement || !form.code_transaction)) {
      setError('Veuillez remplir le mode et code de transaction.'); return;
    }
    setLoading(true);
    try {
      const payload = {
        ...form,
        clients: form.nom_assure, // compatibilité avec le reste de l'app
        iduser: mode === 'client' ? user?.id : undefined,
      };
      const { data: created } = await api.post('/assurances', payload);

      // Upload carte grise si présente
      if (carteGriseFile && created._id) {
        try {
          const fd = new FormData();
          fd.append('carte_grise', carteGriseFile);
          await api.post(`/assurances/${created._id}/carte-grise`, fd, {
            headers: { 'Content-Type': 'multipart/form-data' }
          });
        } catch { /* non bloquant */ }
      }

      if (mode === 'admin') navigate('/admin/assurances');
      else if (mode === 'agent') navigate('/agent/assurances');
      else navigate('/client/assurances');
    } catch (err) {
      setError(err.response?.data?.message || 'Erreur lors de la soumission.');
      setShowModal(false);
    } finally { setLoading(false); }
  };

  const handleAddBrand = async e => {
    e.preventDefault();
    try {
      const { data } = await api.post('/voitures', { marque: newMarque });
      setVoitures(v => [...v, data].sort((a,b) => a.marque.localeCompare(b.marque)));
      setForm(f => ({ ...f, id_voiture: data._id }));
      setNewMarque(''); setShowAddBrand(false);
    } catch (err) { alert(err.response?.data?.message || 'Erreur'); }
  };

  const today = new Date().toISOString().split('T')[0];
  const catSelected = categories.find(c => c._id === form.id_categorie);
  const marqueSelected = voitures.find(v => v._id === form.id_voiture);

  return (
    <div style={{ maxWidth: 900, margin: '0 auto' }}>
      {error && <div className="alert-custom alert-error"><i className="fas fa-exclamation-circle me-2"></i>{error}</div>}

      <form onSubmit={handleCalculer}>

        {/* ── Section 1 : Assuré ── */}
        <div className="devis-section">
          <div className="devis-section-title"><i className="fas fa-user"></i> Informations de l'assuré</div>
          <div style={{ background: '#f0f9f6', borderRadius: 8, padding: '10px 14px', marginBottom: 16, fontSize: 12.5, color: '#555', border: '1px solid #c3e6d8' }}>
            <i className="fas fa-info-circle me-1" style={{ color: '#006652' }}></i>
            Tous les champs doivent être renseignés <strong>exactement comme sur la carte grise</strong>.
          </div>
          <div className="row g-3">
            <div className="col-md-8">
              <div className="form-group">
                <label>Nom complet de l'assuré * <span style={{ fontSize: 11, color: '#888', fontWeight: 400 }}>(tel que sur la carte grise)</span></label>
                <input
                  className="form-control-custom"
                  name="nom_assure"
                  value={form.nom_assure}
                  onChange={handleChange}
                  placeholder="Ex : BARIBOU MAHAMANE"
                  style={{ textTransform: 'uppercase' }}
                  required
                />
              </div>
            </div>
            <div className="col-md-4">
              <div className="form-group">
                <label>Téléphone *</label>
                <input
                  className="form-control-custom"
                  name="telephone"
                  value={form.telephone}
                  onChange={handleChange}
                  placeholder="+227 XX XX XX XX"
                  required
                />
              </div>
            </div>

            {/* Upload carte grise */}
            <div className="col-12">
              <div className="form-group">
                <label style={{ fontWeight: 600, display: 'flex', alignItems: 'center', gap: 6 }}>
                  <i className="fas fa-id-card" style={{ color: '#006652' }}></i>
                  Photo de la carte grise
                  <span style={{ fontSize: 11, color: '#888', fontWeight: 400 }}>(facultatif — pour vérification)</span>
                </label>
                <div style={{ display: 'flex', gap: 12, alignItems: 'flex-start', flexWrap: 'wrap', marginTop: 6 }}>
                  <div
                    onClick={() => fileRef.current.click()}
                    style={{
                      width: 160, minHeight: 90, border: '2px dashed #bbb', borderRadius: 8,
                      display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                      cursor: 'pointer', background: '#fafafa', gap: 6, overflow: 'hidden', flexShrink: 0
                    }}
                  >
                    {carteGrisePreview
                      ? <img src={carteGrisePreview} alt="carte grise" style={{ width: '100%', height: 90, objectFit: 'cover', borderRadius: 6 }} />
                      : <>
                          <i className="fas fa-camera" style={{ fontSize: 22, color: '#bbb' }}></i>
                          <span style={{ fontSize: 11, color: '#999', textAlign: 'center', padding: '0 6px' }}>Cliquer pour importer</span>
                        </>
                    }
                  </div>
                  {carteGrisePreview && (
                    <button type="button" onClick={() => { setCarteGriseFile(null); setCarteGrisePreview(null); }}
                      style={{ background: 'none', border: '1px solid #ddd', borderRadius: 6, padding: '4px 10px', fontSize: 12, cursor: 'pointer', color: '#888', alignSelf: 'flex-start', marginTop: 4 }}>
                      <i className="fas fa-times me-1"></i>Supprimer
                    </button>
                  )}
                </div>
                <input ref={fileRef} type="file" accept="image/*" style={{ display: 'none' }}
                  onChange={e => handleCarteGriseFile(e.target.files[0])} />
              </div>
            </div>
          </div>
        </div>

        {/* ── Section 2 : Véhicule ── */}
        <div className="devis-section">
          <div className="devis-section-title">
            <i className="fas fa-car"></i> Informations du véhicule
            <span style={{ fontSize: 11, color: '#888', fontWeight: 400, marginLeft: 8 }}>(conformes à la carte grise)</span>
            <button type="button" onClick={() => setShowAddBrand(true)}
              style={{ marginLeft: 'auto', background: '#FF8C00', border: 'none', color: 'white', borderRadius: '50%', width: 26, height: 26, cursor: 'pointer', fontSize: 13 }}>
              <i className="fas fa-plus"></i>
            </button>
          </div>
          <div className="row g-3">
            <div className="col-md-6">
              <div className="form-group"><label>Marque *</label>
                <select className="form-control-custom" name="id_voiture" value={form.id_voiture} onChange={handleChange} required>
                  <option value="">-- Sélectionner --</option>
                  {voitures.map(v => <option key={v._id} value={v._id}>{v.marque}</option>)}
                </select>
              </div>
            </div>
            <div className="col-md-6">
              <div className="form-group"><label>Catégorie *</label>
                <select className="form-control-custom" name="id_categorie" value={form.id_categorie} onChange={handleChange} required>
                  <option value="">-- Sélectionner --</option>
                  {categories.map(c => <option key={c._id} value={c._id}>{c.genre}</option>)}
                </select>
              </div>
            </div>
            <div className="col-md-4">
              <div className="form-group"><label>Immatriculation *</label>
                <input className="form-control-custom" name="immatriculation" value={form.immatriculation}
                  onChange={handleChange} placeholder="Ex : BA-2261" style={{ textTransform: 'uppercase' }} required />
              </div>
            </div>
            <div className="col-md-4">
              <div className="form-group">
                <label>Puissance fiscale (CV) *</label>
                <input type="number" className="form-control-custom" name="puissance" value={form.puissance}
                  onChange={handleChange} min={0} placeholder="Ex : 6" required />
                {puissanceHelp && <small style={{ color: '#006652', fontSize: 11 }}>{puissanceHelp}</small>}
              </div>
            </div>
            <div className="col-md-4">
              <div className="form-group"><label>Nombre de places *</label>
                <input type="number" className="form-control-custom" name="nombre_place" value={form.nombre_place}
                  onChange={handleChange} min={1} placeholder="Ex : 5" required />
              </div>
            </div>
            <div className="col-md-6">
              <div className="form-group"><label>Carburant *</label>
                <select className="form-control-custom" name="energie" value={form.energie} onChange={handleChange} required>
                  <option value="">-- Sélectionner --</option>
                  <option value="0">Essence</option>
                  <option value="1">Gazoil</option>
                </select>
              </div>
            </div>
            <div className="col-md-6">
              <div className="form-group"><label>Quartier *</label>
                <select className="form-control-custom" name="quartier" value={form.quartier} onChange={handleChange} required>
                  <option value="">-- Sélectionner --</option>
                  {QUARTIERS.map(q => <option key={q} value={q}>{q}</option>)}
                </select>
              </div>
            </div>
          </div>
        </div>

        {/* ── Section 3 : Assurance ── */}
        <div className="devis-section">
          <div className="devis-section-title"><i className="fas fa-shield-alt"></i> Informations de l'assurance</div>
          <div className="row g-3">
            <div className="col-md-6">
              <div className="form-group"><label>Durée *</label>
                <select className="form-control-custom" name="nombre_mois" value={form.nombre_mois} onChange={handleChange} required>
                  <option value="">-- Sélectionner --</option>
                  <option value="3">3 mois</option>
                  <option value="6">6 mois</option>
                  <option value="12">12 mois</option>
                </select>
              </div>
            </div>
            <div className="col-md-6">
              <div className="form-group"><label>Date de début *</label>
                <input type="date" className="form-control-custom" name="date_debut" value={form.date_debut}
                  onChange={handleChange} min={today} required />
              </div>
            </div>
            {mode !== 'client' && (
              <div className="col-md-6">
                <div className="form-group"><label>Statut de paiement</label>
                  <select className="form-control-custom" name="valider" value={form.valider} onChange={handleChange}>
                    <option value="0">Non payé (En attente)</option>
                    <option value="1">Payé (Activer directement)</option>
                  </select>
                </div>
              </div>
            )}
          </div>
        </div>

        <div style={{ textAlign: 'center', marginTop: 8, marginBottom: 8 }}>
          <button type="submit" disabled={loading} style={{
            background: loading ? '#999' : 'linear-gradient(to right, #006652, #FF8C00)',
            border: 'none', color: 'white', padding: '14px 48px',
            borderRadius: 32, fontSize: 17, fontWeight: 700, cursor: loading ? 'not-allowed' : 'pointer',
            boxShadow: '0 6px 20px rgba(0,102,82,0.3)', transition: 'all 0.25s ease', letterSpacing: '0.3px'
          }}>
            {loading ? <><span className="spinner" style={{ marginRight: 8 }}></span>Calcul...</> : <><i className="fas fa-calculator me-2"></i>Calculer le devis</>}
          </button>
        </div>
      </form>

      {/* ── Modal récapitulatif ── */}
      {showModal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.65)', zIndex: 3000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20, backdropFilter: 'blur(3px)' }}>
          <div style={{ background: 'white', borderRadius: 16, width: '100%', maxWidth: 540, maxHeight: '92vh', overflowY: 'auto', boxShadow: '0 28px 70px rgba(0,0,0,0.35)', animation: 'scaleIn 0.28s ease' }}>
            <div style={{ background: 'linear-gradient(135deg, #004d3d, #006652, #007a60)', color: 'white', padding: '24px 28px', borderRadius: '16px 16px 0 0', textAlign: 'center' }}>
              <div style={{ fontSize: 13, opacity: 0.82, marginBottom: 8, textTransform: 'uppercase', letterSpacing: '1px', fontWeight: 600 }}>Prix total (TVA 12% incluse)</div>
              <div style={{ fontSize: 44, fontWeight: 800, lineHeight: 1 }}>{prix?.toLocaleString()} <span style={{ fontSize: 22, fontWeight: 600 }}>FCFA</span></div>
              <div style={{ fontSize: 13, opacity: 0.72, marginTop: 8 }}>Prix HT : {prixHT?.toLocaleString()} FCFA</div>
            </div>

            <div style={{ padding: '22px 28px' }}>
              <h6 style={{ color: '#006652', marginBottom: 14, fontWeight: 700, fontSize: 15 }}>
                <i className="fas fa-list-check me-2"></i>Récapitulatif du devis
              </h6>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px 18px', fontSize: 13.5, marginBottom: 22 }}>
                {[
                  ['Assuré', form.nom_assure],
                  ['Téléphone', form.telephone],
                  ['Marque', marqueSelected?.marque || '-'],
                  ['Catégorie', catSelected?.genre || '-'],
                  ['Immatriculation', form.immatriculation],
                  ['Puissance', `${form.puissance} CV`],
                  ['Places', form.nombre_place],
                  ['Carburant', form.energie === '0' ? 'Essence' : 'Gazoil'],
                  ['Quartier', form.quartier],
                  ['Durée', `${form.nombre_mois} mois`],
                  ['Date début', form.date_debut ? new Date(form.date_debut).toLocaleDateString('fr-FR') : '-'],
                  ['Carte grise', carteGriseFile ? '✓ Jointe' : '—'],
                ].map(([k, v]) => (
                  <div key={k} style={{ padding: '8px 10px', borderBottom: '1px solid #f0f2f5', borderRadius: 6 }}>
                    <div style={{ fontSize: 11, color: '#aaa', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.5px' }}>{k}</div>
                    <div style={{ fontWeight: 600, fontSize: 14, marginTop: 2 }}>{v}</div>
                  </div>
                ))}
              </div>

              {mode === 'client' && (
                <div style={{ background: '#f8f9fa', borderRadius: 8, padding: 15, marginBottom: 15 }}>
                  <div style={{ fontSize: 13, fontWeight: 700, color: '#006652', marginBottom: 10 }}>
                    <i className="fas fa-credit-card me-2"></i>Informations de paiement
                  </div>
                  <div style={{ background: '#e8f5f1', padding: '8px 12px', borderRadius: 6, marginBottom: 12, fontSize: 12 }}>
                    <i className="fas fa-phone" style={{ color: '#006652' }}></i>&nbsp;Numéro de paiement : <strong>+22799897842</strong>
                  </div>
                  <div className="form-group">
                    <label style={{ fontSize: 12, fontWeight: 600 }}>Mode de paiement *</label>
                    <select className="form-control-custom" name="mode_paiement" value={form.mode_paiement} onChange={handleChange}>
                      <option value="">-- Sélectionner --</option>
                      {['MyNita','AmanaTa','ZeynaCash','AlizzaMoney'].map(m => <option key={m} value={m}>{m}</option>)}
                    </select>
                  </div>
                  <div className="form-group">
                    <label style={{ fontSize: 12, fontWeight: 600 }}>Code de transaction *</label>
                    <input className="form-control-custom" name="code_transaction" value={form.code_transaction} onChange={handleChange} placeholder="Code reçu après paiement" />
                  </div>
                </div>
              )}

              {error && <div className="alert-custom alert-error">{error}</div>}

              <div style={{ display: 'flex', gap: 12, marginTop: 4 }}>
                <button type="button" onClick={() => setShowModal(false)} style={{
                  flex: 1, padding: '13px', border: '2px solid #e0e0e0', background: 'white',
                  borderRadius: 10, cursor: 'pointer', fontWeight: 700, fontSize: 14.5, color: '#555', transition: 'all 0.2s'
                }}
                  onMouseEnter={e => { e.currentTarget.style.borderColor = '#006652'; e.currentTarget.style.color = '#006652'; }}
                  onMouseLeave={e => { e.currentTarget.style.borderColor = '#e0e0e0'; e.currentTarget.style.color = '#555'; }}
                >
                  <i className="fas fa-arrow-left me-2"></i>Modifier
                </button>
                <button type="button" onClick={handleConfirm} disabled={loading} style={{
                  flex: 2, padding: '13px', background: loading ? '#aaa' : 'linear-gradient(to right, #28a745, #20923a)',
                  border: 'none', color: 'white', borderRadius: 10, cursor: loading ? 'not-allowed' : 'pointer',
                  fontWeight: 700, fontSize: 14.5, boxShadow: '0 4px 14px rgba(40,167,69,0.3)', transition: 'all 0.2s'
                }}>
                  {loading ? <><span className="spinner" style={{ marginRight: 8 }}></span>Enregistrement...</> : <><i className="fas fa-check-circle me-2"></i>Confirmer et valider</>}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Modal ajout marque */}
      {showAddBrand && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', zIndex: 3000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20 }}>
          <div style={{ background: 'white', borderRadius: 12, padding: 25, width: '100%', maxWidth: 380 }}>
            <h6 style={{ color: '#006652', marginBottom: 15 }}>Ajouter une nouvelle marque</h6>
            <form onSubmit={handleAddBrand}>
              <div className="form-group">
                <label>Nom de la marque</label>
                <input className="form-control-custom" value={newMarque} onChange={e => setNewMarque(e.target.value)} required />
              </div>
              <div style={{ display: 'flex', gap: 10, justifyContent: 'flex-end', marginTop: 10 }}>
                <button type="button" className="btn btn-secondary btn-sm" onClick={() => setShowAddBrand(false)}>Annuler</button>
                <button type="submit" className="btn-primary-custom">Ajouter</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
