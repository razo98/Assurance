import ClientSidebar from '../../components/ClientSidebar';
import Topbar from '../../components/Topbar';
import DevisForm from '../../components/DevisForm';

export default function ClientDevis() {
  return (
    <div className="app-shell">
      <ClientSidebar />
      <div className="main-content">
        <Topbar title="Demande de devis" />
        <div className="page-content">
          <DevisForm mode="client" />
        </div>
      </div>
    </div>
  );
}
