import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import ClientSidebar from '../../components/ClientSidebar';
import Topbar from '../../components/Topbar';
import api from '../../api/axios';

export default function ClientDashboard() {
  const [stats, setStats] = useState(null);
  const [assurances, setAssurances] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([api.get('/statistics/client-dashboard'), api.get('/assurances')])
      .then(([s, a]) => { setStats(s.data); setAssurances(a.data.slice(0, 5)); })
      .finally(() => setLoading(false));
  }, []);

  const cards = stats ? [
    { label: 'Mes assurances', value: stats.total, icon: 'fas fa-shield-alt', cls: '' },
    { label: 'Actives', value: stats.actives, icon: 'fas fa-check-circle', cls: '' },
    { label: 'En attente', value: stats.attente, icon: 'fas fa-clock', cls: 'orange' },
    { label: 'Expirées', value: stats.expirees, icon: 'fas fa-calendar-times', cls: 'red' },
  ] : [];

  return (
    <div className="app-shell">
      <ClientSidebar />
      <div className="main-content">
        <Topbar title="Tableau de bord" />
        <div className="page-content">
          {loading ? <div style={{ textAlign: 'center', padding: 50 }}><div className="spinner" style={{ width: 40, height: 40, borderWidth: 3, borderColor: '#006652', borderTopColor: 'transparent' }}></div></div> : (
            <>
              <div className="row g-3 mb-4">
                {cards.map((c, i) => (
                  <div className="col-6 col-md-3" key={i}>
                    <div className={`stat-card ${c.cls}`}>
                      <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                        <div><div className="stat-value">{c.value}</div><div className="stat-label">{c.label}</div></div>
                        <i className={`${c.icon} stat-icon`}></i>
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              <div className="row g-3">
                <div className="col-lg-8">
                  <div className="table-card">
                    <div className="table-card-header">
                      <h5><i className="fas fa-shield-alt me-2"></i>Mes dernières assurances</h5>
                      <Link to="/client/assurances" style={{ fontSize: 13, color: '#006652' }}>Voir tout →</Link>
                    </div>
                    <table className="table table-hover mb-0" style={{ fontSize: 13 }}>
                      <thead style={{ background: '#f8f9fa' }}><tr><th>Immatriculation</th><th>Catégorie</th><th>Prix</th><th>Statut</th></tr></thead>
                      <tbody>
                        {assurances.length === 0 ? <tr><td colSpan={4} className="text-center text-muted p-4">Aucune assurance</td></tr> :
                        assurances.map(a => (
                          <tr key={a._id}>
                            <td><code>{a.immatriculation}</code></td>
                            <td>{a.id_categorie?.genre || '-'}</td>
                            <td>{(a.prix_ttc || 0).toLocaleString()} FCFA</td>
                            <td><span className={a.status === 'Active' ? 'badge-active' : a.status === 'En attente' ? 'badge-attente' : 'badge-expired'}>{a.status}</span></td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
                <div className="col-lg-4">
                  <div className="form-card" style={{ textAlign: 'center' }}>
                    <i className="fas fa-shield-alt" style={{ fontSize: 50, color: '#006652', marginBottom: 15 }}></i>
                    <h6 style={{ color: '#006652' }}>Souscrire une assurance</h6>
                    <p style={{ fontSize: 13, color: '#666', marginBottom: 15 }}>Calculez votre prime et souscrivez en ligne</p>
                    <Link to="/client/devis" className="btn-secondary-custom" style={{ textDecoration: 'none', display: 'inline-block' }}>
                      <i className="fas fa-calculator"></i> Faire un devis
                    </Link>
                  </div>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
