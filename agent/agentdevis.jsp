<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Vérifier que l'administrateur est connecté
    Integer adminId = (Integer) session.getAttribute("idadmin");
    String adminFirstName = (String) session.getAttribute("firstname");
    String adminLastName = (String) session.getAttribute("lastname");
    String matric = (String) session.getAttribute("matricule");
    String role = (String) session.getAttribute("role");
    String fullName = adminFirstName + " " + adminLastName;
    
    // Contrôle du rôle "soleil"
    if(adminId == null || role == null || !"lune".equals(role)){
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Connexion pour récupérer les options pour voiture et catégorie
    String url = "jdbc:mariadb://localhost:3306/assurance";
    String dbUser = "root";
    String dbPass = "";
    Connection conn = null;
    Statement stmt = null;
    ResultSet rsVoiture = null;
    ResultSet rsCategorie = null;
    
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        stmt = conn.createStatement();
        rsVoiture = stmt.executeQuery("SELECT id_voiture, marque FROM voiture ORDER BY marque");
        rsCategorie = stmt.executeQuery("SELECT id_categorie, genre FROM categorie");
    } catch(Exception e){
        out.println("Erreur de connexion : " + e.getMessage());
    }
    
    // Pour le champ date, on définit la date du jour au format YYYY-MM-DD (pour l'attribut min)
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String today = sdf.format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Assurer un client</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
  <style>
    /* Variables de couleurs */
    :root {
      --primary-color: #da812f;
      --secondary-color: #4CAF50;
      --text-color: #333;
      --light-bg: #f5f5f5;
      --border-color: #ccc;
      --success-color: #45a049;
      --gray-light: #f8f9fa;
      --error-color: #dc3545;
    }
    
    * {
      box-sizing: border-box; 
      margin: 0; 
      padding: 0;
    }
    
    body {
      font-family: Arial, sans-serif;
      background: var(--light-bg);
      padding: 20px;
      color: var(--text-color);
      line-height: 1.6;
    }
    
    .user-badge {
      position: fixed;
      bottom: 10px;
      right: 10px;
      background: var(--primary-color);
      color: #fff;
      padding: 8px 12px;
      border-radius: 30px;
      font-size: 14px;
      z-index: 1000;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
      display: flex;
      align-items: center;
      transition: transform 0.3s ease;
    }
    
    .user-badge:hover {
      transform: translateY(-5px);
    }
    
    .user-badge i {
      margin-right: 8px;
      font-size: 16px;
    }
    
    h2 {
      text-align: center;
      margin-bottom: 30px;
      color: var(--primary-color);
      position: relative;
      padding-bottom: 10px;
    }
    
    h2:after {
      content: "";
      position: absolute;
      bottom: 0;
      left: 50%;
      transform: translateX(-50%);
      width: 80px;
      height: 3px;
      background-color: var(--secondary-color);
    }
    
    .form-container {
      background: #fff;
      margin: 0 auto;
      padding: 30px;
      margin-top: 60px;
      border-radius: 10px;
      max-width: 1000px;
      box-shadow: 0 0 20px rgba(0,0,0,0.1);
      position: relative;
      overflow: hidden;
    }
    
    .form-container:before {
      content: "";
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 8px;
      background: linear-gradient(to right, var(--primary-color), var(--secondary-color));
    }
    
    .form-section {
      margin-bottom: 30px;
      border: 1px solid var(--border-color);
      border-radius: 8px;
      padding: 20px;
      background-color: var(--light-bg);
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    
    .form-section:hover {
      transform: translateY(-5px);
      box-shadow: 0 8px 15px rgba(0, 0, 0, 0.1);
    }
    
    .section-title {
      display: flex;
      align-items: center;
      font-size: 18px;
      color: var(--primary-color);
      margin-bottom: 20px;
      padding-bottom: 10px;
      border-bottom: 1px solid var(--border-color);
    }
    
    .section-title i {
      margin-right: 10px;
      width: 30px;
      height: 30px;
      background-color: var(--primary-color);
      color: white;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 16px;
    }
    
    .form-row {
      display: flex;
      flex-wrap: wrap;
      margin: -10px;
    }
    
    .form-group {
      position: relative;
      flex: 1 0 250px;
      margin: 10px;
      transition: transform 0.3s ease;
    }
    
    .form-control {
      width: 100%;
      padding: 12px 15px;
      border: 1px solid var(--border-color);
      border-radius: 5px;
      font-size: 16px;
      transition: all 0.3s ease;
      background-color: white;
    }
    
    .form-control:focus {
      border-color: var(--primary-color);
      box-shadow: 0 0 5px rgba(218, 129, 47, 0.5);
      outline: none;
    }
    
    .form-label {
      position: absolute;
      top: 50%;
      left: 15px;
      transform: translateY(-50%);
      background-color: white;
      padding: 0 5px;
      color: #666;
      pointer-events: none;
      transition: all 0.3s ease;
    }
    
    .form-control:focus ~ .form-label,
    .form-control:not(:placeholder-shown) ~ .form-label {
      top: 0;
      font-size: 12px;
      color: var(--primary-color);
    }
    
    .form-select {
      width: 100%;
      padding: 12px 15px;
      border: 1px solid var(--border-color);
      border-radius: 5px;
      font-size: 16px;
      appearance: none;
      background-image: url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='%23333' viewBox='0 0 16 16'%3E%3Cpath d='M7.247 11.14L2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z'/%3E%3C/svg%3E");
      background-repeat: no-repeat;
      background-position: right 15px center;
      background-size: 12px;
      transition: border-color 0.3s, box-shadow 0.3s;
    }
    
    .form-select:focus {
      border-color: var(--primary-color);
      box-shadow: 0 0 5px rgba(218, 129, 47, 0.5);
      outline: none;
    }
    
    .user-info {
      background: var(--gray-light);
      padding: 15px;
      margin-bottom: 25px;
      border-radius: 8px;
      border-left: 4px solid var(--primary-color);
      display: flex;
      align-items: center;
    }
    
    .user-info i {
      font-size: 24px;
      color: var(--primary-color);
      margin-right: 10px;
    }
    
    .submit-btn {
      display: block;
      width: 250px;
      margin: 30px auto 0;
      padding: 15px;
      background: linear-gradient(to right, var(--primary-color), var(--secondary-color));
      color: white;
      border: none;
      border-radius: 30px;
      font-size: 18px;
      font-weight: 600;
      cursor: pointer;
      transition: transform 0.3s, box-shadow 0.3s;
      text-align: center;
    }
    
    .submit-btn:hover {
      transform: translateY(-3px);
      box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
    }
    
    .submit-btn:active {
      transform: translateY(0);
      box-shadow: 0 3px 6px rgba(0, 0, 0, 0.1);
    }
    
    .btn-add-brand {
      background-color: var(--secondary-color);
      color: white;
      border: none;
      border-radius: 50%;
      width: 30px;
      height: 30px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      margin-left: 10px;
      cursor: pointer;
      transition: background-color 0.3s, transform 0.3s;
    }
    
    .btn-add-brand:hover {
      background-color: var(--success-color);
      transform: rotate(90deg);
    }
    
    /* Modal styles */
    .modal {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0, 0, 0, 0.5);
      z-index: 1000;
      overflow: auto;
      backdrop-filter: blur(5px);
    }
    
    .modal-content {
      background-color: white;
      margin: 10% auto;
      padding: 25px;
      width: 90%;
      max-width: 500px;
      border-radius: 10px;
      box-shadow: 0 5px 25px rgba(0, 0, 0, 0.2);
      transform: translateY(-50px);
      opacity: 0;
      transition: transform 0.4s, opacity 0.4s;
      position: relative;
    }
    
    .modal.show .modal-content {
      transform: translateY(0);
      opacity: 1;
    }
    
    .modal-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 20px;
      padding-bottom: 15px;
      border-bottom: 1px solid var(--border-color);
    }
    
    .modal-title {
      font-size: 20px;
      color: var(--primary-color);
      margin: 0;
    }
    
    .close-modal {
      background: none;
      border: none;
      font-size: 24px;
      color: #999;
      cursor: pointer;
      transition: color 0.3s;
    }
    
    .close-modal:hover {
      color: #333;
    }
    
    /* Style pour récapitulatif */
    .recap-list {
      list-style: none;
      padding: 0;
      margin: 0;
    }
    
    .recap-item {
      display: flex;
      justify-content: space-between;
      padding: 10px 0;
      border-bottom: 1px solid #eee;
    }
    
    .recap-label {
      font-weight: bold;
      color: var(--primary-color);
    }
    
    .recap-value {
      color: var(--text-color);
    }
    
    .modal-actions {
      margin-top: 25px;
      display: flex;
      justify-content: flex-end;
      gap: 10px;
    }
    
    .btn-modal {
      padding: 10px 20px;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      font-weight: 600;
      transition: background-color 0.3s;
    }
    
    .btn-confirm {
      background-color: var(--success-color);
      color: white;
    }
    
    .btn-confirm:hover {
      background-color: #218838;
    }
    
    .btn-edit {
      background-color: #f7f7f7;
      color: #333;
    }
    
    .btn-edit:hover {
      background-color: #e6e6e6;
    }
    
    /* Style pour le texte d'aide */
    .help-text {
      font-size: 12px;
      color: var(--primary-color);
      margin-top: 5px;
      display: block;
    }
    
    /* Style pour les erreurs */
    .error-message {
      color: var(--error-color);
      font-size: 12px;
      margin-top: 5px;
      display: none;
    }
    
    /* Animations et effets */
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    .form-section:nth-child(1) { animation: fadeIn 0.5s ease forwards; }
    .form-section:nth-child(2) { animation: fadeIn 0.5s 0.1s ease forwards; opacity: 0; }
    .form-section:nth-child(3) { animation: fadeIn 0.5s 0.2s ease forwards; opacity: 0; }
    
    /* Adaptations responsive */
    @media (max-width: 768px) {
      .form-container {
        padding: 20px;
        margin: 20px;
      }
      
      .form-group {
        flex: 0 0 100%;
      }
      
      .submit-btn {
        width: 100%;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <%@ include file="../meag.jsp" %> <!-- Navbar admin, si existante -->
    
    
    <div class="form-container">
      <h2>Nouvelle Assurance (Agent)</h2>
      
      <!-- Affichage de l'admin connecté -->
      <div class="user-info">
        <i class="fas fa-id-badge"></i>
        <div>
          <p><strong>Agent :</strong> <%= adminFirstName %> <%= adminLastName %></p>
          <p><small><strong>Matricule :</strong> <%= matric %></small></p>
        </div>
      </div>
      
      <!-- Formulaire de création d'assurance -->
      <form id="assuranceForm" action="agenttraitementassurance.jsp" method="post">
        
        <!-- Section 1 : Informations du Client Assuré -->
        <div class="form-section">
          <div class="section-title">
            <i class="fas fa-user"></i> Informations du Client Assuré
          </div>
          <div class="form-row">
            <div class="form-group">
              <input type="text" name="insured_firstname" id="insured_firstname" class="form-control" placeholder=" " required>
              <label for="insured_firstname" class="form-label">Prénom du Client</label>
            </div>
            <div class="form-group">
              <input type="text" name="insured_lastname" id="insured_lastname" class="form-control" placeholder=" " required>
              <label for="insured_lastname" class="form-label">Nom du Client</label>
            </div>
            <div class="form-group">
              <input type="text" name="insured_number" id="insured_number" class="form-control" placeholder=" " required>
              <label for="insured_number" class="form-label">Téléphone du Client</label>
            </div>
          </div>
        </div>
        
        <!-- Section 2 : Informations du véhicule -->
        <div class="form-section">
          <div class="section-title">
            <i class="fas fa-car"></i> Informations du véhicule
            <button type="button" id="ajouterMarqueBtn" class="btn-add-brand" title="Ajouter une nouvelle marque">
              <i class="fas fa-plus"></i>
            </button>
          </div>
          <div class="form-row">
            <div class="form-group">
              <select name="id_voiture" id="id_voiture" class="form-select" required>
                <option value="" disabled selected></option>
                <%
                    while(rsVoiture.next()){
                        int idV = rsVoiture.getInt("id_voiture");
                        String marque = rsVoiture.getString("marque");
                %>
                <option value="<%= idV %>"><%= marque %></option>
                <%
                    }
                %>
              </select>
              <label for="id_voiture" class="form-label">Marque de la Voiture</label>
            </div>
            <div class="form-group">
              <select name="id_categorie" id="id_categorie" class="form-select" required>
                <option value="" disabled selected></option>
                <%
                    while(rsCategorie.next()){
                        int idC = rsCategorie.getInt("id_categorie");
                        String genre = rsCategorie.getString("genre");
                %>
                <option value="<%= idC %>"><%= genre %></option>
                <%
                    }
                %>
              </select>
              <label for="id_categorie" class="form-label">Genre de la Catégorie</label>
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <input type="text" name="immatriculation" id="immatriculation" class="form-control" placeholder=" " required>
              <label for="immatriculation" class="form-label">Immatriculation</label>
            </div>
            <div class="form-group">
              <input type="number" name="puissance" id="puissance" min="1" class="form-control" placeholder=" " required>
              <label for="puissance" class="form-label">Puissance</label>
              <span id="puissanceHelp" class="help-text"></span>
              <span id="puissanceError" class="error-message"></span>
            </div>
            <div class="form-group">
              <input type="number" name="nombre_place" id="nombre_place" min="1" class="form-control" placeholder=" " required>
              <label for="nombre_place" class="form-label">Nombre de Places</label>
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <select name="energie" id="energie" class="form-select" required>
                <option value="" disabled selected></option>
                <option value="0">Essence</option>
                <option value="1">Gazoil</option>
              </select>
              <label for="energie" class="form-label">Type d'Énergie</label>
            </div>
            <div class="form-group">
              <select name="quartier" id="quartier" class="form-select" required>
                <option value="" disabled selected></option>
                <option value="Francophonie">Francophonie</option>
                <option value="Bobiel">Bobiel</option>
                <option value="Sonuci">Sonuci</option>
                <option value="Tchangarey">Tchangarey</option>
                <option value="Ryad">Ryad</option>
                <option value="Dar As Salam">Dar As Salam</option>
                <option value="Plateau">Plateau</option>
                <option value="Recasement">Recasement</option>
                <option value="Cite Chinoise">Cite Chinoise</option>
              </select>
              <label for="quartier" class="form-label">Quartier</label>
            </div>
          </div>
        </div>
        
        <!-- Section 3 : Informations de l'assurance -->
        <div class="form-section">
          <div class="section-title">
            <i class="fas fa-shield-alt"></i> Informations de l'assurance
          </div>
          <div class="form-row">
            <div class="form-group">
              <select name="nombre_mois" id="nombre_mois" class="form-select" required>
                <option value="" disabled selected></option>
                <option value="3">3 mois</option>
                <option value="6">6 mois</option>
                <option value="12">12 mois</option>
              </select>
              <label for="nombre_mois" class="form-label">Durée de l'assurance</label>
            </div>
            <div class="form-group">
              <input type="date" name="new_start_date" id="new_start_date" class="form-control" required min="<%= today %>">
              <label for="new_start_date" class="form-label">Date de Début</label>
            </div>
            <div class="form-group">
              <select name="valider" id="valider" class="form-select" required>
                <option value="" disabled selected></option>
                <option value="0">Non payé</option>
                <option value="1">Payé</option>
              </select>
              <label for="valider" class="form-label">Validation (Paiement)</label>
            </div>
          </div>
        </div>

        <!-- Champ caché pour indiquer l'opération admin -->
        <input type="hidden" name="admin_operation" value="true">
        <input type="hidden" name="matricule" value="<%= matric %>">
        
        <button type="submit" class="submit-btn">
          <i class="fas fa-check-circle"></i> Valider le devis
        </button>
      </form>
    </div>
    
    <!-- Modal de récapitulatif -->
    <div id="recapModal" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title">Récapitulatif du devis</h3>
          <button type="button" class="close-modal" id="closeRecapModal">&times;</button>
        </div>
        <div id="recapContent">
          <ul class="recap-list"></ul>
        </div>
        <div class="modal-actions">
          <button id="editBtn" class="btn-modal btn-edit">
            <i class="fas fa-edit"></i> Modifier
          </button>
          <button id="confirmBtn" class="btn-modal btn-confirm">
            <i class="fas fa-check"></i> Confirmer
          </button>
        </div>
      </div>
    </div>
    
    <!-- Modal pour ajout de marque -->
    <div id="brandModal" class="modal">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title">Ajouter une nouvelle marque</h3>
          <button type="button" class="close-modal" id="closeBrandModal">&times;</button>
        </div>
        <form action="ajouterVoiture.jsp" method="post">
          <div class="form-group" style="margin-bottom: 20px;">
            <input type="text" name="marque" class="form-control" placeholder=" " required>
            <label class="form-label">Nom de la marque</label>
          </div>
          <button type="submit" class="submit-btn" style="margin-top: 0;">
            <i class="fas fa-plus"></i> Ajouter
          </button>
        </form>
      </div>
    </div>
  </div>
  
  <script>
    document.addEventListener("DOMContentLoaded", function() {
      // Gestion du modal de récapitulatif
      const assuranceForm = document.getElementById("assuranceForm");
      const recapModal = document.getElementById("recapModal");
      const recapList = document.querySelector(".recap-list");
      const confirmBtn = document.getElementById("confirmBtn");
      const editBtn = document.getElementById("editBtn");
      const closeRecapModal = document.getElementById("closeRecapModal");
      
      // Références aux éléments pour la validation de puissance
      const id_categorieSelect = document.getElementById('id_categorie');
      const energieSelect = document.getElementById('energie');
      const puissanceField = document.getElementById('puissance');
      const puissanceHelp = document.getElementById('puissanceHelp');
      const puissanceError = document.getElementById('puissanceError');
      
      // Fonction pour mettre à jour le texte d'aide
      function updatePuissanceHelp() {
        const categorieValue = id_categorieSelect.value;
        if (!categorieValue || !energieSelect.value) {
          puissanceHelp.textContent = '';
          return;
        }
        
        const categorieText = id_categorieSelect.options[id_categorieSelect.selectedIndex].text.toLowerCase();
        const energieValue = energieSelect.value;
        
        if (categorieText === "vp") {
          if (energieValue === "0") { // Essence
            puissanceHelp.textContent = "Puissance acceptable pour VP essence : 3 CV et plus";
          } else if (energieValue === "1") { // Gazoil
            puissanceHelp.textContent = "Puissance acceptable pour VP diesel : 2 CV et plus";
          }
        } else if (categorieText === "taxiville_4p") {
          if (energieValue === "0") { // Essence
            puissanceHelp.textContent = "Puissance acceptable : 3 à 14 CV";
          } else if (energieValue === "1") { // Gazoil
            puissanceHelp.textContent = "Puissance acceptable : 2 à 10 CV";
          }
        } else if (categorieText === "moto") {
          puissanceHelp.textContent = "Puissance acceptable : 0 à 3 CV";
        } else if (categorieText === "taxiville_19p") {
          if (energieValue === "0") { // Essence
            puissanceHelp.textContent = "Puissance acceptable : 7 à 14 CV";
          } else if (energieValue === "1") { // Gazoil
            puissanceHelp.textContent = "Puissance acceptable : 5 à 10 CV";
          }
        } else {
          puissanceHelp.textContent = '';
        }
      }
      
      // Ajouter des écouteurs d'événements pour mettre à jour le texte d'aide
      id_categorieSelect.addEventListener('change', updatePuissanceHelp);
      energieSelect.addEventListener('change', updatePuissanceHelp);
      
      // Fonction de validation de la puissance en fonction de la catégorie et du type d'énergie
      function validatePuissance() {
        const categorieSelect = document.getElementById('id_categorie');
        const puissanceInput = document.getElementById('puissance');
        const energieSelect = document.getElementById('energie');
        
        if (!categorieSelect.value || !puissanceInput.value || !energieSelect.value) {
          return true; // Si tous les champs ne sont pas remplis, on laisse passer pour maintenant
        }
        
        const categorieText = categorieSelect.options[categorieSelect.selectedIndex].text.toLowerCase();
        const puissance = parseInt(puissanceInput.value, 10);
        const energie = energieSelect.value; // 0 = Essence, 1 = Gazoil
        
        let isValid = false;
        let errorMessage = "";
        
        // Vérification selon la catégorie
        if (categorieText === "vp") {
          if (energie === "0") { // Essence
            if (puissance >= 3) {
              isValid = true;
            } else {
              errorMessage = "Pour un véhicule particulier essence, la puissance minimale est de 3 CV.";
            }
          } else if (energie === "1") { // Gazoil
            if (puissance >= 2) {
              isValid = true;
            } else {
              errorMessage = "Pour un véhicule particulier diesel, la puissance minimale est de 2 CV.";
            }
          }
        } else if (categorieText === "taxiville_4p") {
          if (energie === "0") { // Essence
            if (puissance >= 3 && puissance <= 14) {
              isValid = true;
            } else {
              errorMessage = "Pour un taxi ville 4 places essence, la puissance doit être entre 3 et 14 CV.";
            }
          } else if (energie === "1") { // Gazoil
            if (puissance >= 2 && puissance <= 10) {
              isValid = true;
            } else {
              errorMessage = "Pour un taxi ville 4 places diesel, la puissance doit être entre 2 et 10 CV.";
            }
          }
        } else if (categorieText === "moto") {
          if (puissance >= 0 && puissance <= 3) {
            isValid = true;
          } else {
            errorMessage = "Pour une moto, la puissance doit être entre 0 et 3 CV.";
          }
        } else if (categorieText === "taxiville_19p") {
          if (energie === "0") { // Essence
            if (puissance >= 7 && puissance <= 14) {
              isValid = true;
            } else {
              errorMessage = "Pour un taxi ville 19 places essence, la puissance doit être entre 7 et 14 CV.";
            }
          } else if (energie === "1") { // Gazoil
            if (puissance >= 5 && puissance <= 10) {
              isValid = true;
            } else {
              errorMessage = "Pour un taxi ville 19 places diesel, la puissance doit être entre 5 et 10 CV.";
            }
          }
        } else {
          // Pour les autres catégories, on accepte toutes les puissances
          isValid = true;
        }
        
        if (!isValid) {
          // Afficher l'erreur
          puissanceError.textContent = errorMessage;
          puissanceError.style.display = "block";
          puissanceInput.style.borderColor = "var(--error-color)";
          return false;
        } else {
          // Réinitialiser l'affichage d'erreur
          puissanceError.style.display = "none";
          puissanceInput.style.borderColor = "var(--border-color)";
          return true;
        }
      }
      
      // Ajouter un écouteur pour valider la puissance lorsque l'utilisateur change la valeur
      puissanceField.addEventListener('change', validatePuissance);
      puissanceField.addEventListener('input', function() {
        if (puissanceError.style.display === "block") {
          validatePuissance();
        }
      });
      
      // Mapping des champs pour l'affichage dans le récapitulatif
      const fieldMappings = {
        "insured_firstname": "Prénom du Client",
        "insured_lastname": "Nom du Client",
        "insured_number": "Téléphone du Client",
        "id_voiture": "Marque du véhicule",
        "id_categorie": "Catégorie",
        "immatriculation": "Immatriculation",
        "puissance": "Puissance",
        "nombre_place": "Nombre de places",
        "energie": "Type d'énergie",
        "quartier": "Quartier",
        "nombre_mois": "Durée (mois)",
        "new_start_date": "Date de début",
        "valider": "État de paiement"
      };
      
      // Format des valeurs spécifiques
      const formatValue = (field, value) => {
        if (field === "energie") {
          return value === "0" ? "Essence" : "Gazoil";
        }
        
        if (field === "valider") {
          return value === "0" ? "Non payé" : "Payé";
        }
        
        // Convertir les ID en texte
        if (field === "id_voiture") {
          const selectElement = document.getElementById("id_voiture");
          const selectedOption = selectElement.options[selectElement.selectedIndex];
          return selectedOption ? selectedOption.text : value;
        }
        
        if (field === "id_categorie") {
          const selectElement = document.getElementById("id_categorie");
          const selectedOption = selectElement.options[selectElement.selectedIndex];
          return selectedOption ? selectedOption.text : value;
        }
        
        return value;
      };
      
      // Soumission du formulaire et affichage du récapitulatif
      assuranceForm.addEventListener("submit", function(e) {
        e.preventDefault();
        
        // Valider la puissance selon la catégorie
        if (!validatePuissance()) {
          return; // Arrêter le traitement si la validation échoue
        }
        
        // Récupérer les valeurs des champs
        const formData = new FormData(assuranceForm);
        recapList.innerHTML = "";
        
        // Créer la liste de récapitulatif
        for (const [key, value] of formData.entries()) {
          if (key !== "admin_operation" && key !== "matricule" && fieldMappings[key]) {  // Ignorer les champs cachés et non mappés
            const li = document.createElement("li");
            li.className = "recap-item";
            
            const label = document.createElement("span");
            label.className = "recap-label";
            label.textContent = fieldMappings[key];
            
            const formattedValue = document.createElement("span");
            formattedValue.className = "recap-value";
            formattedValue.textContent = formatValue(key, value);
            
            li.appendChild(label);
            li.appendChild(formattedValue);
            recapList.appendChild(li);
          }
        }
        
        // Afficher le modal avec animation
        recapModal.style.display = "block";
        setTimeout(() => {
          recapModal.classList.add("show");
        }, 10);
      });
      
      // Fermer le modal quand on clique sur le X
      closeRecapModal.addEventListener("click", function() {
        recapModal.classList.remove("show");
        setTimeout(() => {
          recapModal.style.display = "none";
        }, 400);
      });
      
      // Fermer le modal quand on clique en dehors
      window.addEventListener("click", function(e) {
        if (e.target === recapModal) {
          recapModal.classList.remove("show");
          setTimeout(() => {
            recapModal.style.display = "none";
          }, 400);
        }
      });
      
      // Bouton "Modifier" du récapitulatif
      editBtn.addEventListener("click", function() {
        recapModal.classList.remove("show");
        setTimeout(() => {
          recapModal.style.display = "none";
        }, 400);
      });
      
      // Bouton "Confirmer" du récapitulatif
      confirmBtn.addEventListener("click", function() {
        assuranceForm.submit();
      });
      
      // Gestion du modal d'ajout de marque
      const ajouterMarqueBtn = document.getElementById("ajouterMarqueBtn");
      const brandModal = document.getElementById("brandModal");
      const closeBrandModal = document.getElementById("closeBrandModal");
      
      ajouterMarqueBtn.addEventListener("click", function() {
        brandModal.style.display = "block";
        setTimeout(() => {
          brandModal.classList.add("show");
        }, 10);
      });
      
      closeBrandModal.addEventListener("click", function() {
        brandModal.classList.remove("show");
        setTimeout(() => {
          brandModal.style.display = "none";
        }, 400);
      });
      
      window.addEventListener("click", function(e) {
        if (e.target === brandModal) {
          brandModal.classList.remove("show");
          setTimeout(() => {
            brandModal.style.display = "none";
          }, 400);
        }
      });
      
      // Animation des labels pour les inputs type date
      const dateInputs = document.querySelectorAll('input[type="date"]');
      dateInputs.forEach(input => {
        // Check if the input already has a value
        if (input.value) {
          const label = input.nextElementSibling;
          if (label && label.classList.contains("form-label")) {
            label.style.top = "0";
            label.style.fontSize = "12px";
            label.style.color = "var(--primary-color)";
          }
        }
        
        // Add focus event
        input.addEventListener("focus", function() {
          const label = this.nextElementSibling;
          if (label && label.classList.contains("form-label")) {
            label.style.top = "0";
            label.style.fontSize = "12px";
            label.style.color = "var(--primary-color)";
          }
        });
        
        // Add blur event
        input.addEventListener("blur", function() {
          if (!this.value) {
            const label = this.nextElementSibling;
            if (label && label.classList.contains("form-label")) {
              label.style.top = "50%";
              label.style.fontSize = "16px";
              label.style.color = "#666";
            }
          }
        });
      });
      
      // Animation pour les labels de formulaire (effet flottant)
      const formControls = document.querySelectorAll(".form-control, .form-select");
      
      formControls.forEach(control => {
        // Vérifier si le champ a déjà une valeur lors du chargement
        if (control.value !== "") {
          const label = control.nextElementSibling;
          if (label && label.classList.contains("form-label")) {
            label.style.top = "0";
            label.style.fontSize = "12px";
            label.style.color = "var(--primary-color)";
          }
        }
        
        // Ajouter des écouteurs pour la mise au focus
        control.addEventListener("focus", function() {
          const label = this.nextElementSibling;
          if (label && label.classList.contains("form-label")) {
            label.style.top = "0";
            label.style.fontSize = "12px";
            label.style.color = "var(--primary-color)";
          }
        });
        
        // Retirer l'état actif si le champ est vide lors de la perte de focus
        control.addEventListener("blur", function() {
          if (this.value === "") {
            const label = this.nextElementSibling;
            if (label && label.classList.contains("form-label")) {
              label.style.top = "50%";
              label.style.fontSize = "16px";
              label.style.color = "#666";
            }
          }
        });
      });
    });
  </script>
</body>
</html>