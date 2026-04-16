import { useAuth } from '../context/AuthContext';

export default function Topbar({ title }) {
  const { user } = useAuth();
  const initials = user ? `${user.firstname?.[0] || ''}${user.lastname?.[0] || ''}` : '?';
  const now = new Date();
  const dateStr = now.toLocaleDateString('fr-FR', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });

  return (
    <div className="topbar">
      <div>
        <div className="topbar-title">{title}</div>
        <div style={{ fontSize: 12, color: '#aaa', marginTop: 2, textTransform: 'capitalize' }}>{dateStr}</div>
      </div>
      <div className="topbar-user">
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontSize: 14.5, fontWeight: 600, color: '#333' }}>{user?.firstname} {user?.lastname}</div>
          <div style={{ fontSize: 12, color: '#888' }}>{user?.role === 'admin' ? 'Administrateur' : user?.role === 'agent' ? 'Agent' : 'Client'}</div>
        </div>
        <div className="avatar">{initials}</div>
      </div>
    </div>
  );
}
