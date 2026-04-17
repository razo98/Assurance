import { useState, useEffect } from 'react';
import AgentSidebar from '../../components/AgentSidebar';
import Topbar from '../../components/Topbar';
import AttestationModal from '../../components/AttestationModal';
import api from '../../api/axios';

const STATUS_BADGE = {
  'Active': 'badge-active', 'En attente': 'badge-attente',
  'Expirée': 'badge-expired', 'Suspendue': 'badge-suspended', 'Résiliée': 'badge-resilie'
};

export default function AgentAssurances() {
  const [assurances, setAssurances] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [attestation, setAttestation] = useState(null);
  const [carteGriseModal, setCarteGriseModal] = useState(null);

  const load = () => { setLoading(true); api.get('/assurances').then(r => setAssurances(r.data)).finally(() => setLoading(false)); };
  useEffect(() => { load(); }, []);

  const action = async (id, endpoint) => {
    if (!window.confirm('Confirmer cette action ?')) return;
    await api.post(`/assurances/${id}/${endpoint}`); load();
  };

  const filtered = assurances.filter(a => {
    const matchSearch = `${a.clients} ${a.immatriculation}`.toLowerCase().includes(search.toLowerCase());
    const matchStatus = filterStatus ? a.status === filterStatus : true;
    return matchSearch && matchStatus;
  });

  return (
    <div className="app-shell">
      <AgentSidebar />
      <div className="main-content">
        <Topbar title="Mes assurances" />
        <div className="page-content">
          <div className="table-card">
            <div className="table-card-header">
              <h5><i className="fas fa-shield-alt me-2"></i>Assurances ({filtered.length})</h5>
              <div style={{ display: 'flex', gap: 10 }}>
                <select className="form-select form-select-sm" value={filterStatus} onChange={e => setFilterStatus(e.target.value)} style={{ width: 140 }}>
                  <option value="">Tous</option>
                  {['Active','En attente','Expirée','Suspendue','Résiliée'].map(s => <option key={s} value={s}>{s}</option>)}
                </select>
                <input type="text" className="form-control form-control-sm" placeholder="Rechercher..." value={search} onChange={e => setSearch(e.target.value)} style={{ width: 200 }} />
              </div>
            </div>
            <div className="table-responsive">
              <table className="table table-hover mb-0" style={{ fontSize: 13 }}>
                <thead style={{ background: '#f8f9fa' }}>
                  <tr><th>#</th><th>Client</th><th>Immatriculation</th><th>Catégorie</th><th>Prix TTC</th><th>Statut</th><th>Aperçu</th><th>Actions</th></tr>
                </thead>
                <tbody>
                  {loading ? <tr><td colSpan={7} className="text-center p-4">Chargement...</td></tr> :
                  filtered.map((a, i) => (
                    <tr key={a._id}>
                      <td>{i + 1}</td>
                      <td>{a.clients}</td>
                      <td><code>{a.immatriculation}</code></td>
                      <td>{a.id_categorie?.genre || '-'}</td>
                      <td><strong>{(a.prix_ttc || 0).toLocaleString()} FCFA</strong></td>
                      <td><span className={STATUS_BADGE[a.status] || 'badge-attente'}>{a.status}</span></td>
                      <td>
                        <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap' }}>
                          <button className="btn btn-xs" title="Attestation" disabled={!a.valider}
                            style={{ fontSize: 11, padding: '2px 8px', background: a.valider ? 'linear-gradient(to right,#006652,#008a6e)' : '#ddd', color: a.valider ? 'white' : '#aaa', border: 'none', borderRadius: 4, cursor: a.valider ? 'pointer' : 'not-allowed' }}
                            onClick={() => a.valider && setAttestation(a)}>
                            <i className="fas fa-file-alt me-1"></i>Attest.
                          </button>
                          <button className="btn btn-xs" title="Carte grise" disabled={!a.carte_grise}
                            style={{ fontSize: 11, padding: '2px 8px', background: a.carte_grise ? 'linear-gradient(to right,#0d6efd,#0a58ca)' : '#ddd', color: a.carte_grise ? 'white' : '#aaa', border: 'none', borderRadius: 4, cursor: a.carte_grise ? 'pointer' : 'not-allowed' }}
                            onClick={() => a.carte_grise && setCarteGriseModal({ url: `http://localhost:5000${a.carte_grise}`, nom_assure: a.nom_assure, immatriculation: a.immatriculation })}>
                            <i className="fas fa-id-card me-1"></i>C.grise
                          </button>
                        </div>
                      </td>
                      <td>
                        <div style={{ display: 'flex', gap: 3 }}>
                          {a.status === 'En attente' && <button className="btn btn-xs btn-success" style={{ fontSize: 11, padding: '2px 7px' }} onClick={() => action(a._id, 'valider')}><i className="fas fa-check"></i></button>}
                          {a.status === 'Active' && <button className="btn btn-xs btn-warning" style={{ fontSize: 11, padding: '2px 7px' }} onClick={() => action(a._id, 'suspendre')}><i className="fas fa-pause"></i></button>}
                          {a.status === 'Active' && <button className="btn btn-xs btn-danger" style={{ fontSize: 11, padding: '2px 7px' }} onClick={() => action(a._id, 'resilier')}><i className="fas fa-ban"></i></button>}
                          {(a.status === 'Résiliée' || a.status === 'Suspendue') && <button className="btn btn-xs btn-info" style={{ fontSize: 11, padding: '2px 7px' }} onClick={() => action(a._id, 'restaurer')}><i className="fas fa-undo"></i></button>}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
      {attestation && <AttestationModal assurance={attestation} onClose={() => setAttestation(null)} />}

      {carteGriseModal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.75)', zIndex: 5000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20, backdropFilter: 'blur(4px)' }}>
          <div style={{ background: 'white', borderRadius: 16, width: '100%', maxWidth: 560, boxShadow: '0 30px 80px rgba(0,0,0,0.4)', animation: 'scaleIn 0.28s ease' }}>
            <div style={{ background: 'linear-gradient(to right,#0d6efd,#0a58ca)', color: 'white', padding: '16px 22px', borderRadius: '16px 16px 0 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontWeight: 800, fontSize: 16 }}><i className="fas fa-id-card me-2"></i>Carte grise</div>
                <div style={{ fontSize: 12, opacity: 0.85 }}>{carteGriseModal.immatriculation} — {carteGriseModal.nom_assure || 'Assuré'}</div>
              </div>
              <button onClick={() => setCarteGriseModal(null)} style={{ background: 'none', border: 'none', color: 'white', fontSize: 22, cursor: 'pointer' }}>×</button>
            </div>
            <div style={{ padding: 20 }}>
              <img src={carteGriseModal.url} alt="Carte grise" style={{ width: '100%', borderRadius: 10, boxShadow: '0 4px 20px rgba(0,0,0,0.15)', objectFit: 'contain', maxHeight: 400 }} />
              {carteGriseModal.nom_assure && (
                <div style={{ marginTop: 14, background: '#f0f9f6', borderRadius: 8, padding: '10px 14px', fontSize: 13 }}>
                  <i className="fas fa-user me-2" style={{ color: '#006652' }}></i>
                  <strong>Assuré :</strong> {carteGriseModal.nom_assure}
                </div>
              )}
              <div style={{ display: 'flex', gap: 10, marginTop: 14 }}>
                <a href={carteGriseModal.url} download target="_blank" rel="noreferrer"
                  style={{ flex: 1, padding: '10px', background: 'linear-gradient(to right,#0d6efd,#0a58ca)', color: 'white', border: 'none', borderRadius: 8, fontWeight: 700, fontSize: 13, cursor: 'pointer', textAlign: 'center', textDecoration: 'none' }}>
                  <i className="fas fa-download me-1"></i>Télécharger
                </a>
                <button onClick={() => setCarteGriseModal(null)}
                  style={{ flex: 1, padding: '10px', background: '#f0f0f0', border: 'none', borderRadius: 8, fontWeight: 600, fontSize: 13, cursor: 'pointer' }}>
                  Fermer
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
