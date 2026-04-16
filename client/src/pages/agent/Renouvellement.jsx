import { useState } from 'react';
import AgentSidebar from '../../components/AgentSidebar';
import Topbar from '../../components/Topbar';
import api from '../../api/axios';

export default function AgentRenouvellement() {
  const [search, setSearch] = useState('');
  const [results, setResults] = useState([]);
  const [searched, setSearched] = useState(false);
  const [loading, setLoading] = useState(false);
  const [modal, setModal] = useState(null);
  const [form, setForm] = useState({ date_debut: '', nombre_mois: '' });
  const [submitting, setSubmitting] = useState(false);
  const [success, setSuccess] = useState('');
  const [error, setError] = useState('');

  const today = new Date().toISOString().split('T')[0];

  const handleSearch = async e => {
    e.preventDefault();
    if (!search.trim()) return;
    setLoading(true); setSearched(true); setResults([]); setError('');
    try {
      const { data } = await api.get(`/assurances`);
      const filtered = data.filter(a =>
        a.immatriculation?.toLowerCase().includes(search.toLowerCase()) ||
        a._id?.toString().includes(search)
      );
      setResults(filtered);
    } catch { setError('Erreur lors de la recherche.'); }
    finally { setLoading(false); }
  };

  const openModal = (a) => {
    const minDate = a.date_fin ? new Date(a.date_fin).toISOString().split('T')[0] : today;
    setModal(a);
    setForm({ date_debut: minDate, nombre_mois: '' });
    setSuccess(''); setError('');
  };

  const handleRenouveler = async e => {
    e.preventDefault();
    if (!form.date_debut || !form.nombre_mois) { setError('Remplissez tous les champs.'); return; }
    setSubmitting(true); setError('');
    try {
      const { data } = await api.post(`/assurances/${modal._id}/renouveler`, form);
      setSuccess(`Contrat renouvelé ! Prix TTC : ${data.prix_ttc?.toLocaleString()} FCFA`);
      setModal(null);
      setResults(r => r.filter(x => x._id !== modal._id));
    } catch (err) { setError(err.response?.data?.message || 'Erreur.'); }
    finally { setSubmitting(false); }
  };

  const getExpiryInfo = (a) => {
    if (!a.date_fin) return { cls: 'badge-attente', label: 'Inconnue' };
    const fin = new Date(a.date_fin);
    const diff = (fin - new Date()) / (1000 * 60 * 60 * 24);
    if (diff < 0) return { cls: 'badge-expired', label: 'Expirée' };
    if (diff <= 30) return { cls: 'badge-attente', label: 'Expire bientôt' };
    return { cls: 'badge-active', label: 'Active' };
  };

  const canRenew = a => {
    if (!a.valider || a.resiliation || a.suspension) return false;
    if (!a.date_fin) return false;
    const diff = (new Date(a.date_fin) - new Date()) / (1000 * 60 * 60 * 24);
    return diff < 360;
  };

  return (
    <div className="app-shell">
      <AgentSidebar />
      <div className="main-content">
        <Topbar title="Renouvellement d'assurance" />
        <div className="page-content">

          {success && (
            <div className="alert-custom alert-success" style={{ marginBottom: 20 }}>
              <i className="fas fa-check-circle me-2"></i>{success}
            </div>
          )}

          <div className="form-card" style={{ marginBottom: 24 }}>
            <h6 style={{ color: '#006652', fontWeight: 700, marginBottom: 16, fontSize: 16 }}>
              <i className="fas fa-search me-2"></i>Rechercher une assurance
            </h6>
            <form onSubmit={handleSearch} style={{ display: 'flex', gap: 12, alignItems: 'flex-end', flexWrap: 'wrap' }}>
              <div style={{ flex: 1, minWidth: 260 }}>
                <label style={{ display: 'block', marginBottom: 6, fontSize: 13.5, fontWeight: 600, color: '#444' }}>
                  Immatriculation ou ID assurance
                </label>
                <input className="form-control-custom" value={search} onChange={e => setSearch(e.target.value)} placeholder="Ex : NI-1234-AB" required />
              </div>
              <button type="submit" className="btn-primary-custom" disabled={loading}>
                {loading ? <><span className="spinner me-2"></span>Recherche...</> : <><i className="fas fa-search me-2"></i>Rechercher</>}
              </button>
            </form>
          </div>

          {error && <div className="alert-custom alert-error mb-3"><i className="fas fa-exclamation-circle me-2"></i>{error}</div>}

          {searched && !loading && (
            results.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '50px 20px', background: 'white', borderRadius: 14, boxShadow: '0 3px 12px rgba(0,0,0,0.07)' }}>
                <i className="fas fa-search" style={{ fontSize: 48, color: '#ddd', marginBottom: 16 }}></i>
                <p style={{ color: '#888', fontSize: 16 }}>Aucune assurance trouvée pour "<strong>{search}</strong>"</p>
              </div>
            ) : (
              <div className="row g-3">
                {results.map((a, i) => {
                  const exp = getExpiryInfo(a);
                  const ok = canRenew(a);
                  return (
                    <div className="col-md-6 col-xl-4" key={a._id}>
                      <div style={{ background: 'white', borderRadius: 14, overflow: 'hidden', boxShadow: '0 4px 16px rgba(0,0,0,0.09)', transition: 'transform 0.22s', animation: `slideInUp 0.4s ease ${i * 0.06}s both` }}
                        onMouseEnter={e => e.currentTarget.style.transform = 'translateY(-4px)'}
                        onMouseLeave={e => e.currentTarget.style.transform = ''}
                      >
                        <div style={{ background: 'linear-gradient(to right, #004d3d, #006652)', color: 'white', padding: '14px 18px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                          <div style={{ fontWeight: 700, fontSize: 15 }}>
                            <i className="fas fa-car me-2"></i>{a.id_voiture?.marque || 'Véhicule'} — <code style={{ background: 'rgba(255,255,255,0.2)', padding: '2px 7px', borderRadius: 4 }}>{a.immatriculation}</code>
                          </div>
                          <span className={exp.cls} style={{ fontSize: 11 }}>{exp.label}</span>
                        </div>
                        <div style={{ padding: '16px 18px' }}>
                          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px 16px', marginBottom: 14 }}>
                            {[
                              ['Fin', a.date_fin ? new Date(a.date_fin).toLocaleDateString('fr-FR') : '-'],
                              ['Durée', `${a.nombre_mois} mois`],
                              ['Catégorie', a.id_categorie?.genre || '-'],
                              ['Prix TTC', `${(a.prix_ttc || 0).toLocaleString()} FCFA`],
                            ].map(([k, v]) => (
                              <div key={k}>
                                <div style={{ fontSize: 11, color: '#aaa', textTransform: 'uppercase' }}>{k}</div>
                                <div style={{ fontWeight: 600, fontSize: 13.5 }}>{v}</div>
                              </div>
                            ))}
                          </div>
                          <div style={{ fontSize: 13, color: '#777', marginBottom: 14 }}>
                            <i className="fas fa-user me-1" style={{ color: '#006652' }}></i> {a.clients || '-'}
                          </div>
                          <button onClick={() => openModal(a)} disabled={!ok} style={{
                            width: '100%', padding: '10px', borderRadius: 8, border: 'none',
                            background: ok ? 'linear-gradient(to right, #006652, #008a6e)' : '#ddd',
                            color: ok ? 'white' : '#aaa', fontWeight: 700, fontSize: 14, cursor: ok ? 'pointer' : 'not-allowed'
                          }}>
                            <i className="fas fa-sync-alt me-2"></i>
                            {ok ? 'Renouveler' : 'Non disponible'}
                          </button>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )
          )}

          {!searched && (
            <div style={{ textAlign: 'center', padding: '60px 20px' }}>
              <i className="fas fa-sync-alt" style={{ fontSize: 56, color: '#006652', opacity: 0.2, marginBottom: 16 }}></i>
              <p style={{ color: '#888', fontSize: 16 }}>Entrez une immatriculation pour commencer</p>
            </div>
          )}
        </div>
      </div>

      {modal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)', zIndex: 3000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20, backdropFilter: 'blur(3px)' }}>
          <div style={{ background: 'white', borderRadius: 16, width: '100%', maxWidth: 460, boxShadow: '0 24px 60px rgba(0,0,0,0.3)', animation: 'scaleIn 0.28s ease' }}>
            <div style={{ background: 'linear-gradient(to right, #004d3d, #006652)', color: 'white', padding: '18px 24px', borderRadius: '16px 16px 0 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div><div style={{ fontWeight: 800, fontSize: 17 }}>Renouveler l'assurance</div><div style={{ fontSize: 13, opacity: 0.8 }}>{modal.immatriculation}</div></div>
              <button onClick={() => setModal(null)} style={{ background: 'none', border: 'none', color: 'white', fontSize: 22, cursor: 'pointer' }}>×</button>
            </div>
            <form onSubmit={handleRenouveler} style={{ padding: '22px' }}>
              {error && <div className="alert-custom alert-error mb-3">{error}</div>}
              <div style={{ background: '#f0f4f0', borderRadius: 8, padding: '10px 14px', marginBottom: 18, fontSize: 13.5 }}>
                <strong>Client :</strong> {modal.clients || '-'} &nbsp;|&nbsp; <strong>Fin :</strong> {modal.date_fin ? new Date(modal.date_fin).toLocaleDateString('fr-FR') : '-'}
              </div>
              <div className="form-group">
                <label style={{ fontWeight: 600, marginBottom: 6, display: 'block' }}>Nouvelle date de début *</label>
                <input type="date" className="form-control-custom" value={form.date_debut} min={modal.date_fin ? new Date(modal.date_fin).toISOString().split('T')[0] : today} onChange={e => setForm(f => ({ ...f, date_debut: e.target.value }))} required />
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
              <div style={{ display: 'flex', gap: 10, marginTop: 6 }}>
                <button type="button" onClick={() => setModal(null)} style={{ flex: 1, padding: '11px', border: '2px solid #ddd', background: 'white', borderRadius: 9, cursor: 'pointer', fontWeight: 700, fontSize: 14 }}>Annuler</button>
                <button type="submit" disabled={submitting} style={{ flex: 2, padding: '11px', background: submitting ? '#aaa' : 'linear-gradient(to right, #006652, #008a6e)', border: 'none', color: 'white', borderRadius: 9, cursor: submitting ? 'not-allowed' : 'pointer', fontWeight: 700, fontSize: 14 }}>
                  {submitting ? <><span className="spinner me-2"></span>Traitement...</> : <><i className="fas fa-sync-alt me-2"></i>Confirmer</>}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
