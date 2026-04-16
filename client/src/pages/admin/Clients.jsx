import { useState, useEffect } from 'react';
import AdminSidebar from '../../components/AdminSidebar';
import Topbar from '../../components/Topbar';
import api from '../../api/axios';

export default function Clients() {
  const [clients, setClients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({ firstname: '', lastname: '', username: '', email: '', number: '', password: '' });
  const [msg, setMsg] = useState('');

  const load = () => {
    setLoading(true);
    api.get('/users').then(r => setClients(r.data)).finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  const openAdd = () => { setEditing(null); setForm({ firstname: '', lastname: '', username: '', email: '', number: '', password: '' }); setShowModal(true); setMsg(''); };
  const openEdit = (c) => { setEditing(c); setForm({ firstname: c.firstname, lastname: c.lastname, username: c.username, email: c.email, number: c.number, password: '' }); setShowModal(true); setMsg(''); };
  const handleChange = e => setForm(f => ({ ...f, [e.target.name]: e.target.value }));

  const handleSubmit = async e => {
    e.preventDefault();
    try {
      if (editing) await api.put(`/users/${editing._id}`, form);
      else await api.post('/users', form);
      setShowModal(false); load();
    } catch (err) { setMsg(err.response?.data?.message || 'Erreur'); }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Supprimer ce client ?')) return;
    await api.delete(`/users/${id}`);
    load();
  };

  const filtered = clients.filter(c =>
    `${c.firstname} ${c.lastname} ${c.email} ${c.username}`.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="app-shell">
      <AdminSidebar />
      <div className="main-content">
        <Topbar title="Gestion des clients" />
        <div className="page-content">
          <div className="table-card">
            <div className="table-card-header">
              <h5><i className="fas fa-users me-2"></i>Clients ({filtered.length})</h5>
              <div style={{ display: 'flex', gap: 10 }}>
                <input type="text" className="form-control form-control-sm" placeholder="Rechercher..." value={search} onChange={e => setSearch(e.target.value)} style={{ width: 200 }} />
                <button className="btn-primary-custom" onClick={openAdd}>
                  <i className="fas fa-plus"></i> Ajouter
                </button>
              </div>
            </div>
            <div className="table-responsive">
              <table className="table table-hover mb-0">
                <thead style={{ background: '#f8f9fa' }}>
                  <tr>
                    <th>#</th><th>Nom complet</th><th>Username</th><th>Email</th><th>Téléphone</th><th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {loading ? <tr><td colSpan={6} className="text-center p-4">Chargement...</td></tr> :
                  filtered.map((c, i) => (
                    <tr key={c._id}>
                      <td>{i + 1}</td>
                      <td><strong>{c.firstname} {c.lastname}</strong></td>
                      <td>{c.username}</td>
                      <td>{c.email}</td>
                      <td>{c.number}</td>
                      <td>
                        <button className="btn btn-sm btn-outline-primary me-1" onClick={() => openEdit(c)}>
                          <i className="fas fa-edit"></i>
                        </button>
                        <button className="btn btn-sm btn-outline-danger" onClick={() => handleDelete(c._id)}>
                          <i className="fas fa-trash"></i>
                        </button>
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
          <div style={{ background: 'white', borderRadius: 12, padding: 30, width: '100%', maxWidth: 500 }}>
            <h5 style={{ color: '#006652', marginBottom: 20 }}>{editing ? 'Modifier le client' : 'Ajouter un client'}</h5>
            {msg && <div className="alert-custom alert-error">{msg}</div>}
            <form onSubmit={handleSubmit}>
              <div className="row g-2">
                <div className="col-6"><div className="form-group"><label>Prénom</label><input className="form-control-custom" name="firstname" value={form.firstname} onChange={handleChange} required /></div></div>
                <div className="col-6"><div className="form-group"><label>Nom</label><input className="form-control-custom" name="lastname" value={form.lastname} onChange={handleChange} required /></div></div>
              </div>
              <div className="form-group"><label>Nom d'utilisateur</label><input className="form-control-custom" name="username" value={form.username} onChange={handleChange} required /></div>
              <div className="form-group"><label>Email</label><input type="email" className="form-control-custom" name="email" value={form.email} onChange={handleChange} required /></div>
              <div className="form-group"><label>Téléphone</label><input className="form-control-custom" name="number" value={form.number} onChange={handleChange} required /></div>
              <div className="form-group"><label>{editing ? 'Nouveau mot de passe (laisser vide = pas de changement)' : 'Mot de passe'}</label><input type="password" className="form-control-custom" name="password" value={form.password} onChange={handleChange} required={!editing} /></div>
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
