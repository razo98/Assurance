import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function ClientSidebar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const handleLogout = () => { logout(); navigate('/login'); };
  const initials = user ? `${user.firstname?.[0]}${user.lastname?.[0]}` : 'CL';

  return (
    <aside className="sidebar">
      <div className="sidebar-brand">
        <img src="/logo.jpg" alt="MBA" style={{ width: 44, height: 44, borderRadius: '50%', objectFit: 'cover', border: '2px solid rgba(255,140,0,0.6)', flexShrink: 0, boxShadow: '0 3px 10px rgba(0,0,0,0.25)' }} />
        <div>
          <span style={{ display: 'block', fontSize: 15, fontWeight: 800, letterSpacing: '0.2px' }}>MBA Niger SA</span>
          <span style={{ fontSize: 12, opacity: 0.72 }}>{user?.firstname} {user?.lastname}</span>
        </div>
      </div>
      <nav className="sidebar-nav">
        <div className="sidebar-section">Mon espace</div>
        <NavLink to="/client/dashboard" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-tachometer-alt"></i> Tableau de bord
        </NavLink>
        <NavLink to="/client/devis" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-calculator"></i> Demande de devis
        </NavLink>
        <NavLink to="/client/assurances" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-shield-alt"></i> Mes assurances
        </NavLink>
        <NavLink to="/client/renouvellement" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-sync-alt"></i> Renouvellement
        </NavLink>
        <NavLink to="/client/reclamation" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-exclamation-circle"></i> Réclamations
        </NavLink>
        <div className="sidebar-section">Compte</div>
        <NavLink to="/client/profil" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-user-cog"></i> Mon profil
        </NavLink>
        <button onClick={handleLogout} className="sidebar-link" style={{ background: 'none', border: 'none', width: '100%', textAlign: 'left', cursor: 'pointer' }}>
          <i className="fas fa-sign-out-alt"></i> Déconnexion
        </button>
      </nav>
    </aside>
  );
}
