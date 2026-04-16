<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MBA Niger - Assurance Auto</title>
    <link href="../public/css/1bootstrap.min.css" rel="stylesheet">
    <link href="../public/css/2dataTables.bootstrap5.min.css" rel="stylesheet">
    <style>
        :root {
            --orange: #FF6B00;
            --vert: #2E7D32;
            --blanc: #FFFFFF;
            --transition: all 0.6s cubic-bezier(0.165, 0.84, 0.44, 1);
        }
        
        body {
            background-color: #fdfdfd;
            opacity: 0;
            animation: fadeInBody 1s ease forwards;
        }

        @keyframes fadeInBody {
            to { opacity: 1; }
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Arial', sans-serif;
        }

        /* Navigation */
        .navbar {
            height: 80px;
            position: fixed;
            top: 0;
            width: 100%;
            background: rgb(206, 207, 210);
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            z-index: 1000;
            transform: translateY(-100%);
            animation: slideInNav 0.8s ease forwards;
        }

        @keyframes slideInNav {
            to { transform: translateY(0); }
        }

        .nav-container {
            height: 100%;
            padding: 0 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 1200px;
            margin: 0 auto;
        }

        .logo-container {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .logo-img {
            height: 50px;
            width: auto;
        }

        .logo-text {
            font-size: 1.5rem;
            color: var(--vert);
            font-weight: bold;
        }

        .nav-links {
            display: flex;
            gap: 2rem;
            list-style: none;
            margin-left: auto;
            margin-right: 2rem;
        }

        .nav-links li {
            display: inline-block;
        }

        .nav-links a {
            text-decoration: none;
            color: var(--vert);
            font-weight: 500;
            position: relative;
            transition: var(--transition);
        }

        .nav-links a::after {
            content: '';
            position: absolute;
            width: 0;
            height: 2px;
            bottom: -5px;
            left: 0;
            background: var(--orange);
            transition: var(--transition);
        }

        .nav-links a:hover::after {
            width: 100%;
        }

        .nav-links a:hover {
            color: var(--orange);
        }
        
        /* Bouton de connexion dans la navbar */
        .login-btn {
            background-color: var(--vert);
            color: var(--blanc);
            padding: 8px 16px;
            border-radius: 20px;
            text-decoration: none;
            transition: var(--transition);
            font-weight: 500;
            border: 2px solid var(--vert);
            white-space: nowrap;
        }
        
        .login-btn:hover {
            background-color: var(--orange);
            color: var(--blanc);
            border-color: var(--orange);
            transform: translateY(-3px);
            box-shadow: 0 5px 10px rgba(0,0,0,0.1);
        }

        /* Hero Slider */
        .hero-slider {
            height: calc(100vh - 80px);
            margin-top: 80px;
            position: relative;
            overflow: hidden;
        }

        .slide {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            opacity: 0;
            transform: scale(1.1);
            transition: all 1s ease-in-out;
            background-size: cover;
            background-position: center;
        }

        .slide.active {
            opacity: 1;
            transform: scale(1);
        }

        .hero-content {
            position: absolute;
            top: 85%;
            left: 50%;
            transform: translate(-50%, -50%);
            text-align: center;
            color: var(--blanc);
            z-index: 100;
            width: 90%;
            opacity: 0;
            animation: fadeInContent 1.5s ease forwards 0.5s;
        }

        @keyframes fadeInContent {
            from { opacity: 0; transform: translate(-50%, -40%); }
            to { opacity: 1; transform: translate(-50%, -50%); }
        }

        /* Sections */
        .section {
            padding: 4rem 2rem;
            max-width: 1200px;
            margin: 0 auto;
            opacity: 0;
            transform: translateY(50px);
            transition: var(--transition);
        }

        .section.visible {
            opacity: 1;
            transform: translateY(0);
        }

        .grid-3 {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }

        .card {
            background: #ffffff;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            transition: var(--transition);
            cursor: pointer;
            opacity: 0;
            transform: translateY(30px);
        }

        .card.visible {
            opacity: 1;
            transform: translateY(0);
        }

        .card:hover {
            transform: translateY(-10px) scale(1.02);
            box-shadow: 0 12px 20px rgba(0,0,0,0.15);
        }

        .guarantee-box {
            border-left: 4px solid var(--orange);
            padding: 1rem;
            margin: 1rem 0;
            background: #f8f8f8;
            transition: var(--transition);
            opacity: 0;
            transform: translateX(-20px);
        }

        .guarantee-box.visible {
            opacity: 1;
            transform: translateX(0);
        }

/* From Uiverse.io by gharsh11032000 */ 
.animated-button {
  position: relative;
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 16px 36px;
  border: 4px solid;
  border-color: transparent;
  font-size: 16px;
  background-color: inherit;
  border-radius: 100px;
  left: 40%;
  font-weight: 600;
  color: greenyellow;
  box-shadow: 0 0 0 2px greenyellow;
  cursor: pointer;
  overflow: hidden;
  transition: all 0.6s cubic-bezier(0.23, 1, 0.32, 1);
}

.animated-button svg {
  position: absolute;
  width: 24px;
  fill: greenyellow;
  z-index: 9;
  transition: all 0.8s cubic-bezier(0.23, 1, 0.32, 1);
}

.animated-button .arr-1 {
  right: 16px;
}

.animated-button .arr-2 {
  left: -25%;
}

.animated-button .circle {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 20px;
  height: 20px;
  background-color: greenyellow;
  border-radius: 50%;
  opacity: 0;
  transition: all 0.8s cubic-bezier(0.23, 1, 0.32, 1);
}

.animated-button .text {
  position: relative;
  z-index: 1;
  transform: translateX(-12px);
  transition: all 0.8s cubic-bezier(0.23, 1, 0.32, 1);
}

.animated-button:hover {
  box-shadow: 0 0 0 12px transparent;
  color: #212121;
  border-radius: 12px;
}

.animated-button:hover .arr-1 {
  right: -25%;
}

.animated-button:hover .arr-2 {
  left: 16px;
}

.animated-button:hover .text {
  transform: translateX(12px);
}

.animated-button:hover svg {
  fill: #212121;
}

.animated-button:active {
  scale: 0.95;
  box-shadow: 0 0 0 4px greenyellow;
}

.animated-button:hover .circle {
  width: 220px;
  height: 220px;
  opacity: 1;
}
 
/* Formulaire de contact */
.contact-section {
  width: 100%;
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  gap: 30px;
  padding: 0;
  max-width: 900px;
  margin: 0 auto;
}

.contact-form-container {
  flex: 1;
  min-width: 280px;
  max-width: 500px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}

.contact-form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.form-group {
  margin-bottom: 12px;
}

.contact-form input,
.contact-form textarea {
  width: 100%;
  padding: 10px 15px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.2);
  color: var(--blanc);
  font-size: 15px;
  transition: var(--transition);
}

