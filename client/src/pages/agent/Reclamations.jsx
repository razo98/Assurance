import { useState, useEffect } from 'react';
import AgentSidebar from '../../components/AgentSidebar';
import Topbar from '../../components/Topbar';
import api from '../../api/axios';

export default function AgentReclamations() {
  const [reclamations, setReclamations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState(null);
  const [reponse, setReponse] = useState('');
  const [status, setStatus] = useState('Approuvée');

  const load = () => { setLoading(true); api.get('/reclamations').then(r => setReclamations(r.data)).finally(() => setLoading(false)); };
  useEffect(() => { load(); }, []);

  const handleTraiter = async (id) => {
    try { await api.put(`/reclamations/${id}`, { status, reponse }); setSelected(null); load(); }
    catch (err) { alert(err.response?.data?.message || 'Erreur'); }
  };

  return (
    <div className="app-shell">
      <AgentSidebar />
      <div className="main-content">
        <Topbar title="Réclamations" />
        <div className="page-content">
          <div className="table-card">
            <div className="table-card-header"><h5><i className="fas fa-exclamation-circle me-2"></i>Réclamations ({reclamations.length})</h5></div>
            <div className="table-responsive">
              <table className="table table-hover mb-0">
                <thead style={{ background: '#f8f9fa' }}>
                  <tr><th>#</th><th>Client</th><th>Type</th><th>Statut</th><th>Date</th><th>Actions</th></tr>
                </thead>
                <tbody>
                  {loading ? <tr><td colSpan={6} className="text-center p-4">Chargement...</td></tr> :
                  reclamations.map((r, i) => (
                    <tr key={r._id}>
                      <td>{i + 1}</td>
                      <td>{r.iduser?.firstname} {r.iduser?.lastname}</td>
                      <td>{r.type}</td>
                      <td><span className={r.status === 'Approuvée' ? 'badge-active' : r.status === 'Rejetée' ? 'badge-expired' : 'badge-attente'}>{r.status}</span></td>
                      <td>{new Date(r.createdAt).toLocaleDateString('fr-FR')}</td>
                      <td>{r.status === 'En attente' && <button className="btn btn-sm btn-outline-primary" onClick={() => { setSelected(r); setReponse(''); setStatus('Approuvée'); }}><i className="fas fa-reply"></i></button>}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
      {selected && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', zIndex: 2000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20 }}>
          <div style={{ background: 'white', borderRadius: 12, padding: 30, width: '100%', maxWidth: 500 }}>
            <h5 style={{ color: '#006652', marginBottom: 15 }}>Traiter la réclamation</h5>
            <p><strong>Type :</strong> {selected.type}</p>
            <p><strong>Description :</strong> {selected.description}</p>
            <div className="form-group"><label>Décision</label>
              <select className="form-control-custom" value={status} onChange={e => setStatus(e.target.value)}>
                <option value="Approuvée">Approuvée</option><option value="Rejetée">Rejetée</option>
              </select>
            </div>
            <div className="form-group"><label>Réponse</label><textarea className="form-control-custom" rows={4} value={reponse} onChange={e => setReponse(e.target.value)}></textarea></div>
            <div style={{ display: 'flex', gap: 10, justifyContent: 'flex-end' }}>
              <button className="btn btn-secondary" onClick={() => setSelected(null)}>Annuler</button>
              <button className="btn-primary-custom" onClick={() => handleTraiter(selected._id)}>Confirmer</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
