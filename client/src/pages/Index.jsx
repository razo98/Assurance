import { useState, useEffect, useRef } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const SLIDES = ['/img1.jpg', '/img2.jpg', '/img3.jpg'];

export default function Index() {
  const { isAuthenticated, user } = useAuth();
  const navigate = useNavigate();
  const [slide, setSlide] = useState(0);
  const [contactForm, setContactForm] = useState({ name: '', email: '', phone: '', message: '' });
  const [contactSent, setContactSent] = useState(false);
  const intervalRef = useRef(null);

  useEffect(() => {
    intervalRef.current = setInterval(() => {
      setSlide(s => (s + 1) % SLIDES.length);
    }, 5000);
    return () => clearInterval(intervalRef.current);
  }, []);

  const goToDashboard = () => {
    if (user?.role === 'admin') navigate('/admin/dashboard');
    else if (user?.role === 'agent') navigate('/agent/dashboard');
    else navigate('/client/dashboard');
  };

  const handleContact = e => {
    e.preventDefault();
    const { name, email, phone, message } = contactForm;
    window.open(`mailto:abdoulrazaksouleye@gmail.com?subject=Contact depuis le site MBA&body=Nom: ${name}%0D%0AEmail: ${email}%0D%0ATéléphone: ${phone}%0D%0AMessage: ${message}`, '_blank');
    setContactSent(true);
    setContactForm({ name: '', email: '', phone: '', message: '' });
    setTimeout(() => setContactSent(false), 4000);
  };

  const scrollTo = id => {
    document.getElementById(id)?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };

  return (
    <div style={{ fontFamily: "'Inter', 'Segoe UI', sans-serif" }}>

      {/* ===== NAVBAR ===== */}
      <nav style={{
        position: 'fixed', top: 0, left: 0, right: 0, zIndex: 1000,
        height: 72, background: 'rgba(0,30,22,0.88)', backdropFilter: 'blur(10px)',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 40px', boxShadow: '0 2px 20px rgba(0,0,0,0.2)',
        animation: 'fadeIn 0.6s ease'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <img src="/logo.jpg" alt="MBA" style={{ height: 46, width: 46, borderRadius: '50%', objectFit: 'cover', border: '2px solid rgba(255,140,0,0.6)' }} />
          <div>
            <div style={{ color: 'white', fontWeight: 800, fontSize: 17, lineHeight: 1.1 }}>MBA ASSURANCE</div>
            <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: 11 }}>Niger SA</div>
          </div>
        </div>
        <div style={{ display: 'flex', gap: 28, alignItems: 'center' }}>
          {['historique', 'fondements', 'garanties', 'contact'].map(id => (
            <button key={id} onClick={() => scrollTo(id)} style={{
              background: 'none', border: 'none', color: 'rgba(255,255,255,0.82)',
              fontSize: 14.5, cursor: 'pointer', fontWeight: 500, textTransform: 'capitalize',
              transition: 'color 0.2s', padding: 0
            }}
              onMouseEnter={e => e.target.style.color = '#FF8C00'}
              onMouseLeave={e => e.target.style.color = 'rgba(255,255,255,0.82)'}
            >
              {id.charAt(0).toUpperCase() + id.slice(1)}
            </button>
          ))}
          {isAuthenticated ? (
            <button onClick={goToDashboard} style={{
              background: 'linear-gradient(to right, #006652, #FF8C00)',
              border: 'none', color: 'white', padding: '9px 22px', borderRadius: 24,
              fontSize: 14, fontWeight: 600, cursor: 'pointer'
            }}>
              <i className="fas fa-tachometer-alt me-2"></i>Mon espace
            </button>
          ) : (
            <>
              <Link to="/login" style={{ color: 'rgba(255,255,255,0.82)', textDecoration: 'none', fontSize: 14.5, fontWeight: 500 }}>Connexion</Link>
              <Link to="/register" style={{
                background: '#FF8C00', color: 'white', padding: '9px 22px',
                borderRadius: 24, textDecoration: 'none', fontSize: 14, fontWeight: 600
              }}>S'inscrire</Link>
            </>
          )}
        </div>
      </nav>

      {/* ===== HERO SLIDER ===== */}
      <div style={{ position: 'relative', height: '100vh', marginTop: 0, overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {SLIDES.map((src, i) => (
          <div key={i} style={{
            position: 'absolute', inset: 0,
            backgroundImage: `url(${src})`,
            backgroundSize: 'cover', backgroundPosition: 'center',
            opacity: i === slide ? 1 : 0,
            transform: i === slide ? 'scale(1)' : 'scale(1.06)',
            transition: 'opacity 1.2s ease, transform 1.2s ease'
          }} />
        ))}
        {/* Overlay */}
        <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(to bottom, rgba(0,30,22,0.55) 0%, rgba(0,0,0,0.3) 60%, rgba(0,0,0,0.65) 100%)' }} />

        {/* Slider dots */}
        <div style={{ position: 'absolute', bottom: 40, left: '50%', transform: 'translateX(-50%)', display: 'flex', gap: 10, zIndex: 10 }}>
          {SLIDES.map((_, i) => (
            <button key={i} onClick={() => setSlide(i)} style={{
              width: i === slide ? 28 : 10, height: 10, borderRadius: 5,
              background: i === slide ? '#FF8C00' : 'rgba(255,255,255,0.5)',
              border: 'none', cursor: 'pointer', transition: 'all 0.3s ease', padding: 0
            }} />
          ))}
        </div>

        {/* Hero CTA — centered */}
        <div style={{
          position: 'relative', zIndex: 10,
          textAlign: 'center', color: 'white', width: '90%', maxWidth: 800,
          animation: 'fadeIn 1.5s ease 0.5s both'
        }}>
          <h1 style={{ fontSize: 'clamp(2rem, 5vw, 3.5rem)', fontWeight: 800, marginBottom: 32, textShadow: '0 2px 12px rgba(0,0,0,0.4)', lineHeight: 1.2 }}>
            Protection Automobile Sur Mesure
          </h1>
          <Link to={isAuthenticated ? '#' : '/register'} onClick={isAuthenticated ? goToDashboard : undefined} style={{
            display: 'inline-flex', alignItems: 'center', gap: 10,
            background: 'transparent', border: '3px solid greenyellow',
            color: 'greenyellow', padding: '14px 40px', borderRadius: 50,
            fontSize: 16, fontWeight: 700, textDecoration: 'none',
            transition: 'all 0.4s ease', boxShadow: '0 0 0 0 rgba(173,255,47,0.4)'
          }}
            onMouseEnter={e => {
              e.currentTarget.style.background = 'greenyellow';
              e.currentTarget.style.color = '#1a1a1a';
              e.currentTarget.style.boxShadow = '0 0 20px rgba(173,255,47,0.5)';
            }}
            onMouseLeave={e => {
              e.currentTarget.style.background = 'transparent';
              e.currentTarget.style.color = 'greenyellow';
              e.currentTarget.style.boxShadow = '0 0 0 0 rgba(173,255,47,0.4)';
            }}
          >
            <i className="fas fa-shield-alt"></i>
            Souscrire Maintenant
            <i className="fas fa-arrow-right"></i>
          </Link>
        </div>
      </div>

      {/* ===== FONDEMENTS ===== */}
      <section id="fondements" style={{ padding: '90px 0', background: '#f8faf9' }}>
        <div className="container">
          <div style={{ textAlign: 'center', marginBottom: 52 }}>
            <div style={{ display: 'inline-block', background: 'rgba(0,102,82,0.1)', color: '#006652', padding: '6px 18px', borderRadius: 20, fontSize: 13, fontWeight: 600, marginBottom: 16, textTransform: 'uppercase', letterSpacing: '1px' }}>
              Nos Fondements
            </div>
            <h2 style={{ color: '#1a2e25', fontWeight: 800, fontSize: 'clamp(1.6rem,3vw,2.4rem)', margin: 0 }}>Ce qui nous guide</h2>
          </div>
          <div className="row g-4">
            {[
              { icon: '🏅', title: 'Valeurs', color: '#006652', items: ['Intégrité', 'Réactivité', 'Innovation', 'Proximité client'] },
              { icon: '🎯', title: 'Vision', color: '#FF8C00', items: ['Leader régional de l\'assurance automobile innovante', 'Réseau de plus de 40 points de vente nationaux', 'Capital de 3 milliards FCFA'] },
              { icon: '⚡', title: 'Mission', color: '#0d6efd', items: ['Offrir des solutions de protection adaptées à chaque conducteur', 'Couvrir 16 branches d\'assurances dommages', 'Service rapide et personnalisé'] },
            ].map((c, i) => (
              <div className="col-md-4" key={i}>
                <div style={{
                  background: 'white', borderRadius: 16, padding: '32px 28px',
                  boxShadow: '0 4px 20px rgba(0,0,0,0.07)', height: '100%',
                  borderTop: `4px solid ${c.color}`,
                  transition: 'transform 0.25s, box-shadow 0.25s',
                  animation: `slideInUp 0.5s ease ${i * 0.1}s both`
                }}
                  onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-6px)'; e.currentTarget.style.boxShadow = '0 14px 40px rgba(0,0,0,0.12)'; }}
                  onMouseLeave={e => { e.currentTarget.style.transform = ''; e.currentTarget.style.boxShadow = '0 4px 20px rgba(0,0,0,0.07)'; }}
                >
                  <div style={{ fontSize: 40, marginBottom: 16 }}>{c.icon}</div>
                  <h3 style={{ color: c.color, fontWeight: 800, marginBottom: 14, fontSize: 21 }}>{c.title}</h3>
                  <ul style={{ margin: 0, padding: '0 0 0 18px', color: '#555', lineHeight: 2, fontSize: 15 }}>
                    {c.items.map((item, j) => <li key={j}>{item}</li>)}
                  </ul>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ===== GARANTIES ===== */}
      <section id="garanties" style={{ padding: '90px 0', background: 'white' }}>
        <div className="container">
          <div style={{ textAlign: 'center', marginBottom: 52 }}>
            <div style={{ display: 'inline-block', background: 'rgba(255,140,0,0.1)', color: '#FF8C00', padding: '6px 18px', borderRadius: 20, fontSize: 13, fontWeight: 600, marginBottom: 16, textTransform: 'uppercase', letterSpacing: '1px' }}>
              Couvertures
            </div>
            <h2 style={{ color: '#1a2e25', fontWeight: 800, fontSize: 'clamp(1.6rem,3vw,2.4rem)', margin: 0 }}>Nos Garanties</h2>
          </div>
          <div className="row g-3">
            {[
              { icon: 'fas fa-gavel', title: 'Responsabilité Civile', desc: 'Protection juridique complète selon le Code CIMA. Couverture des dommages causés à des tiers.', color: '#006652' },
              { icon: 'fas fa-fire', title: 'Risque Incendie', desc: 'Couverture des dommages causés par le feu, l\'explosion ou la foudre sur votre véhicule.', color: '#dc3545' },
              { icon: 'fas fa-car-crash', title: 'Dommages Accidentels', desc: 'Collisions, renversements et tous cas spéciaux affectant votre véhicule.', color: '#fd7e14' },
              { icon: 'fas fa-user-shield', title: 'Protection Conducteur', desc: 'Couverture des dommages corporels du conducteur en cas d\'accident responsable.', color: '#0d6efd' },
              { icon: 'fas fa-tools', title: 'Assistance Panne', desc: 'Service d\'assistance et de remorquage en cas de panne ou d\'accident sur la voie publique.', color: '#6f42c1' },
              { icon: 'fas fa-hand-holding-usd', title: 'Indemnisation Rapide', desc: 'Procédure simplifiée pour une indemnisation rapide et transparente en cas de sinistre.', color: '#20c997' },
            ].map((g, i) => (
              <div className="col-md-6 col-lg-4" key={i}>
                <div style={{
                  borderLeft: `4px solid ${g.color}`, background: '#f8faf9',
                  padding: '20px 22px', borderRadius: '0 10px 10px 0',
                  display: 'flex', gap: 16, alignItems: 'flex-start',
                  transition: 'all 0.22s', cursor: 'default',
                  animation: `slideInUp 0.45s ease ${i * 0.07}s both`
                }}
                  onMouseEnter={e => { e.currentTarget.style.background = 'white'; e.currentTarget.style.boxShadow = `0 6px 22px ${g.color}22`; e.currentTarget.style.transform = 'translateX(4px)'; }}
                  onMouseLeave={e => { e.currentTarget.style.background = '#f8faf9'; e.currentTarget.style.boxShadow = 'none'; e.currentTarget.style.transform = ''; }}
                >
                  <div style={{ width: 44, height: 44, borderRadius: '50%', background: `${g.color}18`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18, color: g.color, flexShrink: 0 }}>
                    <i className={g.icon}></i>
                  </div>
                  <div>
                    <h5 style={{ color: g.color, fontWeight: 700, marginBottom: 6, fontSize: 16 }}>{g.title}</h5>
                    <p style={{ color: '#666', fontSize: 14, lineHeight: 1.65, margin: 0 }}>{g.desc}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ===== HISTORIQUE ===== */}
      <section id="historique" style={{ padding: '90px 0', background: 'linear-gradient(135deg, #004d3d 0%, #006652 60%, #008a6e 100%)', color: 'white' }}>
        <div className="container">
          <div style={{ textAlign: 'center', marginBottom: 52 }}>
            <div style={{ display: 'inline-block', background: 'rgba(255,255,255,0.15)', color: 'rgba(255,255,255,0.9)', padding: '6px 18px', borderRadius: 20, fontSize: 13, fontWeight: 600, marginBottom: 16, textTransform: 'uppercase', letterSpacing: '1px' }}>
              Notre Histoire
            </div>
            <h2 style={{ fontWeight: 800, fontSize: 'clamp(1.6rem,3vw,2.4rem)', margin: 0 }}>Historique de MBA Niger SA</h2>
          </div>
          <div className="row align-items-center g-5">
            <div className="col-lg-4 text-center">
              <img src="/logo.jpg" alt="MBA Niger SA" style={{ width: 160, height: 160, borderRadius: '50%', objectFit: 'cover', border: '5px solid rgba(255,140,0,0.7)', boxShadow: '0 10px 40px rgba(0,0,0,0.3)' }} />
              <div style={{ marginTop: 20 }}>
                <div style={{ fontSize: 38, fontWeight: 800, color: '#FF8C00' }}>2013</div>
                <div style={{ fontSize: 14, opacity: 0.8 }}>Année de fondation</div>
              </div>
              <div className="row g-3 mt-3">
                {[
                  { val: '40+', label: 'Agents' },
                  { val: '3 Mrd', label: 'Capital FCFA' },
                  { val: '40+', label: 'Points de vente' },
                  { val: '6 Mrd+', label: 'CA prévisionnel FCFA' },
                ].map((s, i) => (
                  <div className="col-6" key={i}>
                    <div style={{ background: 'rgba(255,255,255,0.1)', borderRadius: 10, padding: '12px 8px', textAlign: 'center' }}>
                      <div style={{ fontSize: 20, fontWeight: 800, color: '#FF8C00' }}>{s.val}</div>
                      <div style={{ fontSize: 11, opacity: 0.8 }}>{s.label}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <div className="col-lg-8">
              <div style={{ background: 'rgba(255,255,255,0.1)', borderRadius: 16, padding: '32px 36px', lineHeight: 1.9, fontSize: 15.5, backdropFilter: 'blur(6px)' }}>
                <p style={{ marginBottom: 18 }}>
                  Fondée en <strong style={{ color: '#FF8C00' }}>2013</strong> sous la forme d'une société anonyme avec Conseil d'Administration, <strong>Mutual Benefits Assurance Niger (MBA Niger)</strong> est une compagnie d'assurance régie par le <strong>Code CIMA</strong> et l'Acte Uniforme de l'OHADA. Enregistrée au Registre du Commerce sous la référence <em>RCCM NI-NIA-2013-B-1673</em>, elle débute ses activités le 1er janvier 2014 avec un capital social initial de <strong style={{ color: '#FF8C00' }}>1 milliard FCFA</strong>, entièrement souscrit et libéré.
                </p>
                <p style={{ marginBottom: 18 }}>
                  Agréée par la CIMA (arrêté n°512 du 05/12/2013) pour les assurances IARD, MBA Niger s'est rapidement imposée sur le marché nigérien. Dès sa première année, elle comptait <strong>15 agents</strong> ; aujourd'hui, son effectif dépasse les <strong style={{ color: '#FF8C00' }}>40 agents</strong>, avec un chiffre d'affaires prévisionnel supérieur à <strong>6 milliards FCFA</strong>.
                </p>
                <p style={{ marginBottom: 18 }}>
                  En réponse aux exigences de la CIMA en 2016, son capital a été porté à <strong style={{ color: '#FF8C00' }}>3 milliards FCFA</strong> en 2019. Implantée sur le <strong>Boulevard Tanimoune à Niamey</strong>, MBA Niger s'appuie sur un réseau de plus de 40 points de vente à travers le pays.
                </p>
                <p style={{ margin: 0 }}>
                  Membre actif du <strong>Comité des Assureurs du Niger (CAN)</strong> et de la <strong>FANAF</strong>, elle bénéficie également de l'expertise de <em>Mutual Benefits Assurance PLC Nigeria</em>. MBA Niger opère dans <strong style={{ color: '#FF8C00' }}>16 branches d'assurances dommages</strong>, allant des accidents aux protections juridiques.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ===== NOS SERVICES ===== */}
      <section style={{ padding: '90px 0', background: '#f0f4f8' }}>
        <div className="container">
          <div style={{ textAlign: 'center', marginBottom: 52 }}>
            <div style={{ display: 'inline-block', background: 'rgba(0,102,82,0.1)', color: '#006652', padding: '6px 18px', borderRadius: 20, fontSize: 13, fontWeight: 600, marginBottom: 16, textTransform: 'uppercase', letterSpacing: '1px' }}>
              Pourquoi nous choisir
            </div>
            <h2 style={{ color: '#1a2e25', fontWeight: 800, fontSize: 'clamp(1.6rem,3vw,2.4rem)', margin: 0 }}>Nos Services</h2>
          </div>
          <div className="row g-4">
            {[
              { icon: 'fas fa-calculator', title: 'Devis en ligne', desc: 'Calculez votre prime d\'assurance en quelques clics. Prix immédiat selon votre véhicule et durée.', color: '#006652' },
              { icon: 'fas fa-shield-alt', title: 'Couverture complète', desc: 'VP, Taxi 4/19p, Moto, Camion — tous types de véhicules couverts avec contrats sur mesure.', color: '#0d6efd' },
              { icon: 'fas fa-bolt', title: 'Validation rapide', desc: 'Vos demandes traitées rapidement par notre équipe d\'agents professionnels et dévoués.', color: '#FF8C00' },
              { icon: 'fas fa-sync-alt', title: 'Renouvellement facile', desc: 'Renouvelez votre contrat en quelques clics depuis votre espace personnel ou via un agent.', color: '#6f42c1' },
            ].map((s, i) => (
              <div className="col-md-6 col-lg-3" key={i}>
                <div style={{
                  background: 'white', borderRadius: 14, padding: '30px 24px',
                  textAlign: 'center', boxShadow: '0 4px 18px rgba(0,0,0,0.07)',
                  height: '100%', transition: 'transform 0.25s, box-shadow 0.25s',
                  animation: `slideInUp 0.5s ease ${i * 0.1}s both`
                }}
                  onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-6px)'; e.currentTarget.style.boxShadow = `0 14px 36px ${s.color}22`; }}
                  onMouseLeave={e => { e.currentTarget.style.transform = ''; e.currentTarget.style.boxShadow = '0 4px 18px rgba(0,0,0,0.07)'; }}
                >
                  <div style={{ width: 68, height: 68, background: `${s.color}15`, borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 18px', fontSize: 28, color: s.color }}>
                    <i className={s.icon}></i>
                  </div>
                  <h5 style={{ color: s.color, marginBottom: 12, fontWeight: 700, fontSize: 17 }}>{s.title}</h5>
                  <p style={{ color: '#666', fontSize: 14.5, lineHeight: 1.7, margin: 0 }}>{s.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ===== CONTACT + FOOTER ===== */}
      <footer id="contact" style={{ background: 'linear-gradient(135deg, #004d3d 0%, #006652 100%)', color: 'white', padding: '80px 0 40px' }}>
        <div className="container">
          <div style={{ textAlign: 'center', marginBottom: 52 }}>
            <div style={{ fontSize: 36, marginBottom: 12 }}>📞</div>
            <h2 style={{ fontWeight: 800, fontSize: 'clamp(1.6rem,3vw,2.2rem)', margin: 0, color: '#FF8C00' }}>Contactez-nous</h2>
          </div>

          <div className="row g-4 justify-content-center mb-5">
            {/* Formulaire */}
            <div className="col-lg-6">
              <div style={{ background: 'rgba(255,255,255,0.1)', borderRadius: 14, padding: '30px', backdropFilter: 'blur(6px)' }}>
                {contactSent && (
                  <div style={{ background: 'rgba(40,167,69,0.3)', border: '1px solid rgba(40,167,69,0.5)', borderRadius: 8, padding: '12px 16px', marginBottom: 18, color: '#d4f7e5', fontSize: 14 }}>
                    <i className="fas fa-check-circle me-2"></i>Message envoyé avec succès !
                  </div>
                )}
                <form onSubmit={handleContact}>
                  {[
                    { id: 'name', label: 'Votre nom', type: 'text', placeholder: 'Nom complet' },
                    { id: 'email', label: 'Votre email', type: 'email', placeholder: 'email@exemple.com' },
                    { id: 'phone', label: 'Téléphone', type: 'tel', placeholder: '+227 XX XX XX XX' },
                  ].map(f => (
                    <div key={f.id} style={{ marginBottom: 16 }}>
                      <label style={{ display: 'block', marginBottom: 6, fontSize: 13.5, fontWeight: 500, opacity: 0.9 }}>{f.label}</label>
                      <input
                        type={f.type} value={contactForm[f.id]}
                        onChange={e => setContactForm(cf => ({ ...cf, [f.id]: e.target.value }))}
                        placeholder={f.placeholder} required
                        style={{ width: '100%', padding: '11px 14px', borderRadius: 8, border: '1px solid rgba(255,255,255,0.25)', background: 'rgba(255,255,255,0.15)', color: 'white', fontSize: 14.5 }}
                      />
                    </div>
                  ))}
                  <div style={{ marginBottom: 20 }}>
                    <label style={{ display: 'block', marginBottom: 6, fontSize: 13.5, fontWeight: 500, opacity: 0.9 }}>Votre message</label>
                    <textarea
                      value={contactForm.message}
                      onChange={e => setContactForm(cf => ({ ...cf, message: e.target.value }))}
                      placeholder="Décrivez votre demande..." rows={4} required
                      style={{ width: '100%', padding: '11px 14px', borderRadius: 8, border: '1px solid rgba(255,255,255,0.25)', background: 'rgba(255,255,255,0.15)', color: 'white', fontSize: 14.5, resize: 'vertical' }}
                    />
                  </div>
                  <button type="submit" style={{
                    width: '100%', padding: '13px', background: '#FF8C00', border: 'none',
                    borderRadius: 8, color: 'white', fontSize: 15, fontWeight: 700, cursor: 'pointer',
                    textTransform: 'uppercase', letterSpacing: '1px', transition: 'all 0.2s'
                  }}
                    onMouseEnter={e => e.currentTarget.style.background = '#e07a00'}
                    onMouseLeave={e => e.currentTarget.style.background = '#FF8C00'}
                  >
                    <i className="fas fa-paper-plane me-2"></i>Envoyer
                  </button>
                </form>
              </div>
            </div>

            {/* Infos */}
            <div className="col-lg-4">
              <div style={{ background: 'rgba(255,255,255,0.1)', borderRadius: 14, padding: '30px', backdropFilter: 'blur(6px)', height: '100%' }}>
                <div style={{ textAlign: 'center', marginBottom: 24 }}>
                  <img src="/logo.jpg" alt="MBA" style={{ width: 80, height: 80, borderRadius: '50%', objectFit: 'cover', border: '3px solid rgba(255,140,0,0.6)', marginBottom: 12 }} />
                  <div style={{ fontWeight: 800, fontSize: 18, color: '#FF8C00' }}>MBA Niger SA</div>
                </div>
                {[
                  { icon: 'fas fa-map-marker-alt', text: 'Boulevard Tanimoune, Niamey, Niger' },
                  { icon: 'fas fa-phone', text: '88 88 81 11' },
                  { icon: 'fas fa-envelope', text: 'contact@mbaniger.com' },
                  { icon: 'fas fa-registered', text: 'RC : RCCM NI-NIA-2013-B-1673' },
                  { icon: 'fas fa-certificate', text: 'Agréé CIMA — Arrêté n°512/13' },
                ].map((info, i) => (
                  <div key={i} style={{ display: 'flex', alignItems: 'flex-start', gap: 12, marginBottom: 16 }}>
                    <i className={info.icon} style={{ color: '#FF8C00', marginTop: 3, width: 18, textAlign: 'center', flexShrink: 0 }}></i>
                    <span style={{ fontSize: 14.5, opacity: 0.9, lineHeight: 1.5 }}>{info.text}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div style={{ borderTop: '1px solid rgba(255,255,255,0.2)', paddingTop: 24, textAlign: 'center' }}>
            <p style={{ margin: 0, opacity: 0.6, fontSize: 13.5 }}>
              © {new Date().getFullYear()} MBA Niger SA — RC 1673 NI-NIA-2013-B — Tous droits réservés
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}
