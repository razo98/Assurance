<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Récupérer les informations de l'utilisateur connecté
    String userFirstname = (String) session.getAttribute("firstname");
    String userLastname = (String) session.getAttribute("lastname");
    String userEmail = (String) session.getAttribute("email"); 
    
    // Variables pour stocker les informations du profil
    String profileImageUrl = "../images/profil.png"; // Image de profil par défaut
%>
<style>
    /* Variables globales pour assurer la cohérence */
    :root {
        --primary-color: #006652;
        --secondary-color: #e6f3f0;
        --text-color: #333;
        --primary-dark: #00a86b;
        --danger-color: #dc3545;
    }

    /* Styles pour le menu hamburger et la navbar */
    #hamburger-btn {
        background: none;
        border: none;
        color: white;
        font-size: 24px;
        cursor: pointer;
        padding: 5px 10px;
        border-radius: 5px;
        transition: background-color 0.3s;
    }

    #hamburger-btn:hover {
        background-color: rgba(255,255,255,0.1);
    }

    /* Barre de navigation principale */
    .main-navbar {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 60px;
        background-color: var(--primary-color);
        color: white;
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0 20px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        z-index: 1000;
    }

    /* Style du titre du site */
    .site-title {
        font-size: 20px;
        font-weight: bold;
        flex-grow: 1;
        text-align: center;
    }

    /* Dropdown dans la navbar */
    .navbar-dropdown {
        position: relative;
    }

    .dropdown-btn {
        background: rgba(255,255,255,0.1);
        color: white;
        border: none;
        padding: 8px 15px;
        border-radius: 5px;
        cursor: pointer;
        display: flex;
        align-items: center;
        transition: background-color 0.3s;
    }

    .dropdown-btn i {
        margin-left: 8px;
    }

    .dropdown-btn:hover {
        background-color: rgba(255,255,255,0.2);
    }

    .dropdown-menu {
        display: none;
        position: absolute;
        right: 0;
        top: 100%;
        background-color: white;
        min-width: 200px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        border-radius: 5px;
        z-index: 1100;
        overflow: hidden;
    }

    .dropdown-menu.show {
        display: block;
    }

    .dropdown-menu a {
        display: flex;
        align-items: center;
        padding: 12px 15px;
        color: var(--text-color);
        text-decoration: none;
        transition: background-color 0.3s;
    }

    .dropdown-menu a i {
        margin-right: 10px;
        color: var(--primary-color);
    }

    .dropdown-menu a:hover {
        background-color: var(--secondary-color);
    }

    /* Modal pour ajouter un client */
    .modal {
        display: none;
        position: fixed;
        z-index: 2000;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        overflow: auto;
        background-color: rgba(0,0,0,0.5);
    }

    .modal-content {
        background-color: #fff;
        margin: 5% auto;
        padding: 20px;
        border-radius: 8px;
        width: 400px;
        position: relative;
        max-width: 90%;
    }

    .modal-content h3 {
        text-align: center;
        margin-bottom: 20px;
        color: var(--primary-color);
    }

    .modal-content form input {
        width: 100%;
        padding: 10px;
        margin: 10px 0;
        border: 1px solid #ccc;
        border-radius: 4px;
    }

    .modal-content form button {
        width: 100%;
        padding: 10px;
        background-color: var(--primary-color);
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        transition: background-color 0.3s;
        margin-top: 10px;
    }

    .modal-content form button:hover {
        background-color: var(--primary-dark);
    }

    .modal-close {
        color: #aaa;
        position: absolute;
        top: 10px;
        right: 15px;
        font-size: 28px;
        font-weight: bold;
        cursor: pointer;
    }

    .modal-close:hover {
        color: #000;
    }
    
    /* Style pour les messages d'erreur */
    .error-message {
        color: var(--danger-color);
        margin-top: 5px;
        font-size: 14px;
        display: none;
    }
    
    /* Style pour la case à cocher des conditions */
    .terms-checkbox {
        display: flex;
        align-items: center;
        margin: 15px 0;
    }
    
    .terms-checkbox input {
        width: auto !important;
        margin-right: 10px !important;
    }
    
    .terms-checkbox label {
        font-size: 14px;
        color: var(--text-color);
    }

    /* Reste des styles du menu latéral (inchangés) */
    #sidebar-menu {
        position: fixed;
        top: 60px;
        left: -250px;
        width: 250px;
        height: calc(100% - 60px);
        background-color: var(--primary-color);
        transition: left 0.3s ease;
        z-index: 999;
        overflow-y: auto;
        padding-top: 0;
    }

    #sidebar-menu.active {
        left: 0;
    }

    /* Styles pour le profil */
    .sidebar-profile {
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
        padding: 25px 20px;
        background-color: rgba(255,255,255,0.1);
        border-bottom: 1px solid rgba(255,255,255,0.1);
    }

    .profile-image {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        overflow: hidden;
        margin-bottom: 15px;
        border: 3px solid rgba(255,255,255,0.2);
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }

    .profile-image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .profile-info {
        width: 100%;
    }

    .profile-info h3 {
        margin: 0;
        font-size: 18px;
        color: white;
        margin-bottom: 8px;
    }

    .profile-info p {
        margin: 0;
        font-size: 14px;
        color: rgba(255,255,255,0.7);
    }

    /* Liste des liens */
    #sidebar-menu ul {
        list-style: none;
        padding: 0;
        margin: 0;
    }

    #sidebar-menu li {
        border-bottom: 1px solid rgba(255,255,255,0.1);
    }

    #sidebar-menu a {
        display: block;
        padding: 15px 20px;
        color: white;
        text-decoration: none;
        transition: background-color 0.3s, transform 0.3s;
    }

    #sidebar-menu a:hover,
    #sidebar-menu a.active {
        background-color: rgba(255,255,255,0.1);
        transform: translateX(10px);
    }

    /* Overlay pour fermer le menu */
    #sidebar-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0,0,0,0.5);
        z-index: 998;
        display: none;
    }

    #sidebar-overlay.active {
        display: block;
    }
