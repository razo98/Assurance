import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function AdminSidebar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => { logout(); navigate('/login'); };
  const initials = user ? `${user.firstname?.[0]}${user.lastname?.[0]}` : 'A';

  return (
    <aside className="sidebar">
      <div className="sidebar-brand">
        <img src="/logo.jpg" alt="MBA" style={{ width: 44, height: 44, borderRadius: '50%', objectFit: 'cover', border: '2px solid rgba(255,140,0,0.6)', flexShrink: 0, boxShadow: '0 3px 10px rgba(0,0,0,0.25)' }} />
        <div>
          <span style={{ display: 'block', fontSize: 15, fontWeight: 800, letterSpacing: '0.2px' }}>MBA Niger SA</span>
          <span style={{ fontSize: 12, opacity: 0.72 }}>{user?.role === 'admin' ? 'Administrateur' : 'Agent'}</span>
        </div>
      </div>

      <nav className="sidebar-nav">
        <div className="sidebar-section">Tableau de bord</div>
        <NavLink to="/admin/dashboard" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-tachometer-alt"></i> Tableau de bord
        </NavLink>

        <div className="sidebar-section">Gestion</div>
        <NavLink to="/admin/clients" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-users"></i> Clients
        </NavLink>
        <NavLink to="/admin/agents" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-user-tie"></i> Agents
        </NavLink>
        <NavLink to="/admin/voitures" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-car"></i> Marques véhicules
        </NavLink>
        <NavLink to="/admin/categories" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-tags"></i> Catégories
        </NavLink>

        <div className="sidebar-section">Assurances</div>
        <NavLink to="/admin/devis" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-plus-circle"></i> Nouvelle assurance
        </NavLink>
        <NavLink to="/admin/assurances" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-shield-alt"></i> Toutes les assurances
        </NavLink>
        <NavLink to="/admin/renouvellement" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-sync-alt"></i> Renouvellements
        </NavLink>
        <NavLink to="/admin/reclamations" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-exclamation-circle"></i> Réclamations
        </NavLink>
        <NavLink to="/admin/statistiques" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-chart-bar"></i> Statistiques
        </NavLink>

        <div className="sidebar-section">Compte</div>
        <NavLink to="/admin/profil" className={({isActive}) => `sidebar-link${isActive?' active':''}`}>
          <i className="fas fa-user-cog"></i> Mon profil
        </NavLink>
        <button onClick={handleLogout} className="sidebar-link" style={{ background: 'none', border: 'none', width: '100%', textAlign: 'left', cursor: 'pointer' }}>
          <i className="fas fa-sign-out-alt"></i> Déconnexion
        </button>
      </nav>
    </aside>
  );
}
