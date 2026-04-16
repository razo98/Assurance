import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../api/axios';

export default function Register() {
  const [form, setForm] = useState({ firstname: '', lastname: '', username: '', email: '', number: '', password: '', confirm: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleChange = e => setForm(f => ({ ...f, [e.target.name]: e.target.value }));

  const handleSubmit = async e => {
    e.preventDefault();
    setError('');
    if (form.password !== form.confirm) { setError('Les mots de passe ne correspondent pas.'); return; }
    setLoading(true);
    try {
      const { data } = await api.post('/auth/register', form);
      login(data.user, data.token);
      navigate('/client/dashboard');
    } catch (err) {
      setError(err.response?.data?.message || 'Erreur lors de l\'inscription.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-page">
      <div className="auth-card" style={{ maxWidth: 550 }}>
        <div className="auth-logo">
          <div style={{ fontSize: 36, color: '#006652', marginBottom: 10 }}>
            <i className="fas fa-user-plus"></i>
          </div>
          <h2>Créer un compte</h2>
          <p>Rejoignez MBA Niger SA</p>
        </div>
        {error && <div className="alert-custom alert-error">{error}</div>}
        <form onSubmit={handleSubmit}>
          <div className="row g-2">
            <div className="col-6">
              <div className="form-group">
                <label>Prénom</label>
                <input type="text" name="firstname" className="form-control-custom" value={form.firstname} onChange={handleChange} placeholder="Prénom" required />
              </div>
            </div>
            <div className="col-6">
              <div className="form-group">
                <label>Nom</label>
                <input type="text" name="lastname" className="form-control-custom" value={form.lastname} onChange={handleChange} placeholder="Nom" required />
              </div>
            </div>
          </div>
          <div className="form-group">
            <label>Nom d'utilisateur</label>
            <input type="text" name="username" className="form-control-custom" value={form.username} onChange={handleChange} placeholder="Nom d'utilisateur" required />
          </div>
          <div className="form-group">
            <label>Email</label>
            <input type="email" name="email" className="form-control-custom" value={form.email} onChange={handleChange} placeholder="email@exemple.com" required />
          </div>
          <div className="form-group">
            <label>Téléphone</label>
            <input type="text" name="number" className="form-control-custom" value={form.number} onChange={handleChange} placeholder="+227..." required />
          </div>
          <div className="row g-2">
            <div className="col-6">
              <div className="form-group">
                <label>Mot de passe</label>
                <input type="password" name="password" className="form-control-custom" value={form.password} onChange={handleChange} placeholder="Mot de passe" required />
              </div>
            </div>
            <div className="col-6">
              <div className="form-group">
                <label>Confirmer</label>
                <input type="password" name="confirm" className="form-control-custom" value={form.confirm} onChange={handleChange} placeholder="Confirmer" required />
              </div>
            </div>
          </div>
          <button type="submit" className="btn-submit" disabled={loading}>
            {loading ? <><span className="spinner"></span> Inscription...</> : <><i className="fas fa-check"></i> S'inscrire</>}
          </button>
        </form>
        <div style={{ textAlign: 'center', marginTop: 20, fontSize: 14 }}>
          <span style={{ color: '#666' }}>Déjà un compte ? </span>
          <Link to="/login" style={{ color: '#006652', fontWeight: 600 }}>Se connecter</Link>
        </div>
      </div>
    </div>
  );
}
