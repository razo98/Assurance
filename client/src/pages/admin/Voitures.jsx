import { useState, useEffect } from 'react';
import AdminSidebar from '../../components/AdminSidebar';
import Topbar from '../../components/Topbar';
import api from '../../api/axios';

export default function Voitures() {
  const [voitures, setVoitures] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [marque, setMarque] = useState('');
  const [msg, setMsg] = useState('');

  const load = () => { setLoading(true); api.get('/voitures').then(r => setVoitures(r.data)).finally(() => setLoading(false)); };
  useEffect(() => { load(); }, []);

  const openAdd = () => { setEditing(null); setMarque(''); setShowModal(true); setMsg(''); };
  const openEdit = (v) => { setEditing(v); setMarque(v.marque); setShowModal(true); setMsg(''); };

  const handleSubmit = async e => {
    e.preventDefault();
    try {
      if (editing) await api.put(`/voitures/${editing._id}`, { marque });
      else await api.post('/voitures', { marque });
      setShowModal(false); load();
    } catch (err) { setMsg(err.response?.data?.message || 'Erreur'); }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Supprimer cette marque ?')) return;
    await api.delete(`/voitures/${id}`); load();
  };

  const filtered = voitures.filter(v => v.marque.toLowerCase().includes(search.toLowerCase()));

  return (
    <div className="app-shell">
      <AdminSidebar />
      <div className="main-content">
        <Topbar title="Marques de véhicules" />
        <div className="page-content">
          <div className="table-card">
            <div className="table-card-header">
              <h5><i className="fas fa-car me-2"></i>Marques ({filtered.length})</h5>
              <div style={{ display: 'flex', gap: 10 }}>
                <input type="text" className="form-control form-control-sm" placeholder="Rechercher..." value={search} onChange={e => setSearch(e.target.value)} style={{ width: 200 }} />
                <button className="btn-primary-custom" onClick={openAdd}><i className="fas fa-plus"></i> Ajouter</button>
              </div>
            </div>
            <div className="table-responsive">
              <table className="table table-hover mb-0">
                <thead style={{ background: '#f8f9fa' }}><tr><th>#</th><th>Marque</th><th>Actions</th></tr></thead>
                <tbody>
                  {loading ? <tr><td colSpan={3} className="text-center p-4">Chargement...</td></tr> :
                  filtered.map((v, i) => (
                    <tr key={v._id}>
                      <td>{i + 1}</td>
                      <td><strong>{v.marque}</strong></td>
                      <td>
                        <button className="btn btn-sm btn-outline-primary me-1" onClick={() => openEdit(v)}><i className="fas fa-edit"></i></button>
                        <button className="btn btn-sm btn-outline-danger" onClick={() => handleDelete(v._id)}><i className="fas fa-trash"></i></button>
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
            <h5 style={{ color: '#006652', marginBottom: 20 }}>{editing ? 'Modifier la marque' : 'Ajouter une marque'}</h5>
            {msg && <div className="alert-custom alert-error">{msg}</div>}
            <form onSubmit={handleSubmit}>
              <div className="form-group"><label>Nom de la marque</label><input className="form-control-custom" value={marque} onChange={e => setMarque(e.target.value)} required /></div>
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