</style>

<!-- Barre de navigation principale -->
<div class="main-navbar">
  <!-- Bouton hamburger texte simple -->
  <button id="hamburger-btn">☰</button>
  
  <!-- Titre du site -->
  <div class="site-title">Assurance Automobile</div>
  
  <!-- Dropdown de navigation -->
  <div class="navbar-dropdown">
    <button class="dropdown-btn">
      Menu <i class="fas fa-chevron-down"></i>
    </button>
    <div class="dropdown-menu">
      <a href="profilAgent.jsp"><i class="fas fa-user"></i> Mon Profil</a>
      <a href="#" id="add-client-btn"><i class="fas fa-user-plus"></i> Créer Compte Client</a>
      <a href="../logout.jsp"><i class="fas fa-sign-out-alt"></i> Déconnexion</a>
    </div>
  </div>
</div>

<!-- Modal Ajouter Client -->
<div id="add-client-modal" class="modal">
  <div class="modal-content">
    <span class="modal-close">&times;</span>
    <h3>Créer un Compte Client</h3>
    <form id="addClientForm" action="ajouterClient.jsp" method="post" onsubmit="return validateForm()">
      <input type="text" name="firstname" placeholder="Prénom" required>
      <input type="text" name="lastname" placeholder="Nom" required>
      <input type="text" name="username" placeholder="Nom d'utilisateur" required>
      <input type="email" name="email" placeholder="Email" required>
      <input type="password" id="password" name="password" placeholder="Mot de passe" required>
      <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirmer le mot de passe" required>
      <div id="password-error" class="error-message">Les mots de passe ne correspondent pas.</div>
      <input type="text" name="number" placeholder="Téléphone" required>
      <div class="terms-checkbox">
        <input type="checkbox" id="acceptTerms" name="acceptTerms" required>
        <label for="acceptTerms">J'accepte les conditions d'utilisation</label>
      </div>
      <button type="submit">Créer le Compte</button>
    </form>
  </div>
</div>

