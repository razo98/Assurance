import { useState, useEffect } from 'react';
import AdminSidebar from '../../components/AdminSidebar';
import Topbar from '../../components/Topbar';
import api from '../../api/axios';

export default function Agents() {
  const [agents, setAgents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({ firstname: '', lastname: '', username: '', email: '', number: '', password: '', role: 'agent', quartier: '' });
  const [msg, setMsg] = useState('');

  const QUARTIERS = ['Francophonie', 'Bobiel', 'Sonuci', 'Tchangarey', 'Ryad', 'Dar As Salam', 'Plateau', 'Recasement', 'Cite Chinoise'];

  const load = () => {
    setLoading(true);
    api.get('/admins').then(r => setAgents(r.data)).finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  const openAdd = () => { setEditing(null); setForm({ firstname: '', lastname: '', username: '', email: '', number: '', password: '', role: 'agent', quartier: '' }); setShowModal(true); setMsg(''); };
  const openEdit = (a) => { setEditing(a); setForm({ firstname: a.firstname, lastname: a.lastname, username: a.username, email: a.email, number: a.number, password: '', role: a.role, quartier: a.quartier || '' }); setShowModal(true); setMsg(''); };
  const handleChange = e => setForm(f => ({ ...f, [e.target.name]: e.target.value }));

  const handleSubmit = async e => {
    e.preventDefault();
    try {
      if (editing) await api.put(`/admins/${editing._id}`, form);
      else await api.post('/admins', form);
      setShowModal(false); load();
    } catch (err) { setMsg(err.response?.data?.message || 'Erreur'); }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Supprimer ce compte ?')) return;
    await api.delete(`/admins/${id}`);
    load();
  };

  const filtered = agents.filter(a =>
    `${a.firstname} ${a.lastname} ${a.email} ${a.matricule}`.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="app-shell">
      <AdminSidebar />
      <div className="main-content">
        <Topbar title="Gestion des agents" />
        <div className="page-content">
          <div className="table-card">
            <div className="table-card-header">
              <h5><i className="fas fa-user-tie me-2"></i>Admins & Agents ({filtered.length})</h5>
              <div style={{ display: 'flex', gap: 10 }}>
                <input type="text" className="form-control form-control-sm" placeholder="Rechercher..." value={search} onChange={e => setSearch(e.target.value)} style={{ width: 200 }} />
                <button className="btn-primary-custom" onClick={openAdd}><i className="fas fa-plus"></i> Ajouter</button>
              </div>
            </div>
            <div className="table-responsive">
              <table className="table table-hover mb-0">
                <thead style={{ background: '#f8f9fa' }}>
                  <tr><th>#</th><th>Matricule</th><th>Nom complet</th><th>Email</th><th>Rôle</th><th>Quartier</th><th>Actions</th></tr>
                </thead>
                <tbody>
                  {loading ? <tr><td colSpan={7} className="text-center p-4">Chargement...</td></tr> :
                  filtered.map((a, i) => (
                    <tr key={a._id}>
                      <td>{i + 1}</td>
                      <td><code>{a.matricule}</code></td>
                      <td><strong>{a.firstname} {a.lastname}</strong></td>
                      <td>{a.email}</td>
                      <td>
                        <span className={a.role === 'admin' ? 'badge-active' : 'badge-suspended'}>
                          {a.role === 'admin' ? 'Admin' : 'Agent'}
                        </span>
                      </td>
                      <td>{a.quartier || '-'}</td>
                      <td>
                        <button className="btn btn-sm btn-outline-primary me-1" onClick={() => openEdit(a)}><i className="fas fa-edit"></i></button>
                        <button className="btn btn-sm btn-outline-danger" onClick={() => handleDelete(a._id)}><i className="fas fa-trash"></i></button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      {showModal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', zIndex: 2000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20 }}>
          <div style={{ background: 'white', borderRadius: 12, padding: 30, width: '100%', maxWidth: 520, maxHeight: '90vh', overflowY: 'auto' }}>
            <h5 style={{ color: '#006652', marginBottom: 20 }}>{editing ? 'Modifier le compte' : 'Ajouter un admin/agent'}</h5>
            {msg && <div className="alert-custom alert-error">{msg}</div>}
            <form onSubmit={handleSubmit}>
              <div className="row g-2">
                <div className="col-6"><div className="form-group"><label>Prénom</label><input className="form-control-custom" name="firstname" value={form.firstname} onChange={handleChange} required /></div></div>
                <div className="col-6"><div className="form-group"><label>Nom</label><input className="form-control-custom" name="lastname" value={form.lastname} onChange={handleChange} required /></div></div>
              </div>
              <div className="form-group"><label>Username</label><input className="form-control-custom" name="username" value={form.username} onChange={handleChange} required /></div>
              <div className="form-group"><label>Email</label><input type="email" className="form-control-custom" name="email" value={form.email} onChange={handleChange} required /></div>
              <div className="form-group"><label>Téléphone</label><input className="form-control-custom" name="number" value={form.number} onChange={handleChange} required /></div>
              <div className="form-group"><label>Rôle</label>
                <select className="form-control-custom" name="role" value={form.role} onChange={handleChange}>
                  <option value="agent">Agent</option>
                  <option value="admin">Administrateur</option>
                </select>
              </div>
              <div className="form-group"><label>Quartier</label>
                <select className="form-control-custom" name="quartier" value={form.quartier} onChange={handleChange}>
                  <option value="">-- Sélectionner --</option>
                  {QUARTIERS.map(q => <option key={q} value={q}>{q}</option>)}
                </select>
              </div>
              <div className="form-group"><label>{editing ? 'Nouveau mot de passe (optionnel)' : 'Mot de passe'}</label><input type="password" className="form-control-custom" name="password" value={form.password} onChange={handleChange} required={!editing} /></div>
              <div style={{ display: 'flex', gap: 10, justifyContent: 'flex-end', marginTop: 10 }}>
                <button type="button" className="btn btn-secondary" onClick={() => setShowModal(false)}>Annuler</button>
                <button type="submit" className="btn-primary-custom">{editing ? 'Modifier' : 'Ajouter'}</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
