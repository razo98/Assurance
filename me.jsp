<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Récupérer les informations de l'utilisateur connecté
    String userFirstname = (String) session.getAttribute("firstname");
    String userLastname = (String) session.getAttribute("lastname");
    String userEmail = (String) session.getAttribute("email"); // Ajoutez cette ligne si vous avez l'email en session
    
    // Variables pour stocker les informations du profil (optionnel, peut être récupéré de la base de données)
    String phoneNumber = ""; // Vous pouvez récupérer ce type d'information si nécessaire
    String profileImageUrl = "../images/profil.png"; // Image de profil par défaut
%>
<!-- Barre de navigation principale -->
<div class="main-navbar">
  <!-- Bouton hamburger texte simple -->
  <button id="hamburger-btn">☰</button>
  
  <!-- Titre du site -->
  <div class="site-title">Assurance Automobile</div>
  
  <!-- Dropdown pour profil et déconnexion -->
  <div class="profile-dropdown">
    <button class="dropdown-btn">
      <img src="<%= profileImageUrl %>" alt="Photo de profil" class="profile-mini">
      <span><%= userFirstname %></span>
      <i class="fas fa-chevron-down"></i>
    </button>
    <div class="dropdown-content">
      <a href="profil.jsp" class="dropdown-item">
        <i class="fas fa-user"></i> Mon profil
      </a>
      <div class="dropdown-divider"></div>
      <a href="../logout.jsp" class="dropdown-item">
        <i class="fas fa-sign-out-alt"></i> Déconnexion
      </a>
    </div>
  </div>
</div>

<!-- Menu latéral -->
<div id="sidebar-menu">
  <!-- Liste des liens de navigation avec icônes -->
  <ul>
    <li><a href="dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Tableau de bord</a></li>
    <li><a href="devis.jsp"><i class="fas fa-file-signature"></i> Souscription</a></li>
    <li><a href="affichageassurance.jsp"><i class="fas fa-shield-alt"></i> Mes assurances</a></li>
    <li><a href="renouvellementclient.jsp"><i class="fas fa-sync-alt"></i> Renouvellement</a></li>
    <li><a href="reclamation.jsp"><i class="fas fa-headset"></i> Réclamation</a></li>
  </ul>
</div>

<!-- Overlay pour fermer le menu en cliquant à l'extérieur -->
<div id="sidebar-overlay"></div>

<!-- Styles CSS directement intégrés -->
<style>
  /* Styles de la barre de navigation */
  .main-navbar {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 60px;
    background-color: #006652;
    color: white;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    z-index: 1000;
  }
  
  /* Style du bouton hamburger */
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
  
  /* Style du titre du site */
  .site-title {
    font-size: 20px;
    font-weight: bold;
  }
  
  /* Style du dropdown profil */
  .profile-dropdown {
    position: relative;
    display: inline-block;
  }
  
  .dropdown-btn {
    background: none;
    border: none;
    color: white;
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 12px;
    cursor: pointer;
    border-radius: 5px;
    transition: background-color 0.3s;
    font-size: 14px;
  }
  
  .dropdown-btn:hover {
    background-color: rgba(255,255,255,0.1);
  }
  
  .profile-mini {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid rgba(255,255,255,0.2);
  }
  
  .dropdown-content {
    display: none;
    position: absolute;
    right: 0;
    min-width: 180px;
    background-color: white;
    box-shadow: 0 5px 15px rgba(0,0,0,0.2);
    border-radius: 4px;
    z-index: 1001;
    margin-top: 5px;
    overflow: hidden;
    transform: translateY(10px);
    opacity: 0;
    transition: transform 0.2s, opacity 0.2s;
  }
  
  .dropdown-content.show {
    display: block;
    transform: translateY(0);
    opacity: 1;
  }
  
  .dropdown-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 12px 15px;
    color: #333;
    text-decoration: none;
    transition: background-color 0.2s;
    font-size: 14px;
  }
  
  .dropdown-item:hover {
    background-color: #f5f5f5;
  }
  
  .dropdown-divider {
    height: 1px;
    background-color: #e5e5e5;
    margin: 5px 0;
  }
  
  /* Menu latéral */
  #sidebar-menu {
    position: fixed;
    top: 60px; /* Juste en dessous de la navbar */
    left: -200px; /* Caché par défaut, réduit de 250px à 200px */
    width: 200px; /* Largeur réduite */
    height: calc(100% - 60px);
    background-color: #006652;
    transition: left 0.3s ease;
    z-index: 999;
    overflow-y: auto;
    padding-top: 20px; /* Ajout de padding en haut */
  }
  
  /* Lorsque le menu est actif */
  #sidebar-menu.active {
    left: 0;
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
    display: flex;
    align-items: center;
    padding: 14px 15px;
    color: white;
    text-decoration: none;
    transition: background-color 0.3s;
    font-size: 14px;
  }
  
  #sidebar-menu a i {
    margin-right: 12px;
    font-size: 16px;
    width: 20px;
    text-align: center;
  }
  
  #sidebar-menu a:hover,
  #sidebar-menu a.active {
    background-color: rgba(255,255,255,0.1);
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

<!-- JavaScript pour le menu -->
<script>
  // Attendre que le document soit chargé
  document.addEventListener('DOMContentLoaded', function() {
    // Récupérer les éléments du DOM
    var hamburgerBtn = document.getElementById('hamburger-btn');
    var sidebarMenu = document.getElementById('sidebar-menu');
    var sidebarOverlay = document.getElementById('sidebar-overlay');
    var dropdownBtn = document.querySelector('.dropdown-btn');
    var dropdownContent = document.querySelector('.dropdown-content');
    
    // Fonction pour basculer l'état du menu
    function toggleMenu() {
      sidebarMenu.classList.toggle('active');
      sidebarOverlay.classList.toggle('active');
    }
    
    // Fonction pour basculer le dropdown
    function toggleDropdown(e) {
      e.stopPropagation();
      dropdownContent.classList.toggle('show');
    }
    
    // Fermer le dropdown si on clique ailleurs
    function closeDropdown(e) {
      if (dropdownContent.classList.contains('show') && 
          !e.target.matches('.dropdown-btn') && 
          !e.target.closest('.dropdown-btn')) {
        dropdownContent.classList.remove('show');
      }
    }
    
    // Ajouter les écouteurs d'événements
    if (hamburgerBtn) {
      hamburgerBtn.addEventListener('click', toggleMenu);
    }
    
    if (sidebarOverlay) {
      sidebarOverlay.addEventListener('click', toggleMenu);
    }
    
    if (dropdownBtn) {
      dropdownBtn.addEventListener('click', toggleDropdown);
    }
    
    // Ajouter l'écouteur sur le document pour fermer le dropdown
    document.addEventListener('click', closeDropdown);
    
    // Mettre en surbrillance la page active
    var currentPage = window.location.pathname.split('/').pop();
    var menuLinks = document.querySelectorAll('#sidebar-menu a');
    
    menuLinks.forEach(function(link) {
      if (link.getAttribute('href') === currentPage) {
        link.classList.add('active');
      }
    });
  });
</script>