<!-- Menu latéral -->
<div id="sidebar-menu">
  <!-- Profil utilisateur en haut du menu -->
  <div class="sidebar-profile">
    <div class="profile-image">
      <img src="<%= profileImageUrl %>" alt="Photo de profil">
    </div>
    <div class="profile-info">
      <h3><%= userFirstname %> <%= userLastname %></h3>
      <% if(userEmail != null) { %>
      <p><%= userEmail %></p>
      <% } %>
    </div>
  </div>

  <!-- Liste des liens de navigation -->
  <ul>
    <li><a href="dashboardagent.jsp"><i class="fas fa-tachometer-alt"></i> Tableau de bord</a></li>
    <li><a href="agentdevis.jsp"><i class="fas fa-file-invoice-dollar"></i> Créer une assurance</a></li>
    <li><a href="agentaffichageassurance.jsp"><i class="fas fa-shield-alt"></i> Les Assurances</a></li>
    <li><a href="assuranceattente.jsp"><i class="fas fa-headset"></i> Autres Assurances</a></li>
    <li><a href="renouAgent.jsp"><i class="fas fa-sync-alt"></i> Renouvellement</a></li>
    <li><a href="../logout.jsp"><i class="fas fa-sign-out-alt"></i> Déconnexion</a></li>
  </ul>
</div>

<!-- Overlay pour fermer le menu en cliquant à l'extérieur -->
<div id="sidebar-overlay"></div>

<script>
  // Attendre que le document soit chargé
  document.addEventListener('DOMContentLoaded', function() {
    // Gestion du menu hamburger
    const hamburgerBtn = document.getElementById('hamburger-btn');
    const sidebarMenu = document.getElementById('sidebar-menu');
    const sidebarOverlay = document.getElementById('sidebar-overlay');
    
    function toggleMenu() {
      sidebarMenu.classList.toggle('active');
      sidebarOverlay.classList.toggle('active');
    }
    
    hamburgerBtn.addEventListener('click', toggleMenu);
    sidebarOverlay.addEventListener('click', toggleMenu);

    // Gestion du dropdown
    const dropdownBtn = document.querySelector('.dropdown-btn');
    const dropdownMenu = document.querySelector('.dropdown-menu');

    dropdownBtn.addEventListener('click', function() {
      dropdownMenu.classList.toggle('show');
    });

    // Fermer le dropdown si on clique en dehors
    window.addEventListener('click', function(event) {
      if (!event.target.matches('.dropdown-btn')) {
        dropdownMenu.classList.remove('show');
      }
    });

    // Gestion de la modal d'ajout de client
    const addClientBtn = document.getElementById('add-client-btn');
    const addClientModal = document.getElementById('add-client-modal');
    const modalCloseBtn = document.querySelector('.modal-close');

    addClientBtn.addEventListener('click', function() {
      addClientModal.style.display = 'block';
    });

    modalCloseBtn.addEventListener('click', function() {
      addClientModal.style.display = 'none';
    });

    // Fermer le modal si on clique en dehors
    window.addEventListener('click', function(event) {
      if (event.target === addClientModal) {
        addClientModal.style.display = 'none';
      }
    });
    
    // Mettre en surbrillance la page active
    const currentPage = window.location.pathname.split('/').pop();
    const menuLinks = document.querySelectorAll('#sidebar-menu a');
    
    menuLinks.forEach(function(link) {
      if (link.getAttribute('href') === currentPage) {
        link.classList.add('active');
      }
    });
    
    // Vérification en temps réel des mots de passe
    const password = document.getElementById('password');
    const confirmPassword = document.getElementById('confirmPassword');
    const passwordError = document.getElementById('password-error');
    
    function checkPasswords() {
      if (password.value !== confirmPassword.value) {
        passwordError.style.display = 'block';
        return false;
      } else {
        passwordError.style.display = 'none';
        return true;
      }
    }
    
    // Vérifier les mots de passe lorsqu'ils sont modifiés
    if (password && confirmPassword) {
      password.addEventListener('input', checkPasswords);
      confirmPassword.addEventListener('input', checkPasswords);
    }
    
    // Validation du formulaire avant envoi
    window.validateForm = function() {
      return checkPasswords();
    };
  });
</script>