.contact-form input::placeholder,
.contact-form textarea::placeholder {
  color: rgba(255, 255, 255, 0.8);
}

.contact-form input:focus,
.contact-form textarea:focus {
  outline: none;
  border-color: var(--orange);
  background: rgba(255, 255, 255, 0.25);
}

.submit-btn {
  background-color: var(--orange);
  color: var(--blanc);
  padding: 10px 25px;
  border: none;
  border-radius: 6px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: var(--transition);
  text-transform: uppercase;
  letter-spacing: 1px;
  box-shadow: 0 3px 8px rgba(0, 0, 0, 0.2);
}

.submit-btn:hover {
  background-color: #ff8124;
  transform: translateY(-2px);
  box-shadow: 0 5px 12px rgba(0, 0, 0, 0.3);
}

.contact-info-container {
  flex: 0 0 250px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.contact-info {
  padding: 20px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 10px;
  line-height: 1.6;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}

.contact-info h4 {
  color: var(--orange);
  margin-bottom: 12px;
  font-size: 18px;
}

/* Footer */
footer {
    padding: 3rem 2rem;
    text-align: center;
    background: var(--vert);
    color: var(--blanc);
    opacity: 0;
    transform: translateY(50px);
    transition: var(--transition);
}

footer.visible {
    opacity: 1;
    transform: translateY(0);
}

footer h3 {
    color: var(--orange);
    margin-bottom: 25px;
}

/* Media Queries */
@media (max-width: 768px) {
    .login-btn {
        padding: 6px 12px;
        font-size: 14px;
    }
    
    .nav-links {
        display: none;
    }
    
    .hero-slider {
        height: 70vh;
    }
    
    .btn {
        display: block;
        width: 100%;
        margin: 1rem 0;
    }
    
    .navbar {
        height: 70px;
    }
    
    .logo-img {
        height: 40px;
    }
    
    .contact-section {
        flex-direction: column;
        align-items: center;
    }
    
    .contact-form-container,
    .contact-info-container {
        width: 100%;
        max-width: 100%;
    }
}
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar">
        <div class="nav-container">
            <div class="logo-container">
                <img src="images/logo.jpg" alt="MBA Logo" class="logo-img">
                <div class="logo-text">MBA ASSURANCE</div>
            </div>
            <ul class="nav-links">
                <li><a href="#historique">Historique</a></li>
                <li><a href="#fondements">Fondements</a></li>
                <li><a href="#garanties">Garanties</a></li>
                <li><a href="#contact">Contact</a></li>
            </ul>
            <a href="login.jsp" class="login-btn">Connexion</a>
        </div>
    </nav>

    <!-- Hero Slider -->
    <div class="hero-slider">
        <div class="slide active" style="background-image: url('images/img1.jpg')"></div>
        <div class="slide" style="background-image: url('images/img2.jpg')"></div>
        <div class="slide" style="background-image: url('images/img3.jpg')"></div>
        
        <div class="hero-content">
            <h1 style="font-size: 3rem; margin-bottom: 2rem;">Protection Automobile Sur Mesure</h1>
            <div>
                <a href="login.jsp"><!-- From Uiverse.io by gharsh11032000 --> 
<button class="animated-button">
  <svg viewBox="0 0 24 24" class="arr-2" xmlns="http://www.w3.org/2000/svg">
    <path
      d="M16.1716 10.9999L10.8076 5.63589L12.2218 4.22168L20 11.9999L12.2218 19.778L10.8076 18.3638L16.1716 12.9999H4V10.9999H16.1716Z"
    ></path>
  </svg>
  <span class="text">Souscrire Maintenant </span>
  <span class="circle"></span>
  <svg viewBox="0 0 24 24" class="arr-1" xmlns="http://www.w3.org/2000/svg">
    <path
      d="M16.1716 10.9999L10.8076 5.63589L12.2218 4.22168L20 11.9999L12.2218 19.778L10.8076 18.3638L16.1716 12.9999H4V10.9999H16.1716Z"
    ></path>
  </svg>
</button>
</a>
            </div>
        </div>
    </div>

    <!-- Fondements -->
    <section id="fondements" class="section">
        <h2>Nos Fondements</h2>
        <div class="grid-3">
            <div class="card">
                <h3>🏅 Valeurs</h3>
                <p>• Intégrité<br>• Réactivité<br>• Innovation</p>
            </div>
            <div class="card">
                <h3>🎯 Vision</h3>
                <p>Leader régional de l'assurance automobile innovante d'ici 2025</p>
            </div>
            <div class="card">
                <h3>⚡ Mission</h3>
                <p>Offrir des solutions de protection adaptées à chaque conducteur</p>
            </div>
        </div>
    </section>

    <!-- Garanties -->
    <section id="garanties" class="section">
        <h2>Nos Couvertures</h2>
        <div class="guarantee-box">
            <h3>🛡️ Responsabilité Civile</h3>
            <p>Protection juridique complète selon Code CIMA</p>
        </div>
        <div class="guarantee-box">
            <h3>🔥 Risque Incendie</h3>
            <p>Couverture des dommages par feu/explosion</p>
        </div>
        <div class="guarantee-box">
            <h3>🚗 Dommages Accidentels</h3>
            <p>Collisions, renversements et cas spéciaux</p>
        </div>
    </section>
        <!-- Historique -->
    <section id="historique" class="section">
        <h2>Historique</h2><br>
        <div class="card" >
            <p>Fondée en 2013 sous la forme d'une société anonyme avec Conseil d'Administration, Mutual Benefits Assurance Niger (MBA Niger) est une compagnie d'assurance régie par le Code CIMA et l'Acte Uniforme de l'OHADA. Enregistrée au Registre du Commerce sous la référence RCCM NI-NIA-2013-B-1673, elle débute ses activités le 1er janvier 2014 avec un capital social initial de 1 milliard FCFA, entièrement souscrit et libéré. Agréée par la CIMA (arrêté n°512 du 05/12/2013) pour les assurances IARD, MBA Niger s'est rapidement imposée sur le marché nigérien. Dès sa première année, elle comptait 15 agents ; aujourd'hui, son effectif dépasse les 40 agents, avec un chiffre d'affaires prévisionnel supérieur à 6 milliards FCFA. En réponse aux exigences de la CIMA en 2016, son capital a été porté à 3 milliards FCFA en 2019. Implantée sur le boulevard Tanimoune à Niamey, MBA Niger s'appuie sur un réseau de plus de 40 points de vente à travers le pays, géré par des mandataires (agents généraux et courtiers). Membre actif du Comité des Assureurs du Niger (CAN) et de la Fédération des Sociétés d'Assurances de droit National Africaines (FANAF), elle bénéficie également de l'expertise de Mutual Benefits Assurance PLC Nigeria, une entité d'un groupe international présent dans plusieurs secteurs et pays africains. Dès sa création, MBA Niger s'est fixé pour objectif d'opérer dans 16 branches d'assurances dommages, allant des accidents aux protections juridiques, en passant par la responsabilité civile et les dommages aux biens, offrant ainsi des solutions complètes et personnalisées à ses clients.</p>
        </div>
    </section>

    <!-- Footer avec formulaire de contact -->
    <footer id="contact">
        <h3>📞 Contactez-nous</h3>
        
        <div class="contact-section">
            <div class="contact-form-container">
                <form id="contact-form" class="contact-form" action="javascript:void(0);" onsubmit="sendEmail()">
                    <div class="form-group">
                        <input type="text" id="name" name="name" placeholder="Votre nom" required>
                    </div>
                    <div class="form-group">
                        <input type="email" id="email" name="email" placeholder="Votre email" required>
                    </div>
                    <div class="form-group">
                        <input type="tel" id="phone" name="phone" placeholder="Téléphone" required>
                    </div>
                    <div class="form-group">
                        <textarea id="message" name="message" placeholder="Votre message" rows="4" required></textarea>
                    </div>
                    <button type="submit" class="submit-btn">ENVOYER</button>
                </form>
            </div>
            
            <div class="contact-info-container">
                <div class="contact-info">
                    <h4>Coordonnées</h4>
                    <p>Boulevard Tanimoune, Niamey<br>
                       ☎ 88 88 81 11<br>
                       📧 contact@mbaniger.com</p>
                </div>
            </div>
        </div>
        
        <p style="margin-top: 20px; text-align: center;">© 2023 MBA Niger SA - RC 1673 NI-NIA-2013-B</p>
    </footer>

    <script>
        // Improved carousel
        let currentSlide = 0;
        const slides = document.querySelectorAll('.slide');
        
        function nextSlide() {
            slides[currentSlide].classList.remove('active');
            currentSlide = (currentSlide + 1) % slides.length;
            slides[currentSlide].classList.add('active');
        }
        
        setInterval(nextSlide, 5000);

        // Enhanced scroll animations
        function checkVisibility() {
            const elements = document.querySelectorAll('.section, .card, .guarantee-box, footer');
            const windowHeight = window.innerHeight;

            elements.forEach((el, index) => {
                const rect = el.getBoundingClientRect();
                if (rect.top <= windowHeight * 0.8) {
                    el.classList.add('visible');
                    el.style.transitionDelay = `${index * 0.1}s`;
                }
            });
        }

        // Smooth scroll with easing
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', (e) => {
                e.preventDefault();
                const target = document.querySelector(anchor.getAttribute('href'));
                const start = window.pageYOffset;
                const distance = target.offsetTop - 80;
                let startTime = null;

                function animation(currentTime) {
                    if (!startTime) startTime = currentTime;
                    const timeElapsed = currentTime - startTime;
                    const run = ease(timeElapsed, start, distance - start, 1000);
                    window.scrollTo(0, run);
                    if (timeElapsed < 1000) requestAnimationFrame(animation);
                }

                function ease(t, b, c, d) {
                    t /= d / 2;
                    if (t < 1) return c / 2 * t * t + b;
                    t--;
                    return -c / 2 * (t * (t - 2) - 1) + b;
                }

                requestAnimationFrame(animation);
            });
        });
        
        // Fonction pour envoyer l'email de contact
        function sendEmail() {
            const name = document.getElementById('name').value;
            const email = document.getElementById('email').value;
            const phone = document.getElementById('phone').value;
            const message = document.getElementById('message').value;
            
            // Dans un environnement réel, ceci serait connecté à un service d'email backend
            // Voici une simulation pour le moment
            const mailtoLink = `mailto:abdoulrazaksouleye@gmail.com?subject=Contact depuis le site MBA&body=Nom: ${name}%0D%0AEmail: ${email}%0D%0ATéléphone: ${phone}%0D%0AMessage: ${message}`;
            
            // Ouvrir le client email de l'utilisateur
            window.open(mailtoLink, '_blank');
            
            // Réinitialiser le formulaire après l'envoi
            document.getElementById('contact-form').reset();
            
            // Afficher un message de confirmation
            alert('Votre message a été envoyé avec succès!');
        }

        // Event listeners
        window.addEventListener('scroll', checkVisibility);
        window.addEventListener('load', checkVisibility);
    </script>
</body>
</html>