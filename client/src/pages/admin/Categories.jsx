import { useState, useEffect } from 'react';
import AdminSidebar from '../../components/AdminSidebar';
import Topbar from '../../components/Topbar';
import api from '../../api/axios';

export default function Categories() {
  const [cats, setCats] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [genre, setGenre] = useState('');
  const [msg, setMsg] = useState('');

  const load = () => { setLoading(true); api.get('/categories').then(r => setCats(r.data)).finally(() => setLoading(false)); };
  useEffect(() => { load(); }, []);

  const openAdd = () => { setEditing(null); setGenre(''); setShowModal(true); setMsg(''); };
  const openEdit = (c) => { setEditing(c); setGenre(c.genre); setShowModal(true); setMsg(''); };

  const handleSubmit = async e => {
    e.preventDefault();
    try {
      if (editing) await api.put(`/categories/${editing._id}`, { genre });
      else await api.post('/categories', { genre });
      setShowModal(false); load();
    } catch (err) { setMsg(err.response?.data?.message || 'Erreur'); }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Supprimer cette catégorie ?')) return;
    await api.delete(`/categories/${id}`); load();
  };

  return (
    <div className="app-shell">
      <AdminSidebar />
      <div className="main-content">
        <Topbar title="Catégories d'assurance" />
        <div className="page-content">
          <div className="table-card">
            <div className="table-card-header">
              <h5><i className="fas fa-tags me-2"></i>Catégories ({cats.length})</h5>
              <button className="btn-primary-custom" onClick={openAdd}><i className="fas fa-plus"></i> Ajouter</button>
            </div>
            <div className="table-responsive">
              <table className="table table-hover mb-0">
                <thead style={{ background: '#f8f9fa' }}><tr><th>#</th><th>Genre / Catégorie</th><th>Actions</th></tr></thead>
                <tbody>
                  {loading ? <tr><td colSpan={3} className="text-center p-4">Chargement...</td></tr> :
                  cats.map((c, i) => (
                    <tr key={c._id}>
                      <td>{i + 1}</td>
                      <td><strong>{c.genre}</strong></td>
                      <td>
                        <button className="btn btn-sm btn-outline-primary me-1" onClick={() => openEdit(c)}><i className="fas fa-edit"></i></button>
                        <button className="btn btn-sm btn-outline-danger" onClick={() => handleDelete(c._id)}><i className="fas fa-trash"></i></button>
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
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', zIndex: 2000, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{ background: 'white', borderRadius: 12, padding: 30, width: 360 }}>
            <h5 style={{ color: '#006652', marginBottom: 20 }}>{editing ? 'Modifier la catégorie' : 'Ajouter une catégorie'}</h5>
            {msg && <div className="alert-custom alert-error">{msg}</div>}
            <form onSubmit={handleSubmit}>
              <div className="form-group"><label>Genre / Catégorie</label><input className="form-control-custom" value={genre} onChange={e => setGenre(e.target.value)} placeholder="Ex: VP, Moto, Taxiville_4p" required /></div>
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
