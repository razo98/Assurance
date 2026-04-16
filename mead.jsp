<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Récupérer les informations de l'utilisateur connecté
    String adminFirstname = (String) session.getAttribute("firstname");
    String adminLastname = (String) session.getAttribute("lastname");
    String rol = (String) session.getAttribute("role");
    
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

    /* Menu latéral */
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
  <!-- Bouton hamburger -->
  <button id="hamburger-btn">☰</button>
  
  <!-- Titre du site -->
  <div class="site-title">Assurance Automobile</div>
  
  <!-- Dropdown de navigation -->
  <div class="navbar-dropdown">
    <button class="dropdown-btn">
      Menu Admin <i class="fas fa-chevron-down"></i>
    </button>
    <div class="dropdown-menu">
      <a href="Profiladmin.jsp"><i class="fas fa-user"></i> Mon Profil</a>
      <a href="gererAgents.jsp"><i class="fas fa-users-cog"></i> Gérer les agents</a>
      <a href="gererclient.jsp"><i class="fas fa-user-friends"></i> Gérer les clients</a>
      <a href="gerervoitures.jsp"><i class="fas fa-car"></i> Gérer les Marques</a>
      <a href="gerercategories.jsp"><i class="fas fa-tags"></i> Gérer les Categories</a>
      <a href="../logout.jsp"><i class="fas fa-sign-out-alt"></i> Déconnexion</a>
    </div>
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
      <h3><%= adminFirstname %> <%= adminLastname %></h3>
      <% if(rol != null) { %>
      <p><%= rol %></p>
      <% } %>
    </div>
  </div>
  <!-- Liste des liens de navigation -->
  <ul>
    <li><a href="Tableaubord.jsp"><i class="fas fa-tachometer-alt"></i> Tableau de bord</a></li>
    <li><a href="statistiques_avancees.jsp"><i class="fas fa-chart-pie"></i> Statistiques avancées</a></li>
    <li><a href="admindevis.jsp"><i class="fas fa-file-invoice-dollar"></i> Créer une assurance</a></li>
    <li><a href="adminaffichageassurance.jsp"><i class="fas fa-shield-alt"></i> Les Assurances</a></li>
    <li><a href="assuranceattente.jsp"><i class="fas fa-clock"></i> Assurances En Attente</a></li>
    <li><a href="renouAdmin.jsp"><i class="fas fa-sync-alt"></i> Renouvellement</a></li>
    <li><a href="gererreclamation.jsp"><i class="fas fa-exclamation-circle"></i> Gérer les réclamations</a></li>
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
      if (!event.target.matches('.dropdown-btn') && !event.target.parentElement != dropdownBtn) {
        dropdownMenu.classList.remove('show');
      }
    });
    
    // Diaporama
    const images = document.querySelectorAll('.slideshow img');
    let current = 0;
    const total = images.length;
    
    function nextSlide() {
      images[current].classList.remove('active');
      current = (current + 1) % total;
      images[current].classList.add('active');
    }
    
    // Changer d'image toutes les 5 secondes
    setInterval(nextSlide, 5000);
    
    // Mettre en surbrillance la page active
    const currentPage = window.location.pathname.split('/').pop();
    const menuLinks = document.querySelectorAll('#sidebar-menu a');
    
    menuLinks.forEach(function(link) {
      if (link.getAttribute('href') === currentPage) {
        link.classList.add('active');
      }
    });
  });
</script>