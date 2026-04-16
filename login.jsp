S<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Si une erreur ou un message d'inscription est renvoyé par register.jsp,
    // on ouvre directement l'onglet Inscription.
    boolean openRegistration = false;
    if (request.getAttribute("registrationError") != null || request.getAttribute("registerSuccess") != null) {
        openRegistration = true;
    }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Connexion / Inscription - MBA Niger</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="public/css/1bootstrap.min.css" rel="stylesheet">
  <link href="public/css/2dataTables.bootstrap5.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
  <style>
    /* Réinitialisation et styles globaux */
    * { 
      margin: 0; 
      padding: 0; 
      box-sizing: border-box; 
    }
    
    html, body {
      height: 100%;
      font-family: 'Arial', sans-serif;
    }
    
    body {
      background-color: #f5f5f5;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px 0;
      margin: 0;
    }

    
    .container {
      width: 900px;
      max-width: 95%;
      background-color: #fff;
      border-radius: 5px;
      overflow: hidden;
      display: flex;
      box-shadow: 0 0 10px rgba(0,0,0,0.1);
      height: 650px;
    }
    
    /* Partie gauche */
    .left-section {
      width: 450px;
      background-color: #006652;
      color: white;
      padding: 30px;
      display: flex;
      flex-direction: column;
      align-items: center;
      text-align: center;
    }
    
    .logo-area {
      margin-bottom: 25px;
      text-align: center;
    }
    
    .logo-area img {
      max-width: 80px;
      margin-bottom: 15px;
    }
    
    .logo-area h2 {
      font-size: 20px;
      font-weight: bold;
    }
    
    .welcome-text {
      margin-bottom: 30px;
    }
    
    .welcome-text h1 {
      font-size: 22px;
      margin-bottom: 15px;
    }
    
    .welcome-text p {
      font-size: 14px;
      line-height: 1.5;
    }
    
    .features {
      margin-bottom: 30px;
      text-align: left;
      width: 100%;
    }
    
    .feature-item {
      display: flex;
      align-items: center;
      margin-bottom: 15px;
      font-size: 14px;
    }
    
    .feature-icon {
      background-color: rgba(255, 255, 255, 0.2);
      width: 30px;
      height: 30px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-right: 15px;
      flex-shrink: 0;
    }
    
    .feature-icon i {
      font-size: 14px;
    }
    
    /* Partie droite */
    .right-section {
      flex: 1;
      padding: 30px;
      position: relative;
      display: flex;
      align-items: center;
      justify-content: center;
      max-width: 500px;
      margin: 0 auto;
    }
    
    .forms-slider {
      position: relative;
      width: 100%;
      height: 100%;
      display: flex;
      overflow: hidden;
    }
    
    .form-slide {
      position: absolute;
      width: 100%;
      height: 100%;
      top: 0;
      left: 0;
      transition: transform 0.5s ease-in-out;
      padding-right: 20px;
      overflow-y: auto;
      overflow-x: hidden;
      -ms-overflow-style: none;
      scrollbar-width: none;
    }
    
    .form-slide::-webkit-scrollbar {
      display: none;
      width: 0;
    }
    
    .form-container {
      width: 100%;
      max-width: 350px;
    }
    
    .form-title {
      text-align: center;
      margin-bottom: 25px;
      color: #333;
    }
    
    .form-title h2 {
      font-size: 22px;
      margin-bottom: 10px;
      color: #006652;
      font-weight: bold;
    }
    
    .form-title p {
      font-size: 14px;
      color: #666;
    }
    
    .form-group {
      margin-bottom: 20px;
    }
    
    .form-group label {
      display: block;
      margin-bottom: 8px;
      font-size: 14px;
      color: #333;
      font-weight: 500;
    }
    
    .input-with-icon {
      position: relative;
    }
    
    .input-with-icon i {
      position: absolute;
      left: 12px;
      top: 50%;
      transform: translateY(-50%);
      color: #006652;
      font-size: 16px;
    }
    
    .input-with-icon input {
      width: 100%;
      padding: 12px 12px 12px 40px;
      border: 1px solid #ddd;
      border-radius: 4px;
      font-size: 14px;
    }
    
    .input-with-icon input:focus {
      outline: none;
      border-color: #006652;
      box-shadow: 0 0 0 2px rgba(0, 102, 82, 0.2);
    }
    
    .checkbox-group {
      display: flex;
      align-items: center;
      margin-bottom: 20px;
    }
    
    .checkbox-group input[type="checkbox"] {
      margin-right: 10px;
    }
    
    .checkbox-group label {
      font-size: 14px;
      color: #333;
      margin-bottom: 0;
    }
    
    .btn {
      width: 100%;
      padding: 12px;
      background-color: #006652;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 15px;
      font-weight: bold;
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 8px;
      transition: background-color 0.3s ease;
    }
    
    .btn:hover {
      background-color: #005544;
    }
    
    .form-footer {
      display: flex;
      justify-content: center;
      align-items: center;
      margin-top: 20px;
      font-size: 14px;
      color: #666;
    }
    
    .form-footer a {
      color: #006652;
      text-decoration: none;
      margin-left: 5px;
      transition: text-decoration 0.3s ease;
    }
    
    .form-footer a:hover {
      text-decoration: underline;
    }
    
    .error-message {
      background-color: #f8d7da;
      color: #721c24;
      padding: 10px;
      border-radius: 4px;
      margin-bottom: 20px;
      font-size: 14px;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    
    .success-message {
      background-color: #d4edda;
      color: #155724;
      padding: 10px;
      border-radius: 4px;
      margin-bottom: 20px;
      font-size: 14px;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    
    .home-link {
      color: white;
      text-decoration: none;
      margin-top: auto;
      font-size: 14px;
      display: flex;
      align-items: center;
      background: rgba(255,255,255,0.2);
      padding: 10px 15px;
      border-radius: 4px;
      transition: background 0.3s ease;
    }

    .home-link i {
      margin-right: 8px;
      font-size: 14px;
    }

    .home-link:hover {
      background: rgba(255,255,255,0.3);
    }
    
    .forgot-password {
      text-align: right;
      font-size: 14px;
      margin-bottom: 15px;
    }
    
    .forgot-password a {
      color: #006652;
      text-decoration: none;
      transition: text-decoration 0.3s ease;
    }
    
    .forgot-password a:hover {
      text-decoration: underline;
    }

    /* Adaptations pour mobile */
    @media (max-width: 768px) {
      body {
        align-items: flex-start;
        padding: 20px;
        height: auto;
        min-height: 100%;
      }
      
      .container {
        flex-direction: column;
        width: 100%;
        max-width: 500px;
        height: auto;
        min-height: 100vh;
      }
      
      .left-section, .right-section {
        width: 100%;
        max-width: 100%;
      }
      
      .left-section {
        padding: 25px;
      }
      
      .right-section {
        padding: 25px;
        height: auto;
      }
      
      .forms-slider {
        height: auto;
        min-height: 550px;
      }
      
      .form-slide {
        position: relative;
        height: auto;
      }
      
      .form-container {
        max-width: 100%;
        padding-bottom: 30px;
      }
      
      .features {
        display: none;
      }
      
      .welcome-text {
        margin-bottom: 15px;
      }
      
      .logo-area {
        margin-bottom: 15px;
      }
    }
    
    @media (max-width: 480px) {
      body {
        padding: 10px;
      }
      
      .container {
        width: 100%;
        box-shadow: none;
        border-radius: 8px;
      }
      
      .left-section {
        padding: 20px 15px;
        border-radius: 8px 8px 0 0;
      }
      
      .right-section {
        padding: 20px 15px;
      }
      
      .form-title h2 {
        font-size: 20px;
      }
      
      .form-title p {
        font-size: 13px;
      }
      
      .input-with-icon input {
        font-size: 14px;
      }
      
      .form-group {
        margin-bottom: 15px;
      }
      
      .form-slide {
        padding-right: 5px;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <!-- Partie gauche -->
    <div class="left-section">
      <div class="logo-area">
        <img src="images/logo.jpg" alt="Logo MBA Niger">
        <h2>MBA NIGER</h2>
      </div>
      
      <div class="welcome-text">
        <h1>Bienvenue sur notre plateforme</h1>
        <p>Gérez vos assurances automobile en toute simplicité avec MBA Niger.</p>
      </div>
      
      <div class="features">
        <div class="feature-item">
          <div class="feature-icon">
            <i class="fas fa-shield-alt"></i>
          </div>
          <span>Souscription et renouvellement en ligne</span>
        </div>
        <div class="feature-item">
          <div class="feature-icon">
            <i class="fas fa-file-contract"></i>
          </div>
          <span>Suivi de vos contrats en temps réel</span>
        </div>
        <div class="feature-item">
          <div class="feature-icon">
            <i class="fas fa-credit-card"></i>
          </div>
          <span>Paiement sécurisé multi-canal</span>
        </div>
      </div>
      
      <a href="index.jsp" class="home-link">
        <i class="fas fa-arrow-left"></i>
        Retour à l'accueil
      </a>
    </div>
    
    <!-- Partie droite -->
    <div class="right-section">
      <div class="forms-slider" id="forms-slider">
        <!-- Formulaire de connexion -->
        <div class="form-slide login-slide">
          <div class="form-container">
            <div class="form-title">
              <h2>Authentification</h2>
              <p>Accédez à votre espace personnel</p>
            </div>
            
            <!-- Messages d'erreur ou de succès -->
            <% if (request.getAttribute("loginError") != null) { %>
              <div class="error-message">
                <i class="fas fa-exclamation-circle"></i>
                <%= request.getAttribute("loginError") %>
              </div>
            <% } %>
            
            <% if (request.getAttribute("registerSuccess") != null) { %>
              <div class="success-message">
                <i class="fas fa-check-circle"></i>
                <%= request.getAttribute("registerSuccess") %>
              </div>
            <% } %>
            
            <% if (request.getAttribute("resetSuccess") != null) { %>
              <div class="success-message">
                <i class="fas fa-check-circle"></i>
                <%= request.getAttribute("resetSuccess") %>
              </div>
            <% } %>
            
            <form id="loginForm" action="validelogin.jsp" method="POST" autocomplete="off">
              <div class="form-group">
                <label for="username">Email ou nom d'utilisateur</label>
                <div class="input-with-icon">
                  <i class="fas fa-user"></i>
                  <input type="text" id="username" name="username" placeholder="Entrez votre email ou nom d'utilisateur" required>
                </div>
              </div>
              
              <div class="form-group">
                <label for="password">Mot de passe</label>
                <div class="input-with-icon">
                  <i class="fas fa-lock"></i>
                  <input type="password" id="password" name="password" placeholder="Entrez votre mot de passe" required autocomplete="new-password">
                </div>
              </div>
              
              <div class="checkbox-group">
                <input type="checkbox" id="adminLoginCheck" name="isAdmin" value="true">
                <label for="adminLoginCheck">Se connecter en tant qu'administrateur</label>
              </div>
              
              <!-- Champ matricule, masqué par défaut -->
              <div class="form-group" id="matricule-group" style="display: none;">
                <label for="matriculeLoginField">Matricule</label>
                <div class="input-with-icon">
                  <i class="fas fa-id-badge"></i>
                  <input type="text" id="matriculeLoginField" name="matricule" placeholder="Entrez votre matricule" disabled>
                </div>
              </div>
              
              <div class="forgot-password">
                <a href="forgot-password.jsp">Mot de passe oublié ?</a>
              </div>
              
              <button type="submit" class="btn">
                <i class="fas fa-sign-in-alt"></i>
                Se connecter
              </button>
            </form>
            
            <div class="form-footer">
              <p>Vous n'avez pas de compte?<a href="#" id="switch-to-register">Inscrivez-vous</a></p>
            </div>
          </div>
        </div>
        
        <!-- Formulaire d'inscription -->
        <div class="form-slide register-slide">
          <div class="form-container">
            <div class="form-title">
              <h2>Créer un compte</h2>
              <p>Rejoignez la communauté MBA Niger</p>
            </div>
            
            <!-- Message d'erreur d'inscription -->
            <% if (request.getAttribute("registrationError") != null) { %>
              <div class="error-message">
                <i class="fas fa-exclamation-circle"></i>
                <%= request.getAttribute("registrationError") %>
              </div>
            <% } %>
            
            <form id="signupForm" action="register.jsp" method="POST" autocomplete="off">
              <div class="form-group">
                <label for="firstname">Prénom</label>
                <div class="input-with-icon">
                  <i class="fas fa-user"></i>
                  <input type="text" id="firstname" name="firstname" placeholder="Entrez votre prénom" required>
                </div>
              </div>
              
              <div class="form-group">
                <label for="lastname">Nom</label>
                <div class="input-with-icon">
                  <i class="fas fa-user"></i>
                  <input type="text" id="lastname" name="lastname" placeholder="Entrez votre nom" required>
                </div>
              </div>
              
              <div class="form-group">
                <label for="email">Email</label>
                <div class="input-with-icon">
                  <i class="fas fa-envelope"></i>
                  <input type="email" id="email" name="email" placeholder="Entrez votre adresse email" required>
                </div>
              </div>
              
              <div class="form-group">
                <label for="register-username">Nom d'utilisateur</label>
                <div class="input-with-icon">
                  <i class="fas fa-user-tag"></i>
                  <input type="text" id="register-username" name="username" placeholder="Choisissez un nom d'utilisateur" required>
                </div>
              </div>
              
              <div class="form-group">
                <label for="number">Téléphone</label>
                <div class="input-with-icon">
                  <i class="fas fa-phone"></i>
                  <input type="tel" id="number" name="number" placeholder="Entrez votre numéro de téléphone" required>
                </div>
              </div>
              
              <div class="form-group">
                <label for="register-password">Mot de passe</label>
                <div class="input-with-icon">
                  <i class="fas fa-lock"></i>
                  <input type="password" id="register-password" name="password" placeholder="Créez un mot de passe" required autocomplete="new-password">
                </div>
              </div>
              
              <div class="form-group">
                <label for="confirm-password">Confirmer le mot de passe</label>
                <div class="input-with-icon">
                  <i class="fas fa-lock"></i>
                  <input type="password" id="confirm-password" name="confirmPassword" placeholder="Confirmez votre mot de passe" required autocomplete="new-password">
                </div>
              </div>
              
              <div class="checkbox-group">
                <input type="checkbox" id="acceptTerms" name="acceptTerms" required>
                <label for="acceptTerms">J'accepte les conditions d'utilisation</label>
              </div>
              
              <button type="submit" class="btn">
                <i class="fas fa-user-plus"></i>
                S'inscrire
              </button>
            </form>
            
            <div class="form-footer">
              <p>Vous avez déjà un compte?<a href="#" id="switch-to-login">Connectez-vous</a></p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <script>
    // Éléments DOM
    const formsSlider = document.getElementById('forms-slider');
    const loginSlide = document.querySelector('.login-slide');
    const registerSlide = document.querySelector('.register-slide');
    const switchToRegister = document.getElementById('switch-to-register');
    const switchToLogin = document.getElementById('switch-to-login');
    const adminLoginCheck = document.getElementById('adminLoginCheck');
    const matriculeGroup = document.getElementById('matricule-group');
    const matriculeLoginField = document.getElementById('matriculeLoginField');
    const signupForm = document.getElementById('signupForm');
    const password = document.getElementById('register-password');
    const confirmPassword = document.getElementById('confirm-password');
    
    // Fonction pour faire glisser vers l'inscription
    function slideToRegister(e) {
      e.preventDefault();
      
      // Ajustement pour mobile
      if (window.innerWidth <= 768) {
        loginSlide.style.display = 'none';
        registerSlide.style.display = 'block';
        registerSlide.style.transform = 'translateX(0)';
      } else {
        loginSlide.style.transform = 'translateX(-100%)';
        registerSlide.style.transform = 'translateX(0)';
      }
    }
    
    // Fonction pour faire glisser vers la connexion
    function slideToLogin(e) {
      e.preventDefault();
      
      // Ajustement pour mobile
      if (window.innerWidth <= 768) {
        loginSlide.style.display = 'block';
        registerSlide.style.display = 'none';
        loginSlide.style.transform = 'translateX(0)';
      } else {
        loginSlide.style.transform = 'translateX(0)';
        registerSlide.style.transform = 'translateX(100%)';
      }
    }
    
    // Ouvrir directement l'onglet inscription si on a un message d'erreur ou success d'inscription
    window.addEventListener('DOMContentLoaded', function() {
      // Initialiser la position des slides
      if (window.innerWidth <= 768) {
        // Pour mobile
        loginSlide.style.display = 'block';
        registerSlide.style.display = 'none';
      } else {
        // Pour desktop
        loginSlide.style.transform = 'translateX(0)';
        registerSlide.style.transform = 'translateX(100%)';
      }
      
      <% if (openRegistration) { %>
        slideToRegister({ preventDefault: () => {} });
      <% } %>
    });
    
    // Ajuster les slides lors du redimensionnement de la fenêtre
    window.addEventListener('resize', function() {
      if (window.innerWidth <= 768) {
        // Pour mobile
        if (registerSlide.style.transform === 'translateX(0px)' || registerSlide.style.display === 'block') {
          loginSlide.style.display = 'none';
          registerSlide.style.display = 'block';
        } else {
          loginSlide.style.display = 'block';
          registerSlide.style.display = 'none';
        }
      } else {
        // Pour desktop
        loginSlide.style.display = 'block';
        registerSlide.style.display = 'block';
        
        if (registerSlide.style.transform === 'translateX(0px)' || registerSlide.style.display === 'block') {
          loginSlide.style.transform = 'translateX(-100%)';
          registerSlide.style.transform = 'translateX(0)';
        } else {
          loginSlide.style.transform = 'translateX(0)';
          registerSlide.style.transform = 'translateX(100%)';
        }
      }
    });
    
    // Événements pour basculer entre connexion et inscription
    switchToRegister.addEventListener('click', slideToRegister);
    switchToLogin.addEventListener('click', slideToLogin);
    
    // Gestion de l'affichage du champ matricule
    adminLoginCheck.addEventListener('change', function() {
      if (this.checked) {
        matriculeGroup.style.display = 'block';
        matriculeLoginField.disabled = false;
        matriculeLoginField.required = true;
      } else {
        matriculeGroup.style.display = 'none';
        matriculeLoginField.disabled = true;
        matriculeLoginField.required = false;
        matriculeLoginField.value = '';
      }
    });
    
    // Validation du mot de passe lors de l'inscription
    signupForm.addEventListener('submit', function(e) {
      if (password.value !== confirmPassword.value) {
        e.preventDefault();
        
        // Vérifier s'il y a déjà un message d'erreur
        let errorDiv = document.querySelector('.password-error');
        
        if (!errorDiv) {
          // Créer un message d'erreur
          errorDiv = document.createElement('div');
          errorDiv.className = 'error-message password-error';
          errorDiv.innerHTML = '<i class="fas fa-exclamation-circle"></i> Les mots de passe ne correspondent pas';
          
          // Insérer après le champ de confirmation
          confirmPassword.parentElement.parentElement.after(errorDiv);
        }
      }
    });
    
    // Réinitialiser l'erreur de mot de passe lors de la saisie
    [password, confirmPassword].forEach(input => {
      input.addEventListener('input', function() {
        const errorDiv = document.querySelector('.password-error');
        if (errorDiv) {
          errorDiv.remove();
        }
      });
    });
  </script>
</body>
</html>