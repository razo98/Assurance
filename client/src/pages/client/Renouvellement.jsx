import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import ClientSidebar from '../../components/ClientSidebar';
import Topbar from '../../components/Topbar';
import { useAuth } from '../../context/AuthContext';
import api from '../../api/axios';

export default function ClientRenouvellement() {
  const { user } = useAuth();
  const [assurances, setAssurances] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState(null);
  const [form, setForm] = useState({ date_debut: '', nombre_mois: '', mode_paiement: '', code_transaction: '' });
  const [prix, setPrix] = useState(null);
  const [prixCalcLoading, setPrixCalcLoading] = useState(false);
  const [showPayment, setShowPayment] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [success, setSuccess] = useState('');
  const [error, setError] = useState('');

  const today = new Date().toISOString().split('T')[0];

  useEffect(() => {
    api.get('/assurances')
      .then(r => {
        // Filtrer : actives, non résiliées, non suspendues, validées
        const eligibles = r.data.filter(a => a.valider && !a.resiliation && !a.suspension);
        setAssurances(eligibles);
      })
      .finally(() => setLoading(false));
  }, []);

  const getExpiryInfo = (a) => {
    if (!a.date_fin) return { cls: 'badge-attente', label: 'Inconnue', canRenew: false };
    const fin = new Date(a.date_fin);
    const diff = (fin - new Date()) / (1000 * 60 * 60 * 24);
    if (diff < 0) return { cls: 'badge-expired', label: 'Expirée', canRenew: true };
    if (diff <= 30) return { cls: 'badge-attente', label: 'Expire bientôt', canRenew: true };
    if (diff <= 300) return { cls: 'badge-active', label: 'Active', canRenew: true };
    return { cls: 'badge-active', label: 'Active', canRenew: false };
  };

  const openModal = (a) => {
    const minDate = a.date_fin ? new Date(a.date_fin).toISOString().split('T')[0] : today;
    setModal(a);
    setForm({ date_debut: minDate, nombre_mois: '', mode_paiement: '', code_transaction: '' });
    setPrix(null); setShowPayment(false); setError('');
  };

  const handleCalculer = async () => {
    if (!form.nombre_mois || !form.date_debut) { setError('Sélectionnez la durée et la date de début.'); return; }
    const cat = modal.id_categorie;
    const genre = cat?.genre || '';
    setPrixCalcLoading(true); setError('');
    try {
      const { data } = await api.get(`/prix/calculer?genre=${encodeURIComponent(genre)}&energie=${modal.energie}&puissance=${modal.puissance}&nombre_mois=${form.nombre_mois}`);
      if (data.success) {
        setPrix(data.prix);
        setShowPayment(true);
      } else {
        setError(data.message || 'Impossible de calculer le prix.');
      }
    } catch { setError('Erreur lors du calcul du prix.'); }
    finally { setPrixCalcLoading(false); }
  };

  const handleConfirm = async () => {
    if (!form.mode_paiement || !form.code_transaction) { setError('Remplissez le mode et le code de paiement.'); return; }
    setSubmitting(true); setError('');
    try {
      await api.post(`/assurances/${modal._id}/renouveler`, {
        date_debut: form.date_debut,
        nombre_mois: form.nombre_mois,
        mode_paiement: form.mode_paiement,
        code_transaction: form.code_transaction,
      });
      setSuccess(`Renouvellement effectué ! Votre nouveau contrat est en attente de validation.`);
      setModal(null);
      setAssurances(prev => prev.filter(a => a._id !== modal._id));
    } catch (err) { setError(err.response?.data?.message || 'Erreur lors du renouvellement.'); }
    finally { setSubmitting(false); }
  };

  return (
    <div className="app-shell">
      <ClientSidebar />
      <div className="main-content">
        <Topbar title="Renouvellement d'assurance" />
        <div className="page-content">

          {success && (
            <div className="alert-custom alert-success" style={{ marginBottom: 20 }}>
              <i className="fas fa-check-circle me-2"></i>{success}
            </div>
          )}

          {loading ? (
            <div style={{ textAlign: 'center', padding: 60 }}>
              <div className="spinner" style={{ width: 44, height: 44, borderWidth: 4, borderColor: '#006652', borderTopColor: 'transparent' }}></div>
              <div style={{ marginTop: 14, color: '#666' }}>Chargement de vos assurances...</div>
            </div>
          ) : assurances.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '60px 20px', background: 'white', borderRadius: 14, boxShadow: '0 3px 12px rgba(0,0,0,0.07)' }}>
              <i className="fas fa-shield-alt" style={{ fontSize: 56, color: '#006652', opacity: 0.2, marginBottom: 16 }}></i>
              <h5 style={{ color: '#555', marginBottom: 10 }}>Aucune assurance à renouveler</h5>
              <p style={{ color: '#888', marginBottom: 24 }}>Vous n'avez pas encore de contrat validé.</p>
              <Link to="/client/devis" className="btn-secondary-custom" style={{ textDecoration: 'none', display: 'inline-flex', alignItems: 'center', gap: 8 }}>
                <i className="fas fa-calculator"></i>Faire un devis
              </Link>
            </div>
          ) : (
            <div className="row g-3">
              {assurances.map((a, i) => {
                const exp = getExpiryInfo(a);
                return (
                  <div className="col-md-6 col-xl-4" key={a._id}>
                    <div style={{
                      background: 'white', borderRadius: 14, overflow: 'hidden',
                      boxShadow: '0 4px 16px rgba(0,0,0,0.09)',
                      transition: 'transform 0.22s, box-shadow 0.22s',
                      animation: `slideInUp 0.4s ease ${i * 0.07}s both`
                    }}
                      onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-4px)'; e.currentTarget.style.boxShadow = '0 12px 28px rgba(0,0,0,0.13)'; }}
                      onMouseLeave={e => { e.currentTarget.style.transform = ''; e.currentTarget.style.boxShadow = '0 4px 16px rgba(0,0,0,0.09)'; }}
                    >
                      {/* Header */}
                      <div style={{ background: 'linear-gradient(to right, #004d3d, #006652)', color: 'white', padding: '14px 18px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <div style={{ fontWeight: 700, fontSize: 15 }}>
                          <i className="fas fa-car me-2"></i>
                          {a.id_voiture?.marque || 'Véhicule'} — <code style={{ background: 'rgba(255,255,255,0.2)', padding: '2px 7px', borderRadius: 4 }}>{a.immatriculation}</code>
                        </div>
                        <span className={exp.cls} style={{ fontSize: 11 }}>{exp.label}</span>
                      </div>

                      {/* Body */}
                      <div style={{ padding: '16px 18px' }}>
                        {/* Dates */}
                        <div style={{ display: 'flex', gap: 10, marginBottom: 16 }}>
                          {[
                            ['Début', a.date_debut ? new Date(a.date_debut).toLocaleDateString('fr-FR') : '-'],
                            ['Fin', a.date_fin ? new Date(a.date_fin).toLocaleDateString('fr-FR') : '-'],
                          ].map(([k, v]) => (
                            <div key={k} style={{ flex: 1, background: '#f8faf9', borderRadius: 8, padding: '10px', textAlign: 'center' }}>
                              <div style={{ fontSize: 11, color: '#aaa', textTransform: 'uppercase', marginBottom: 4 }}>{k}</div>
                              <div style={{ fontWeight: 700, fontSize: 13.5 }}>{v}</div>
                            </div>
                          ))}
                        </div>

                        {/* Infos */}
                        {[
                          { icon: 'fas fa-tachometer-alt', label: 'Puissance', val: `${a.puissance} CV` },
                          { icon: 'fas fa-calendar-alt', label: 'Durée', val: `${a.nombre_mois} mois` },
                          { icon: 'fas fa-money-bill-wave', label: 'Prix TTC', val: `${(a.prix_ttc || 0).toLocaleString()} FCFA` },
                          { icon: 'fas fa-tags', label: 'Catégorie', val: a.id_categorie?.genre || '-' },
                        ].map(({ icon, label, val }) => (
                          <div key={label} style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 9 }}>
                            <i className={icon} style={{ color: '#006652', width: 18, textAlign: 'center', fontSize: 14 }}></i>
                            <span style={{ color: '#555', fontSize: 13.5 }}><strong>{label} :</strong> {val}</span>
                          </div>
                        ))}

                        <button
                          onClick={() => openModal(a)}
                          disabled={!exp.canRenew}
                          style={{
                            width: '100%', marginTop: 12, padding: '11px', borderRadius: 9, border: 'none',
                            background: exp.canRenew ? 'linear-gradient(to right, #006652, #008a6e)' : '#e0e0e0',
                            color: exp.canRenew ? 'white' : '#999',
                            fontWeight: 700, fontSize: 14,
                            cursor: exp.canRenew ? 'pointer' : 'not-allowed',
                            transition: 'all 0.2s'
                          }}
                        >
                          <i className="fas fa-sync-alt me-2"></i>
                          {exp.canRenew ? 'Renouveler ce contrat' : 'Renouvellement non disponible'}
                        </button>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* ===== MODAL RENOUVELLEMENT CLIENT ===== */}
      {modal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.65)', zIndex: 3000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20, backdropFilter: 'blur(4px)' }}>
          <div style={{ background: 'white', borderRadius: 16, width: '100%', maxWidth: 520, maxHeight: '92vh', overflowY: 'auto', boxShadow: '0 28px 70px rgba(0,0,0,0.35)', animation: 'scaleIn 0.28s ease' }}>

            {/* Header */}
            <div style={{ background: 'linear-gradient(135deg, #004d3d, #006652)', color: 'white', padding: '20px 26px', borderRadius: '16px 16px 0 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontWeight: 800, fontSize: 18 }}>Renouveler l'assurance</div>
                <div style={{ fontSize: 13, opacity: 0.8 }}>{modal.id_voiture?.marque} — {modal.immatriculation}</div>
              </div>
              <button onClick={() => setModal(null)} style={{ background: 'none', border: 'none', color: 'white', fontSize: 24, cursor: 'pointer' }}>×</button>
            </div>

            <div style={{ padding: '22px 26px' }}>
              {error && <div className="alert-custom alert-error mb-3"><i className="fas fa-exclamation-circle me-2"></i>{error}</div>}

              {/* Résumé assurance */}
              <div style={{ background: '#f0f7f5', borderRadius: 10, padding: '14px 16px', marginBottom: 20, fontSize: 13.5 }}>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px 16px' }}>
                  <div><span style={{ color: '#888' }}>Catégorie :</span> <strong>{modal.id_categorie?.genre || '-'}</strong></div>
                  <div><span style={{ color: '#888' }}>Puissance :</span> <strong>{modal.puissance} CV</strong></div>
                  <div><span style={{ color: '#888' }}>Fin actuelle :</span> <strong>{modal.date_fin ? new Date(modal.date_fin).toLocaleDateString('fr-FR') : '-'}</strong></div>
                  <div><span style={{ color: '#888' }}>Énergie :</span> <strong>{modal.energie === 0 || modal.energie === '0' ? 'Essence' : 'Gazoil'}</strong></div>
                </div>
              </div>

              {/* Affichage du prix calculé */}
              {prix && (
                <div style={{ background: 'linear-gradient(to right, #004d3d, #006652)', color: 'white', borderRadius: 12, padding: '18px', textAlign: 'center', marginBottom: 20, animation: 'scaleIn 0.3s ease' }}>
                  <div style={{ fontSize: 12, opacity: 0.8, textTransform: 'uppercase', letterSpacing: '1px', marginBottom: 6 }}>Prix total à payer (TVA 12% incluse)</div>
                  <div style={{ fontSize: 40, fontWeight: 800 }}>{prix.toLocaleString()} <span style={{ fontSize: 20, fontWeight: 600 }}>FCFA</span></div>
                  <div style={{ fontSize: 12, opacity: 0.7, marginTop: 6 }}>Durée : {form.nombre_mois} mois — Début : {form.date_debut}</div>
                </div>
              )}

              {!showPayment ? (
                <>
                  <div className="form-group">
                    <label style={{ fontWeight: 600, marginBottom: 6, display: 'block' }}>Nouvelle date de début *</label>
                    <input type="date" className="form-control-custom"
                      value={form.date_debut}
                      min={modal.date_fin ? new Date(modal.date_fin).toISOString().split('T')[0] : today}
                      onChange={e => setForm(f => ({ ...f, date_debut: e.target.value }))}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label style={{ fontWeight: 600, marginBottom: 6, display: 'block' }}>Durée *</label>
                    <select className="form-control-custom" value={form.nombre_mois} onChange={e => setForm(f => ({ ...f, nombre_mois: e.target.value }))} required>
                      <option value="">-- Sélectionner --</option>
                      <option value="3">3 mois</option>
                      <option value="6">6 mois</option>
                      <option value="12">12 mois</option>
                    </select>
                  </div>
                  <div style={{ textAlign: 'center', marginTop: 8 }}>
                    <button onClick={handleCalculer} disabled={prixCalcLoading} style={{
                      background: prixCalcLoading ? '#aaa' : 'linear-gradient(to right, #006652, #FF8C00)',
                      border: 'none', color: 'white', padding: '13px 40px',
                      borderRadius: 30, fontSize: 16, fontWeight: 700, cursor: prixCalcLoading ? 'not-allowed' : 'pointer',
                      boxShadow: '0 6px 20px rgba(0,102,82,0.3)'
                    }}>
                      {prixCalcLoading ? <><span className="spinner me-2"></span>Calcul...</> : <><i className="fas fa-calculator me-2"></i>Calculer le prix</>}
                    </button>
                  </div>
                </>
              ) : (
                <>
                  {/* Section paiement */}
                  <div style={{ background: '#f8f9fa', borderRadius: 10, padding: '18px', marginBottom: 18 }}>
                    <div style={{ fontSize: 15, fontWeight: 700, color: '#006652', marginBottom: 14 }}>
                      <i className="fas fa-credit-card me-2"></i>Informations de paiement
                    </div>
                    <div style={{ background: '#e8f5f1', padding: '10px 14px', borderRadius: 8, marginBottom: 14, fontSize: 13 }}>
                      <i className="fas fa-phone" style={{ color: '#006652', marginRight: 8 }}></i>
                      Numéro de paiement : <strong>+22799897842</strong>
                    </div>
                    <div className="form-group">
                      <label style={{ fontWeight: 600, marginBottom: 6, display: 'block', fontSize: 13.5 }}>Mode de paiement *</label>
                      <select className="form-control-custom" value={form.mode_paiement} onChange={e => setForm(f => ({ ...f, mode_paiement: e.target.value }))}>
                        <option value="">-- Sélectionner --</option>
                        {['MyNita', 'AmanaTa', 'ZeynaCash', 'AlizzaMoney'].map(m => <option key={m} value={m}>{m}</option>)}
                      </select>
                    </div>
                    <div className="form-group">
                      <label style={{ fontWeight: 600, marginBottom: 6, display: 'block', fontSize: 13.5 }}>Code de transaction *</label>
                      <input className="form-control-custom" value={form.code_transaction} onChange={e => setForm(f => ({ ...f, code_transaction: e.target.value }))} placeholder="Code reçu après paiement" />
                    </div>
                  </div>

                  <div style={{ display: 'flex', gap: 10 }}>
                    <button onClick={() => { setShowPayment(false); setPrix(null); }} style={{
                      flex: 1, padding: '12px', border: '2px solid #ddd', background: 'white',
                      borderRadius: 10, cursor: 'pointer', fontWeight: 700, fontSize: 14
                    }}>
                      <i className="fas fa-arrow-left me-2"></i>Modifier
                    </button>
                    <button onClick={handleConfirm} disabled={submitting} style={{
                      flex: 2, padding: '12px',
                      background: submitting ? '#aaa' : 'linear-gradient(to right, #28a745, #20923a)',
                      border: 'none', color: 'white', borderRadius: 10,
                      cursor: submitting ? 'not-allowed' : 'pointer',
                      fontWeight: 700, fontSize: 14, boxShadow: '0 4px 14px rgba(40,167,69,0.3)'
                    }}>
                      {submitting ? <><span className="spinner me-2"></span>Traitement...</> : <><i className="fas fa-check-circle me-2"></i>Confirmer le renouvellement</>}
                    </button>
                  </div>
                </>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
