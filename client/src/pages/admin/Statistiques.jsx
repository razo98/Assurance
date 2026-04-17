import { useState, useEffect, useCallback } from 'react';
import AdminSidebar from '../../components/AdminSidebar';
import Topbar from '../../components/Topbar';
import api from '../../api/axios';
import { Bar } from 'react-chartjs-2';
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend } from 'chart.js';

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

export default function Statistiques() {
  const [type, setType] = useState('temps');
  const [dateDebut, setDateDebut] = useState('');
  const [dateFin, setDateFin] = useState('');
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [summary, setSummary] = useState(null);

  // Charge les stats résumées une seule fois
  useEffect(() => {
    api.get('/statistics/dashboard')
      .then(r => setSummary(r.data))
      .catch(() => {});
  }, []);

  // Fonction qui prend le type en paramètre pour éviter les closures périmées
  const loadAdvanced = useCallback((t, debut, fin) => {
    setLoading(true);
    setError('');
    api.get(`/statistics/advanced?type=${t}&dateDebut=${debut}&dateFin=${fin}`)
      .then(r => setData(r.data || []))
      .catch(err => {
        console.error('Stats error:', err);
        setError(err.response?.data?.message || 'Erreur lors du chargement.');
        setData([]);
      })
      .finally(() => setLoading(false));
  }, []);

  // Chargement initial
  useEffect(() => {
    loadAdvanced('temps', '', '');
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  // Changement de type — appel direct avec la nouvelle valeur
  const handleTypeChange = (newType) => {
    setType(newType);
    loadAdvanced(newType, dateDebut, dateFin);
  };

  // Bouton Analyser — applique aussi les dates
  const handleAnalyser = () => loadAdvanced(type, dateDebut, dateFin);

  const moisNoms = ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc'];

  const getLabel = (d) => {
    if (type === 'temps') {
      if (!d._id) return 'Inconnu';
      const m = (d._id.month || 1) - 1;
      const y = d._id.year || '';
      return `${moisNoms[Math.max(0, Math.min(11, m))]} ${y}`;
    }
    return d._id || 'N/A';
  };

  const labels = data.map(getLabel);
  const totalAssurances = data.reduce((s, d) => s + (d.total || 0), 0);
  const totalCapital = data.reduce((s, d) => s + (d.capital || 0), 0);

  const chartData = {
    labels,
    datasets: [
      {
        label: "Nombre d'assurances",
        data: data.map(d => d.total || 0),
        backgroundColor: 'rgba(0, 102, 82, 0.75)',
        borderColor: '#006652',
        borderWidth: 1,
        borderRadius: 6,
      },
      {
        label: 'Capital (FCFA / 1000)',
        data: data.map(d => Math.round((d.capital || 0) / 1000)),
        backgroundColor: 'rgba(255, 140, 0, 0.75)',
        borderColor: '#FF8C00',
        borderWidth: 1,
        borderRadius: 6,
      }
    ]
  };

  const chartOptions = {
    responsive: true,
    plugins: {
      legend: { position: 'top' },
      title: {
        display: true,
        text: type === 'temps' ? 'Évolution mensuelle' : type === 'agent' ? 'Performance par agent' : 'Répartition par catégorie',
        color: '#006652',
        font: { size: 14, weight: 'bold' }
      }
    },
    scales: {
      y: { beginAtZero: true, grid: { color: '#f0f0f0' } },
      x: { grid: { display: false } }
    }
  };

  const typeLabel = type === 'temps' ? 'Période' : type === 'agent' ? 'Agent' : 'Catégorie';

  return (
    <div className="app-shell">
      <AdminSidebar />
      <div className="main-content">
        <Topbar title="Statistiques avancées" />
        <div className="page-content">

          {/* Filtres */}
          <div className="form-card" style={{ marginBottom: 20 }}>
            <div style={{ display: 'flex', gap: 15, flexWrap: 'wrap', alignItems: 'flex-end' }}>
              <div>
                <label style={{ fontSize: 13, fontWeight: 600 }}>Type d'analyse</label>
                <select className="form-select form-select-sm mt-1" value={type} onChange={e => handleTypeChange(e.target.value)} style={{ width: 160 }}>
                  <option value="temps">Par période</option>
                  <option value="agent">Par agent</option>
                  <option value="categorie">Par catégorie</option>
                </select>
              </div>
              <div>
                <label style={{ fontSize: 13, fontWeight: 600 }}>Date début</label>
                <input type="date" className="form-control form-control-sm mt-1" value={dateDebut} onChange={e => setDateDebut(e.target.value)} />
              </div>
              <div>
                <label style={{ fontSize: 13, fontWeight: 600 }}>Date fin</label>
                <input type="date" className="form-control form-control-sm mt-1" value={dateFin} onChange={e => setDateFin(e.target.value)} />
              </div>
              <button className="btn-primary-custom" onClick={handleAnalyser} disabled={loading}>
                <i className="fas fa-search me-1"></i>{loading ? 'Chargement...' : 'Analyser'}
              </button>
            </div>
          </div>

          {/* Erreur */}
          {error && (
            <div style={{ background: '#fff3f3', border: '1px solid #ffb3b3', borderRadius: 10, padding: '12px 18px', marginBottom: 18, color: '#c0392b', fontSize: 14 }}>
              <i className="fas fa-exclamation-triangle me-2"></i>{error}
            </div>
          )}

          {/* Cartes récapitulatives globales */}
          {summary && (
            <div className="row g-3 mb-4">
              {[
                { label: 'Total assurances', value: summary.totalAssurances, icon: 'fas fa-shield-alt', color: '#006652' },
                { label: 'Actives', value: summary.assurancesActives, icon: 'fas fa-check-circle', color: '#28a745' },
                { label: 'En attente', value: summary.assurancesAttente, icon: 'fas fa-clock', color: '#FF8C00' },
                { label: 'Capital total', value: `${((summary.capitalTotal || 0) / 1000).toFixed(0)}K FCFA`, icon: 'fas fa-coins', color: '#6f42c1' },
              ].map((c, i) => (
                <div className="col-6 col-md-3" key={i}>
                  <div style={{ background: 'white', borderRadius: 12, padding: '16px 18px', boxShadow: '0 2px 10px rgba(0,0,0,0.07)', borderLeft: `4px solid ${c.color}` }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <div>
                        <div style={{ fontSize: 22, fontWeight: 800, color: c.color }}>{c.value}</div>
                        <div style={{ fontSize: 12, color: '#888', marginTop: 2 }}>{c.label}</div>
                      </div>
                      <i className={`${c.icon}`} style={{ fontSize: 26, color: `${c.color}40` }}></i>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Graphique + Détails */}
          <div className="row g-3">
            <div className="col-lg-8">
              <div className="form-card">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 15 }}>
                  <h6 style={{ color: '#006652', margin: 0 }}><i className="fas fa-chart-bar me-2"></i>Graphique — {typeLabel}</h6>
                  {data.length > 0 && (
                    <span style={{ fontSize: 12, color: '#888' }}>
                      {totalAssurances} assurance(s) | {totalCapital.toLocaleString()} FCFA
                    </span>
                  )}
                </div>
                {loading ? (
                  <div style={{ textAlign: 'center', padding: 40, color: '#888' }}>
                    <i className="fas fa-spinner fa-spin" style={{ fontSize: 28, color: '#006652' }}></i>
                    <div style={{ marginTop: 10, fontSize: 14 }}>Chargement...</div>
                  </div>
                ) : data.length > 0 ? (
                  <Bar
                    key={`${type}-${dateDebut}-${dateFin}-${data.length}`}
                    data={chartData}
                    options={chartOptions}
                  />
                ) : (
                  <div style={{ textAlign: 'center', padding: 40 }}>
                    <i className="fas fa-chart-bar" style={{ fontSize: 40, color: '#ddd', display: 'block', marginBottom: 12 }}></i>
                    <p style={{ color: '#999', fontSize: 14, margin: 0 }}>Aucune donnée disponible</p>
                    <p style={{ color: '#bbb', fontSize: 12, marginTop: 6 }}>
                      {type === 'agent' ? 'Aucune assurance créée par un agent trouvée.' : type === 'categorie' ? 'Aucune catégorie trouvée.' : 'Aucune assurance sur cette période.'}
                    </p>
                  </div>
                )}
              </div>
            </div>
            <div className="col-lg-4">
              <div className="form-card" style={{ height: '100%' }}>
                <h6 style={{ color: '#006652', marginBottom: 15 }}><i className="fas fa-list me-2"></i>Détails — {typeLabel}</h6>
                {loading ? (
                  <p style={{ color: '#aaa', fontSize: 13 }}>Chargement...</p>
                ) : data.length === 0 ? (
                  <p style={{ color: '#aaa', fontSize: 13 }}>Aucune donnée</p>
                ) : (
                  <div style={{ maxHeight: 380, overflowY: 'auto' }}>
                    {data.map((d, i) => (
                      <div key={i} style={{ padding: '9px 0', borderBottom: '1px solid #f0f0f0', fontSize: 13 }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                          <strong style={{ color: '#333' }}>{getLabel(d)}</strong>
                          <span style={{ background: '#006652', color: 'white', borderRadius: 20, padding: '1px 10px', fontSize: 12, fontWeight: 700 }}>{d.total}</span>
                        </div>
                        <div style={{ color: '#888', marginTop: 3 }}>{(d.capital || 0).toLocaleString()} FCFA</div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}
