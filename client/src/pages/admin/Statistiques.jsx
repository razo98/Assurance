import { useState, useEffect } from 'react';
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

  const load = () => {
    setLoading(true);
    api.get(`/statistics/advanced?type=${type}&dateDebut=${dateDebut}&dateFin=${dateFin}`)
      .then(r => setData(r.data))
      .catch(console.error)
      .finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, [type]);

  const moisNoms = ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc'];

  const labels = data.map(d => {
    if (type === 'temps') return `${moisNoms[(d._id.month || 1) - 1]} ${d._id.year || ''}`;
    return d._id || 'Inconnu';
  });

  const chartData = {
    labels,
    datasets: [
      {
        label: 'Nombre d\'assurances',
        data: data.map(d => d.total),
        backgroundColor: 'rgba(0, 102, 82, 0.7)',
        borderColor: '#006652',
        borderWidth: 1
      },
      {
        label: 'Capital (FCFA / 1000)',
        data: data.map(d => Math.round((d.capital || 0) / 1000)),
        backgroundColor: 'rgba(255, 140, 0, 0.7)',
        borderColor: '#FF8C00',
        borderWidth: 1
      }
    ]
  };

  return (
    <div className="app-shell">
      <AdminSidebar />
      <div className="main-content">
        <Topbar title="Statistiques avancées" />
        <div className="page-content">
          <div className="form-card" style={{ marginBottom: 20 }}>
            <div style={{ display: 'flex', gap: 15, flexWrap: 'wrap', alignItems: 'flex-end' }}>
              <div>
                <label style={{ fontSize: 13, fontWeight: 600 }}>Type d'analyse</label>
                <select className="form-select form-select-sm mt-1" value={type} onChange={e => setType(e.target.value)} style={{ width: 160 }}>
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
              <button className="btn-primary-custom" onClick={load}>
                <i className="fas fa-search"></i> Analyser
              </button>
            </div>
          </div>

          <div className="row g-3">
            <div className="col-lg-8">
              <div className="form-card">
                <h6 style={{ color: '#006652', marginBottom: 15 }}>Graphique</h6>
                {loading ? <p>Chargement...</p> : data.length > 0 ? (
                  <Bar data={chartData} options={{ responsive: true, plugins: { legend: { position: 'top' } } }} />
                ) : <p style={{ color: '#999', textAlign: 'center', padding: 30 }}>Aucune donnée disponible</p>}
              </div>
            </div>
            <div className="col-lg-4">
              <div className="form-card">
                <h6 style={{ color: '#006652', marginBottom: 15 }}>Détails</h6>
                <div style={{ maxHeight: 350, overflowY: 'auto' }}>
                  {data.map((d, i) => (
                    <div key={i} style={{ padding: '8px 0', borderBottom: '1px solid #eee', fontSize: 13 }}>
                      <strong>{type === 'temps' ? `${moisNoms[(d._id.month || 1) - 1]} ${d._id.year}` : d._id || 'N/A'}</strong>
                      <div style={{ color: '#666' }}>{d.total} assurance(s) | {(d.capital || 0).toLocaleString()} FCFA</div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
