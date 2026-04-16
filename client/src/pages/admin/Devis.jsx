import AdminSidebar from '../../components/AdminSidebar';
import Topbar from '../../components/Topbar';
import DevisForm from '../../components/DevisForm';

export default function AdminDevis() {
  return (
    <div className="app-shell">
      <AdminSidebar />
      <div className="main-content">
        <Topbar title="Nouvelle assurance" />
        <div className="page-content">
          <DevisForm mode="admin" />
        </div>
      </div>
    </div>
  );
}
