import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../api/axios';

export default function Login() {
  const [form, setForm] = useState({ username: '', password: '', isAdmin: false });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleChange = e => {
    const { name, value, type, checked } = e.target;
    setForm(f => ({ ...f, [name]: type === 'checkbox' ? checked : value }));
  };

  const handleSubmit = async e => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const { data } = await api.post('/auth/login', form);
      login(data.user, data.token);
      const role = data.user.role;
      if (role === 'admin') navigate('/admin/dashboard');
      else if (role === 'agent') navigate('/agent/dashboard');
      else navigate('/client/dashboard');
    } catch (err) {
      setError(err.response?.data?.message || 'Erreur de connexion.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-logo">
          <img src="/logo.jpg" alt="MBA Niger SA" style={{ width: 90, height: 90, borderRadius: '50%', objectFit: 'cover', border: '4px solid #006652', marginBottom: 12, boxShadow: '0 4px 18px rgba(0,102,82,0.25)' }} />
          <h2>MBA Niger SA</h2>
          <p>Connectez-vous à votre espace</p>
        </div>

        {error && <div className="alert-custom alert-error">{error}</div>}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Nom d'utilisateur ou email</label>
            <input
              type="text"
              name="username"
              className="form-control-custom"
              value={form.username}
              onChange={handleChange}
              placeholder="Votre identifiant"
              required
            />
          </div>
          <div className="form-group">
            <label>Mot de passe</label>
            <input
              type="password"
              name="password"
              className="form-control-custom"
              value={form.password}
              onChange={handleChange}
              placeholder="Votre mot de passe"
              required
            />
          </div>

          <div className="form-group" style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <input
              type="checkbox"
              name="isAdmin"
              id="isAdmin"
              checked={form.isAdmin}
              onChange={handleChange}
              style={{ width: 16, height: 16 }}
            />
            <label htmlFor="isAdmin" style={{ margin: 0, cursor: 'pointer', fontWeight: 500 }}>
              Je suis un administrateur / agent
            </label>
          </div>

          <button type="submit" className="btn-submit" disabled={loading}>
            {loading ? <><span className="spinner"></span> Connexion...</> : <><i className="fas fa-sign-in-alt"></i> Se connecter</>}
          </button>
        </form>

        <div style={{ textAlign: 'center', marginTop: 20, fontSize: 14 }}>
          <span style={{ color: '#666' }}>Pas encore de compte ? </span>
          <Link to="/register" style={{ color: '#006652', fontWeight: 600 }}>S'inscrire</Link>
        </div>
        <div style={{ textAlign: 'center', marginTop: 10, fontSize: 14 }}>
          <Link to="/" style={{ color: '#999' }}>
            <i className="fas fa-arrow-left"></i> Retour à l'accueil
          </Link>
        </div>
      </div>
    </div>
  );
}
