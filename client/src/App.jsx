import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';

// Pages publiques
import Index from './pages/Index';
import Login from './pages/Login';
import Register from './pages/Register';

// Pages Admin
import AdminDashboard from './pages/admin/Dashboard';
import AdminDevis from './pages/admin/Devis';
import Clients from './pages/admin/Clients';
import Agents from './pages/admin/Agents';
import Voitures from './pages/admin/Voitures';
import Categories from './pages/admin/Categories';
import AdminAssurances from './pages/admin/Assurances';
import AdminReclamations from './pages/admin/Reclamations';
import AdminProfil from './pages/admin/Profil';
import Statistiques from './pages/admin/Statistiques';
import AdminRenouvellement from './pages/admin/Renouvellement';

// Pages Agent
import AgentDashboard from './pages/agent/Dashboard';
import AgentDevis from './pages/agent/Devis';
import AgentAssurances from './pages/agent/Assurances';
import AgentReclamations from './pages/agent/Reclamations';
import AgentProfil from './pages/agent/Profil';
import AgentRenouvellement from './pages/agent/Renouvellement';

// Pages Client
import ClientDashboard from './pages/client/Dashboard';
import ClientDevis from './pages/client/Devis';
import ClientAssurances from './pages/client/Assurances';
import ClientProfil from './pages/client/Profil';
import ClientReclamation from './pages/client/Reclamation';
import ClientRenouvellement from './pages/client/Renouvellement';

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          {/* Publiques */}
          <Route path="/" element={<Index />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />

          {/* Admin */}
          <Route path="/admin/dashboard" element={<ProtectedRoute roles={['admin']}><AdminDashboard /></ProtectedRoute>} />
          <Route path="/admin/devis" element={<ProtectedRoute roles={['admin']}><AdminDevis /></ProtectedRoute>} />
          <Route path="/admin/clients" element={<ProtectedRoute roles={['admin']}><Clients /></ProtectedRoute>} />
          <Route path="/admin/agents" element={<ProtectedRoute roles={['admin']}><Agents /></ProtectedRoute>} />
          <Route path="/admin/voitures" element={<ProtectedRoute roles={['admin']}><Voitures /></ProtectedRoute>} />
          <Route path="/admin/categories" element={<ProtectedRoute roles={['admin']}><Categories /></ProtectedRoute>} />
          <Route path="/admin/assurances" element={<ProtectedRoute roles={['admin']}><AdminAssurances /></ProtectedRoute>} />
          <Route path="/admin/reclamations" element={<ProtectedRoute roles={['admin']}><AdminReclamations /></ProtectedRoute>} />
          <Route path="/admin/statistiques" element={<ProtectedRoute roles={['admin']}><Statistiques /></ProtectedRoute>} />
          <Route path="/admin/renouvellement" element={<ProtectedRoute roles={['admin']}><AdminRenouvellement /></ProtectedRoute>} />
          <Route path="/admin/profil" element={<ProtectedRoute roles={['admin']}><AdminProfil /></ProtectedRoute>} />

          {/* Agent */}
          <Route path="/agent/dashboard" element={<ProtectedRoute roles={['agent','admin']}><AgentDashboard /></ProtectedRoute>} />
          <Route path="/agent/devis" element={<ProtectedRoute roles={['agent','admin']}><AgentDevis /></ProtectedRoute>} />
          <Route path="/agent/assurances" element={<ProtectedRoute roles={['agent','admin']}><AgentAssurances /></ProtectedRoute>} />
          <Route path="/agent/reclamations" element={<ProtectedRoute roles={['agent','admin']}><AgentReclamations /></ProtectedRoute>} />
          <Route path="/agent/renouvellement" element={<ProtectedRoute roles={['agent','admin']}><AgentRenouvellement /></ProtectedRoute>} />
          <Route path="/agent/profil" element={<ProtectedRoute roles={['agent','admin']}><AgentProfil /></ProtectedRoute>} />

          {/* Client */}
          <Route path="/client/dashboard" element={<ProtectedRoute roles={['client']}><ClientDashboard /></ProtectedRoute>} />
          <Route path="/client/devis" element={<ProtectedRoute roles={['client']}><ClientDevis /></ProtectedRoute>} />
          <Route path="/client/assurances" element={<ProtectedRoute roles={['client']}><ClientAssurances /></ProtectedRoute>} />
          <Route path="/client/profil" element={<ProtectedRoute roles={['client']}><ClientProfil /></ProtectedRoute>} />
          <Route path="/client/reclamation" element={<ProtectedRoute roles={['client']}><ClientReclamation /></ProtectedRoute>} />
          <Route path="/client/renouvellement" element={<ProtectedRoute roles={['client']}><ClientRenouvellement /></ProtectedRoute>} />

          {/* Fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
