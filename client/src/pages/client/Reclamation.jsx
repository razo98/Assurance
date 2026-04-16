import { useState, useEffect } from 'react';
import ClientSidebar from '../../components/ClientSidebar';
import Topbar from '../../components/Topbar';
import api from '../../api/axios';

const TYPES = ['Dommage matériel', 'Vol de véhicule', 'Accident', 'Service client', 'Remboursement', 'Autre'];

export default function ClientReclamation() {
  const [reclamations, setReclamations] = useState([]);
  const [assurances, setAssurances] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ id_assurance: '', type: '', description: '' });
  const [msg, setMsg] = useState('');
  const [success, setSuccess] = useState('');

  const load = () => {
    setLoading(true);
    Promise.all([api.get('/reclamations'), api.get('/assurances')])
      .then(([r, a]) => { setReclamations(r.data); setAssurances(a.data.filter(x => x.status === 'Active')); })
      .finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  const handleChange = e => setForm(f => ({ ...f, [e.target.name]: e.target.value }));

  const handleSubmit = async e => {
    e.preventDefault(); setMsg(''); setSuccess('');
    try {
      await api.post('/reclamations', form);
      setSuccess('Réclamation soumise avec succès.'); setShowForm(false);
      setForm({ id_assurance: '', type: '', description: '' }); load();
    } catch (err) { setMsg(err.response?.data?.message || 'Erreur'); }
  };

  return (
    <div className="app-shell">
      <ClientSidebar />
      <div className="main-content">
        <Topbar title="Mes réclamations" />
        <div className="page-content">
          {success && <div className="alert-custom alert-success">{success}</div>}

          {showForm ? (
            <div className="form-card" style={{ maxWidth: 600, margin: '0 auto' }}>
              <h5 style={{ color: '#006652', marginBottom: 20 }}>Nouvelle réclamation</h5>
              {msg && <div className="alert-custom alert-error">{msg}</div>}
              <form onSubmit={handleSubmit}>
                <div className="form-group"><label>Assurance concernée (optionnel)</label>
                  <select className="form-control-custom" name="id_assurance" value={form.id_assurance} onChange={handleChange}>
                    <option value="">-- Aucune en particulier --</option>
                    {assurances.map(a => <option key={a._id} value={a._id}>{a.immatriculation} - {a.id_categorie?.genre}</option>)}
                  </select>
                </div>
                <div className="form-group"><label>Type de réclamation</label>
                  <select className="form-control-custom" name="type" value={form.type} onChange={handleChange} required>
                    <option value="">-- Sélectionner --</option>
                    {TYPES.map(t => <option key={t} value={t}>{t}</option>)}
                  </select>
                </div>
                <div className="form-group"><label>Description</label>
                  <textarea className="form-control-custom" name="description" rows={5} value={form.description} onChange={handleChange} placeholder="Décrivez votre réclamation en détail..." required></textarea>
                </div>
                <div style={{ display: 'flex', gap: 10 }}>
                  <button type="button" className="btn btn-secondary" onClick={() => setShowForm(false)}>Annuler</button>
                  <button type="submit" className="btn-primary-custom"><i className="fas fa-paper-plane"></i> Soumettre</button>
                </div>
              </form>
            </div>
          ) : (
            <div className="table-card">
              <div className="table-card-header">
                <h5><i className="fas fa-exclamation-circle me-2"></i>Mes réclamations ({reclamations.length})</h5>
                <button className="btn-secondary-custom" onClick={() => setShowForm(true)}>
                  <i className="fas fa-plus"></i> Nouvelle réclamation
                </button>
              </div>
              <div className="table-responsive">
                <table className="table table-hover mb-0">
                  <thead style={{ background: '#f8f9fa' }}>
                    <tr><th>#</th><th>Type</th><th>Description</th><th>Statut</th><th>Réponse</th><th>Date</th></tr>
                  </thead>
                  <tbody>
                    {loading ? <tr><td colSpan={6} className="text-center p-4">Chargement...</td></tr> :
                    reclamations.length === 0 ? <tr><td colSpan={6} className="text-center text-muted p-4">Aucune réclamation.</td></tr> :
                    reclamations.map((r, i) => (
                      <tr key={r._id}>
                        <td>{i + 1}</td>
                        <td>{r.type}</td>
                        <td style={{ maxWidth: 200, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{r.description}</td>
                        <td><span className={r.status === 'Approuvée' ? 'badge-active' : r.status === 'Rejetée' ? 'badge-expired' : 'badge-attente'}>{r.status}</span></td>
                        <td style={{ fontSize: 12, color: '#555' }}>{r.reponse || '-'}</td>
                        <td>{new Date(r.createdAt).toLocaleDateString('fr-FR')}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
