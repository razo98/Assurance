import { useState, useEffect } from 'react';
import AgentSidebar from '../../components/AgentSidebar';
import Topbar from '../../components/Topbar';
import { useAuth } from '../../context/AuthContext';
import api from '../../api/axios';

export default function AgentProfil() {
  const { user, login, token } = useAuth();
  const [form, setForm] = useState({ firstname: '', lastname: '', email: '', number: '', password: '' });
  const [msg, setMsg] = useState('');
  const [success, setSuccess] = useState('');

  useEffect(() => {
    if (user) setForm({ firstname: user.firstname, lastname: user.lastname, email: user.email, number: user.number || '', password: '' });
  }, [user]);

  const handleChange = e => setForm(f => ({ ...f, [e.target.name]: e.target.value }));

  const handleSubmit = async e => {
    e.preventDefault(); setMsg(''); setSuccess('');
    try {
      const { data } = await api.put(`/admins/${user.id}`, form);
      login({ ...user, ...data }, token);
      setSuccess('Profil mis à jour.');
    } catch (err) { setMsg(err.response?.data?.message || 'Erreur'); }
  };

  return (
    <div className="app-shell">
      <AgentSidebar />
      <div className="main-content">
        <Topbar title="Mon profil" />
        <div className="page-content">
          <div className="row"><div className="col-lg-6">
            <div className="form-card">
              <h5 style={{ color: '#006652', marginBottom: 20 }}>Mon profil</h5>
              <div style={{ background: '#f0f7f5', padding: 12, borderRadius: 8, marginBottom: 15, fontSize: 13 }}>
                <strong>Matricule:</strong> <code>{user?.matricule}</code>
              </div>
              {msg && <div className="alert-custom alert-error">{msg}</div>}
              {success && <div className="alert-custom alert-success">{success}</div>}
              <form onSubmit={handleSubmit}>
                <div className="row g-2">
                  <div className="col-6"><div className="form-group"><label>Prénom</label><input className="form-control-custom" name="firstname" value={form.firstname} onChange={handleChange} required /></div></div>
                  <div className="col-6"><div className="form-group"><label>Nom</label><input className="form-control-custom" name="lastname" value={form.lastname} onChange={handleChange} required /></div></div>
                </div>
                <div className="form-group"><label>Email</label><input type="email" className="form-control-custom" name="email" value={form.email} onChange={handleChange} required /></div>
                <div className="form-group"><label>Téléphone</label><input className="form-control-custom" name="number" value={form.number} onChange={handleChange} /></div>
                <div className="form-group"><label>Nouveau mot de passe</label><input type="password" className="form-control-custom" name="password" value={form.password} onChange={handleChange} placeholder="Laisser vide = pas de changement" /></div>
                <button type="submit" className="btn-primary-custom"><i className="fas fa-save"></i> Enregistrer</button>
              </form>
            </div>
          </div></div>
        </div>
      </div>
    </div>
  );
}
