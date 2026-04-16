import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import ClientSidebar from '../../components/ClientSidebar';
import Topbar from '../../components/Topbar';
import api from '../../api/axios';

const STATUS_BADGE = {
  'Active': 'badge-active', 'En attente': 'badge-attente',
  'Expirée': 'badge-expired', 'Suspendue': 'badge-suspended', 'Résiliée': 'badge-resilie'
};

export default function ClientAssurances() {
  const [assurances, setAssurances] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState(null);

  const load = () => { setLoading(true); api.get('/assurances').then(r => setAssurances(r.data)).finally(() => setLoading(false)); };
  useEffect(() => { load(); }, []);

  return (
    <div className="app-shell">
      <ClientSidebar />
      <div className="main-content">
        <Topbar title="Mes assurances" />
        <div className="page-content">
          <div className="table-card">
            <div className="table-card-header">
              <h5><i className="fas fa-shield-alt me-2"></i>Mes assurances ({assurances.length})</h5>
              <Link to="/client/devis" className="btn-secondary-custom" style={{ textDecoration: 'none', fontSize: 13 }}>
                <i className="fas fa-plus"></i> Nouvelle assurance
              </Link>
            </div>
            <div className="table-responsive">
              <table className="table table-hover mb-0" style={{ fontSize: 13 }}>
                <thead style={{ background: '#f8f9fa' }}>
                  <tr><th>#</th><th>Immatriculation</th><th>Marque</th><th>Catégorie</th><th>Prix TTC</th><th>Début</th><th>Fin</th><th>Statut</th><th>Détails</th></tr>
                </thead>
                <tbody>
                  {loading ? <tr><td colSpan={9} className="text-center p-4">Chargement...</td></tr> :
                  assurances.length === 0 ? <tr><td colSpan={9} className="text-center text-muted p-4">Aucune assurance trouvée. <Link to="/client/devis">Faire un devis</Link></td></tr> :
                  assurances.map((a, i) => (
                    <tr key={a._id}>
                      <td>{i + 1}</td>
                      <td><code>{a.immatriculation}</code></td>
                      <td>{a.id_voiture?.marque || '-'}</td>
                      <td>{a.id_categorie?.genre || '-'}</td>
                      <td><strong>{(a.prix_ttc || 0).toLocaleString()} FCFA</strong></td>
                      <td>{a.date_debut ? new Date(a.date_debut).toLocaleDateString('fr-FR') : '-'}</td>
                      <td>{a.date_fin ? new Date(a.date_fin).toLocaleDateString('fr-FR') : '-'}</td>
                      <td><span className={STATUS_BADGE[a.status] || 'badge-attente'}>{a.status}</span></td>
                      <td>
                        <button className="btn btn-sm btn-outline-primary" onClick={() => setSelected(a)}>
                          <i className="fas fa-eye"></i>
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      {selected && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', zIndex: 2000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20 }}>
          <div style={{ background: 'white', borderRadius: 12, padding: 30, width: '100%', maxWidth: 550, maxHeight: '90vh', overflowY: 'auto' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
              <h5 style={{ color: '#006652', margin: 0 }}>Détails de l'assurance</h5>
              <button onClick={() => setSelected(null)} style={{ border: 'none', background: 'none', fontSize: 20, cursor: 'pointer' }}>×</button>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, fontSize: 14 }}>
              {[
                ['Immatriculation', selected.immatriculation],
                ['Marque', selected.id_voiture?.marque || '-'],
                ['Catégorie', selected.id_categorie?.genre || '-'],
                ['Puissance', `${selected.puissance} CV`],
                ['Énergie', selected.energie === 0 ? 'Essence' : 'Gazoil'],
                ['Places', selected.nombre_place],
                ['Durée', `${selected.nombre_mois} mois`],
                ['Prix HT', `${(selected.prix_ht || 0).toLocaleString()} FCFA`],
                ['Prix TTC', `${(selected.prix_ttc || 0).toLocaleString()} FCFA`],
                ['Début', selected.date_debut ? new Date(selected.date_debut).toLocaleDateString('fr-FR') : '-'],
                ['Fin', selected.date_fin ? new Date(selected.date_fin).toLocaleDateString('fr-FR') : '-'],
                ['Statut', selected.status],
                ['Agent', selected.agents || '-'],
                ['Paiement', selected.mode_paiement || '-'],
                ['Transaction', selected.code_transaction || '-'],
              ].map(([k, v]) => (
                <div key={k} style={{ padding: '8px 0', borderBottom: '1px solid #f0f0f0' }}>
                  <div style={{ fontSize: 11, color: '#999', fontWeight: 600 }}>{k}</div>
                  <div style={{ fontWeight: 500 }}>{v}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
