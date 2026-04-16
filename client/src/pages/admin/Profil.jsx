import { useState, useEffect } from 'react';
import AdminSidebar from '../../components/AdminSidebar';
import Topbar from '../../components/Topbar';
import { useAuth } from '../../context/AuthContext';
import api from '../../api/axios';

export default function AdminProfil() {
  const { user, login, token } = useAuth();
  const [form, setForm] = useState({ firstname: '', lastname: '', email: '', number: '', quartier: '', password: '' });
  const [msg, setMsg] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (user) setForm({ firstname: user.firstname, lastname: user.lastname, email: user.email, number: user.number || '', quartier: user.quartier || '', password: '' });
  }, [user]);

  const handleChange = e => setForm(f => ({ ...f, [e.target.name]: e.target.value }));

  const handleSubmit = async e => {
    e.preventDefault(); setMsg(''); setSuccess(''); setLoading(true);
    try {
      const { data } = await api.put(`/admins/${user.id}`, form);
      login({ ...user, ...data }, token);
      setSuccess('Profil mis à jour avec succès.');
    } catch (err) { setMsg(err.response?.data?.message || 'Erreur'); }
    finally { setLoading(false); }
  };

  const QUARTIERS = ['Francophonie', 'Bobiel', 'Sonuci', 'Tchangarey', 'Ryad', 'Dar As Salam', 'Plateau', 'Recasement', 'Cite Chinoise'];

  return (
    <div className="app-shell">
      <AdminSidebar />
      <div className="main-content">
        <Topbar title="Mon profil" />
        <div className="page-content">
          <div className="row">
            <div className="col-lg-7">
              <div className="form-card">
                <h5 style={{ color: '#006652', marginBottom: 20 }}>Informations personnelles</h5>
                {msg && <div className="alert-custom alert-error">{msg}</div>}
                {success && <div className="alert-custom alert-success">{success}</div>}
                <div style={{ background: '#f0f7f5', padding: 15, borderRadius: 8, marginBottom: 20 }}>
                  <strong>Matricule :</strong> <code>{user?.matricule}</code> &nbsp;&nbsp;
                  <strong>Rôle :</strong> {user?.role === 'admin' ? 'Administrateur' : 'Agent'}
                </div>
                <form onSubmit={handleSubmit}>
                  <div className="row g-2">
                    <div className="col-6"><div className="form-group"><label>Prénom</label><input className="form-control-custom" name="firstname" value={form.firstname} onChange={handleChange} required /></div></div>
                    <div className="col-6"><div className="form-group"><label>Nom</label><input className="form-control-custom" name="lastname" value={form.lastname} onChange={handleChange} required /></div></div>
                  </div>
                  <div className="form-group"><label>Email</label><input type="email" className="form-control-custom" name="email" value={form.email} onChange={handleChange} required /></div>
                  <div className="form-group"><label>Téléphone</label><input className="form-control-custom" name="number" value={form.number} onChange={handleChange} required /></div>
                  <div className="form-group"><label>Quartier</label>
                    <select className="form-control-custom" name="quartier" value={form.quartier} onChange={handleChange}>
                      <option value="">-- Sélectionner --</option>
                      {QUARTIERS.map(q => <option key={q} value={q}>{q}</option>)}
                    </select>
                  </div>
                  <div className="form-group"><label>Nouveau mot de passe (optionnel)</label><input type="password" className="form-control-custom" name="password" value={form.password} onChange={handleChange} placeholder="Laisser vide pour ne pas changer" /></div>
                  <button type="submit" className="btn-primary-custom" disabled={loading}>
                    {loading ? 'Mise à jour...' : <><i className="fas fa-save"></i> Enregistrer</>}
                  </button>
                </form>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
