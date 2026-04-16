import { useState, useEffect } from 'react';
import AgentSidebar from '../../components/AgentSidebar';
import Topbar from '../../components/Topbar';
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
                  <tr><th>#</th><th>Client</th><th>Immatriculation</th><th>Catégorie</th><th>Prix TTC</th><th>Statut</th><th>Actions</th></tr>
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
    </div>
  );
}
