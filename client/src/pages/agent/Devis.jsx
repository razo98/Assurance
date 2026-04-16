import AgentSidebar from '../../components/AgentSidebar';
import Topbar from '../../components/Topbar';
import DevisForm from '../../components/DevisForm';

export default function AgentDevis() {
  return (
    <div className="app-shell">
      <AgentSidebar />
      <div className="main-content">
        <Topbar title="Nouvelle assurance" />
        <div className="page-content">
          <DevisForm mode="agent" />
        </div>
      </div>
    </div>
  );
}
