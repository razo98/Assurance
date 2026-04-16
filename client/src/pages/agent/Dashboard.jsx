import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import AgentSidebar from '../../components/AgentSidebar';
import Topbar from '../../components/Topbar';
import { useAuth } from '../../context/AuthContext';
import api from '../../api/axios';

export default function AgentDashboard() {
  const { user } = useAuth();
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/statistics/agent-dashboard').then(r => setStats(r.data)).finally(() => setLoading(false));
  }, []);

  const statCards = stats ? [
    { label: 'Mes contrats', value: stats.total, icon: 'fas fa-shield-alt', cls: '' },
    { label: 'Actives', value: stats.actives, icon: 'fas fa-check-circle', cls: '' },
    { label: 'En attente', value: stats.attente, icon: 'fas fa-clock', cls: 'orange' },
    { label: 'Expirées', value: stats.expirees, icon: 'fas fa-calendar-times', cls: 'red' },
  ] : [];

  const actionCards = [
    { title: 'Nouvelle assurance', desc: 'Créer un contrat', icon: 'fas fa-plus-circle', to: '/agent/devis', color: '#006652' },
    { title: 'Mes assurances', desc: 'Liste des contrats', icon: 'fas fa-shield-alt', to: '/agent/assurances', color: '#0d6efd' },
    { title: 'Réclamations', desc: 'Voir les réclamations', icon: 'fas fa-exclamation-circle', to: '/agent/reclamations', color: '#fd7e14' },
    { title: 'Mon profil', desc: 'Mes informations', icon: 'fas fa-user-cog', to: '/agent/profil', color: '#6f42c1' },
  ];

  return (
    <div className="app-shell">
      <AgentSidebar />
      <div className="main-content">
        <Topbar title="Tableau de bord agent" />
        <div className="page-content">

          <div style={{
            background: 'linear-gradient(135deg, #004d3d 0%, #006652 60%, #008a6e 100%)',
            borderRadius: 14, padding: '24px 30px', marginBottom: 28, color: 'white',
            boxShadow: '0 6px 24px rgba(0,102,82,0.3)', animation: 'fadeIn 0.4s ease'
          }}>
            <h4 style={{ margin: 0, fontWeight: 800, fontSize: 22 }}>
              Bienvenue, {user?.firstname} {user?.lastname}
            </h4>
            <div style={{ fontSize: 15, opacity: 0.88, marginTop: 6 }}>
              <i className="fas fa-id-badge me-1"></i>{user?.matricule} — Agent
            </div>
          </div>

          {loading ? (
            <div style={{ textAlign: 'center', padding: 60 }}>
              <div className="spinner" style={{ width: 44, height: 44, borderWidth: 4, borderColor: '#006652', borderTopColor: 'transparent' }}></div>
              <div style={{ marginTop: 14, color: '#666', fontSize: 15 }}>Chargement des données...</div>
            </div>
          ) : (
            <>
              <div className="row g-3 mb-4">
                {statCards.map((c, i) => (
                  <div className="col-6 col-md-3" key={i}>
                    <div className={`stat-card ${c.cls}`}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <div>
                          <div className="stat-value">{c.value}</div>
                          <div className="stat-label">{c.label}</div>
                        </div>
                        <i className={`${c.icon} stat-icon`}></i>
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              <h6 style={{ color: '#444', marginBottom: 16, fontWeight: 700, fontSize: 15, textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                <i className="fas fa-bolt me-2" style={{ color: '#FF8C00' }}></i>Actions rapides
              </h6>
              <div className="row g-3">
                {actionCards.map((a, i) => (
                  <div className="col-6 col-md-3" key={i}>
                    <Link to={a.to} style={{ textDecoration: 'none' }}>
                      <div style={{
                        background: 'white', borderRadius: 14, padding: '22px 18px',
                        boxShadow: '0 3px 12px rgba(0,0,0,0.07)', textAlign: 'center',
                        border: `2px solid ${a.color}20`,
                        transition: 'transform 0.25s ease, box-shadow 0.25s ease, border-color 0.25s ease',
                        cursor: 'pointer'
                      }}
                        onMouseEnter={e => {
                          e.currentTarget.style.transform = 'translateY(-6px)';
                          e.currentTarget.style.boxShadow = '0 14px 32px rgba(0,0,0,0.13)';
                          e.currentTarget.style.borderColor = a.color;
                        }}
                        onMouseLeave={e => {
                          e.currentTarget.style.transform = 'none';
                          e.currentTarget.style.boxShadow = '0 3px 12px rgba(0,0,0,0.07)';
                          e.currentTarget.style.borderColor = `${a.color}20`;
                        }}
                      >
                        <div style={{
                          width: 58, height: 58, borderRadius: '50%',
                          background: `${a.color}18`,
                          display: 'flex', alignItems: 'center', justifyContent: 'center',
                          margin: '0 auto 14px', fontSize: 24, color: a.color
                        }}>
                          <i className={a.icon}></i>
                        </div>
                        <div style={{ fontWeight: 700, color: a.color, fontSize: 14.5 }}>{a.title}</div>
                        <div style={{ fontSize: 12.5, color: '#888', marginTop: 4 }}>{a.desc}</div>
                      </div>
                    </Link>
                  </div>
                ))}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
