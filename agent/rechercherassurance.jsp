<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
   Integer idadmin = (Integer) session.getAttribute("idadmin");
   String firstname = (String) session.getAttribute("firstname");
   String lastname = (String) session.getAttribute("lastname");
   String fullName = (String) session.getAttribute("fullname");
   String roler = (String) session.getAttribute("role");
   String matric = (String) session.getAttribute("matricule");
   if(idadmin == null || roler == null || !"lune".equals(roler)) {
      response.sendRedirect("../login.jsp");
      return;
   }
   
   // Récupérer le paramètre de recherche
   String search = request.getParameter("search");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Recherche d'Assurance</title>
  
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
  <!-- jsPDF -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.23/jspdf.plugin.autotable.min.js"></script>
  
  <style>
    /* Root Variables for Consistent Theming */
    :root {
      /* Palette de couleurs */
      --primary-color: #006652;
      --secondary-color: #FF8C00;
      --text-color: #333;
      --light-bg: #f5f5f5;
      --white: #ffffff;
      --border-color: #ddd;
      
      /* Couleurs pour les états */
      --success-color: #28a745;
      --warning-color: #ffc107;
      --danger-color: #dc3545;
      --info-color: #17a2b8;
      
      /* Espacements */
      --spacing-xs: 5px;
      --spacing-sm: 10px;
      --spacing-md: 15px;
      --spacing-lg: 20px;
      --spacing-xl: 30px;
    }
    
    /* Global Reset and Base Styles */
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    body {
      font-family: 'Arial', sans-serif;
      background-color: var(--light-bg);
      color: var(--text-color);
      line-height: 1.6;
    }
    
    .container {
      width: 100%;
      max-width: 1200px;
      margin: 0 auto;
      padding: 0 var(--spacing-md);
    }
    
    /* Page Header */
    .page-header {
      text-align: center;
      margin: var(--spacing-xl) 0;
      animation: fadeIn 0.8s ease;
    }
    
    .page-title {
      color: var(--primary-color);
      font-size: 28px;
      font-weight: 700;
      position: relative;
      display: inline-block;
      padding-bottom: var(--spacing-sm);
    }
    
    .page-title::after {
      content: "";
      position: absolute;
      bottom: 0;
      left: 50%;
      transform: translateX(-50%);
      width: 80px;
      height: 3px;
      background-color: var(--secondary-color);
    }
    
    /* User Badge */
    .user-badge {
      position: fixed;
      bottom: 20px;
      right: 20px;
      background-color: var(--primary-color);
      color: var(--white);
      padding: 10px 15px;
      border-radius: 30px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
      display: flex;
      align-items: center;
      z-index: 900;
      transition: transform 0.3s;
    }
    
    .user-badge:hover {
      transform: translateY(-5px);
    }
    
    .user-badge i {
      margin-right: 8px;
      font-size: 16px;
    }
    
    /* Search Form */
    .search-form-container {
      background-color: var(--white);
      border-radius: 10px;
      padding: var(--spacing-lg);
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      margin-bottom: var(--spacing-xl);
      animation: fadeIn 0.8s ease 0.2s both;
    }
    
    .search-form {
      display: flex;
      flex-direction: column;
      gap: var(--spacing-md);
    }
    
    .search-title {
      color: var(--primary-color);
      font-size: 20px;
      font-weight: 600;
      margin-bottom: var(--spacing-md);
      text-align: center;
    }
    
    .search-description {
      text-align: center;
      color: #666;
      margin-bottom: var(--spacing-md);
    }
    
    .search-input-container {
      display: flex;
      gap: var(--spacing-md);
    }
    
    .search-input-container input {
      flex: 1;
      padding: 12px 15px;
      border: 1px solid var(--border-color);
      border-radius: 5px;
      font-size: 16px;
      transition: border-color 0.3s, box-shadow 0.3s;
    }
    
    .search-input-container input:focus {
      border-color: var(--primary-color);
      box-shadow: 0 0 0 3px rgba(0, 102, 82, 0.2);
      outline: none;
    }
    
    .search-input-container button {
      background-color: var(--primary-color);
      color: var(--white);
      border: none;
      border-radius: 5px;
      padding: 0 25px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: background-color 0.3s;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    .search-input-container button:hover {
      background-color: #004d40;
    }
    
    /* Table Container */
    .table-container {
      background-color: var(--white);
      border-radius: 10px;
      padding: var(--spacing-lg);
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      margin-bottom: var(--spacing-xl);
      animation: fadeIn 0.8s ease 0.4s both;
      overflow: hidden;
    }
    
    /* Search Container */
    .search-container {
      display: flex;
      justify-content: flex-end;
      margin-bottom: var(--spacing-md);
    }
    
    .search-input {
      padding: 8px 15px;
      border: 1px solid var(--border-color);
      border-radius: 20px;
      width: 300px;
      font-size: 14px;
      transition: border-color 0.3s, box-shadow 0.3s;
    }
    
    .search-input:focus {
      border-color: var(--primary-color);
      box-shadow: 0 0 0 3px rgba(0, 102, 82, 0.2);
      outline: none;
    }
    
    /* Table Styles */
    .table-responsive {
      overflow-x: auto;
    }
    
    .assurance-table {
      width: 100%;
      border-collapse: separate;
      border-spacing: 0;
      border: 1px solid var(--primary-color);
      border-radius: 8px;
    }
    
    .assurance-table th {
      background-color: var(--primary-color);
      color: var(--white);
      padding: 12px 15px;
      text-align: left;
      font-weight: 600;
      position: relative;
      border: 1px solid rgba(255, 255, 255, 0.2);
    }
    
    .assurance-table th:first-child {
      border-top-left-radius: 8px;
    }
    
    .assurance-table th:last-child {
      border-top-right-radius: 8px;
    }
    
    .assurance-table th .sort-icon {
      margin-left: 5px;
      font-size: 12px;
    }
    
    .assurance-table tbody tr {
      border-bottom: 1px solid var(--border-color);
      transition: background-color 0.3s;
    }
    
    .assurance-table tbody tr:hover {
      background-color: rgba(0, 102, 82, 0.05);
    }
    
    .assurance-table td {
      padding: 12px 15px;
      vertical-align: middle;
      border: 1px solid var(--border-color);
    }
    
    .assurance-table tbody tr:last-child td:first-child {
      border-bottom-left-radius: 8px;
    }
    
    .assurance-table tbody tr:last-child td:last-child {
      border-bottom-right-radius: 8px;
    }
    
    /* Status Badges */
    .status-badge {
      display: inline-block;
      padding: 5px 10px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
      text-align: center;
      min-width: 80px;
    }
    
    .status-active {
      background-color: rgba(40, 167, 69, 0.1);
      color: var(--success-color);
    }
    
    .status-pending {
      background-color: rgba(255, 193, 7, 0.1);
      color: var(--warning-color);
    }
    
    .status-expired {
      background-color: rgba(220, 53, 69, 0.1);
      color: var(--danger-color);
    }
    
    /* Action Buttons */
    .action-buttons {
      display: flex;
      gap: 5px;
      justify-content: center;
    }
    
    .btn-action {
      width: 36px;
      height: 36px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      border: none;
      cursor: pointer;
      transition: background-color 0.3s, transform 0.3s;
      font-size: 14px;
    }
    
    .btn-action.btn-print {
      background-color: var(--primary-color);
      color: var(--white);
    }
    
    .btn-action.btn-print:hover {
      background-color: #00574b;
      transform: scale(1.1);
    }
    
    .btn-action.btn-danger {
      background-color: var(--danger-color);
      color: var(--white);
    }
    
    .btn-action.btn-danger:hover {
      background-color: #a71d2a;
      transform: scale(1.1);
    }
    
    .btn-action.btn-success {
      background-color: var(--success-color);
      color: var(--white);
    }
    
    .btn-action.btn-success:hover {
      background-color: #218838;
      transform: scale(1.1);
    }
    
    .btn-action.btn-dark {
      background-color: #343a40;
      color: var(--white);
    }
    
    .btn-action.btn-dark:hover {
      background-color: #23272b;
      transform: scale(1.1);
    }
    
    /* Boutons désactivés */
    .btn-action:disabled,
    .btn-action.disabled {
      background-color: #6c757d;
      cursor: not-allowed;
      opacity: 0.5;
    }
    
    .btn-action:disabled:hover,
    .btn-action.disabled:hover {
      transform: none;
    }
    
    /* Tooltip */
    .tooltip-container {
      position: relative;
      display: inline-block;
    }
    
    .tooltip-text {
      visibility: hidden;
      width: 150px;
      background-color: #333;
      color: #fff;
      text-align: center;
      border-radius: 6px;
      padding: 5px;
      position: absolute;
      z-index: 1;
      bottom: 125%;
      left: 50%;
      margin-left: -75px;
      opacity: 0;
      transition: opacity 0.3s;
      font-size: 12px;
      pointer-events: none;
    }
    
    .tooltip-container:hover .tooltip-text {
      visibility: visible;
      opacity: 1;
    }
    
    /* Empty State */
    .empty-state {
      text-align: center;
      padding: var(--spacing-xl);
      color: #666;
    }
    
    .empty-state i {
      font-size: 48px;
      margin-bottom: var(--spacing-md);
      color: #ccc;
    }
    
    /* Result Message */
    .result-message {
      padding: var(--spacing-md);
      margin-bottom: var(--spacing-md);
      border-radius: 5px;
      text-align: center;
      font-weight: 500;
    }
    
    .result-message.success {
      background-color: rgba(40, 167, 69, 0.1);
      color: var(--success-color);
    }
    
    .result-message.error {
      background-color: rgba(220, 53, 69, 0.1);
      color: var(--danger-color);
    }
    
    /* Animations */
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    /* Responsive Adjustments */
    @media (max-width: 768px) {
      .search-input-container {
        flex-direction: column;
      }
      
      .search-input {
        width: 100%;
      }
      
      .action-buttons {
        flex-direction: column;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <%@ include file="../meag.jsp" %>
    <br><br>
    <div class="page-header">
      <h1 class="page-title">Recherche d'Assurance</h1>
    </div>
    
    <!-- Formulaire de recherche -->
    <div class="search-form-container">
      <h2 class="search-title">Rechercher une assurance</h2>
      <p class="search-description">Entrez l'identifiant de l'assurance ou l'immatriculation du véhicule</p>
      
      <form action="rechercherassurance.jsp" method="get" class="search-form">
        <div class="search-input-container">
          <input type="text" name="search" id="search" placeholder="ID Assurance ou Immatriculation (ex: 123 ou BP-5051)" 
                 value="<%= search != null ? search : "" %>" required>
          <button type="submit">
            <i class="fas fa-search"></i> Rechercher
          </button>
        </div>
      </form>
    </div>
    
    <% if(search != null && !search.trim().isEmpty()) { %>
    <!-- Conteneur pour les résultats -->
    <div class="table-container">
      <% 
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        boolean hasResults = false;
        
        try {
          Class.forName("org.mariadb.jdbc.Driver");
          conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
          
          // Requête : récupération par ID assurance ou immatriculation
          String sql = "SELECT a.id_assurance, a.id_voiture, v.marque, a.id_categorie, c.genre, " +
                       "a.clients, a.telephone, a.date_debut, a.date_fin, a.heure, a.immatriculation, " +
                       "a.puissance, a.nombre_place, a.energie, a.nombre_mois, a.prix_ht, a.prix_ttc, " +
                       "a.resiliation, a.suspension, a.valider, a.quartier, a.agents, a.matricule, a.status " +
                       "FROM assurance a " +
                       "JOIN voiture v ON a.id_voiture = v.id_voiture " +
                       "JOIN categorie c ON a.id_categorie = c.id_categorie " +
                       "WHERE a.id_assurance = ? OR a.immatriculation = ?";
          stmt = conn.prepareStatement(sql);
          
          // Déterminer si la recherche est un ID
          int searchId = 0;
          try {
            searchId = Integer.parseInt(search);
          } catch (NumberFormatException e) {
            // Ce n'est pas un ID numérique, c'est probablement une immatriculation
          }
          
          stmt.setInt(1, searchId);
          stmt.setString(2, search);
          rs = stmt.executeQuery();
          
          if(rs.next()) {
            hasResults = true;
      %>
      
      <div class="result-message success">
        <i class="fas fa-check-circle"></i> Assurance trouvée
      </div>
      
      <div class="table-responsive">
        <table class="assurance-table" id="assuranceTable">
          <thead>
            <tr>
              <th>Marque</th>
              <th>Client</th>
              <th>Date Début</th>
              <th>Date Fin</th>
              <th>Immat</th>
              <th>Puissance</th>
              <th>Energie</th>
              <th>Nb Mois</th>
              <th>Prix TTC</th>
              <th>Statut</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
          <% do { 
              // Récupérer les états
              int resiliation = rs.getInt("resiliation");
              int suspension = rs.getInt("suspension");
              String status = rs.getString("status");
              int valider = rs.getInt("valider");
              
              // Déterminer le statut d'affichage
              java.util.Date today = new java.util.Date();
              java.util.Date dateFin = rs.getDate("date_fin");
              String statusClass;
              String statusText;
              
              if (resiliation == 1) {
                statusClass = "status-expired";
                statusText = "Résiliée";
              } else if (suspension == 1) {
                statusClass = "status-pending";
                statusText = "Suspendue";
              } else if (dateFin.before(today)) {
                statusClass = "status-expired";
                statusText = "Expirée";
              } else if (status != null && status.equals("En attente") || valider == 0) {
                statusClass = "status-pending";
                statusText = "En attente";
              } else {
                statusClass = "status-active";
                statusText = "Active";
              }
              
              // Déterminer quels boutons doivent être désactivés selon les règles métier
              boolean canSuspend = resiliation == 0 && suspension == 0 && valider == 1;
              boolean canReactivate = suspension == 1;
              boolean canResiliate = suspension == 0 && valider == 1 && resiliation == 0;
          %>
            <tr>
              <td><%= rs.getString("marque") %></td>
              <td><%= rs.getString("clients") %></td>
              <td><%= rs.getDate("date_debut") %></td>
              <td><%= rs.getDate("date_fin") %> 23:59</td>
              <td><%= rs.getString("immatriculation") %></td>
              <td><%= rs.getInt("puissance") %></td>
              <td><%= (rs.getInt("energie") == 0) ? "Essence" : "Gazoil" %></td>
              <td><%= rs.getInt("nombre_mois") %></td>
              <td><%= String.format("%.2f", rs.getDouble("prix_ttc")) %></td>
              <td><span class="status-badge <%= statusClass %>"><%= statusText %></span></td>
              <td>
                <div class="action-buttons">
                  <div class="tooltip-container">
                    <button class="btn-action btn-print" 
                            <%= (resiliation == 1 || suspension == 1 || valider == 0) ? "disabled" : "" %>
                            onclick="<%= (resiliation == 1 || suspension == 1 || valider == 0) ? "" : "printAssurance(" %>
                            '<%= rs.getInt("id_assurance") %>',
                            '<%= rs.getString("marque") %>',
                            '<%= rs.getString("clients") %>',
                            '<%= rs.getString("telephone") %>',
                            '<%= rs.getDate("date_debut") %>',
                            '<%= rs.getDate("date_fin") %> 23:59',
                            '<%= rs.getString("immatriculation") %>',
                            '<%= rs.getInt("puissance") %>',
                            '<%= (rs.getInt("energie")==0) ? "Essence" : "Gazoil" %>',
                            '<%= rs.getInt("nombre_mois") %>',
                            '<%= rs.getDouble("prix_ttc") %>',
                            '<%= (rs.getInt("valider")==1) ? "Paye" : "Non paye" %>',
                            '<%= rs.getString("agents") %>',
                            <%= rs.getInt("resiliation") %>,
                            <%= rs.getInt("suspension") %>
                            <%= (resiliation == 1 || suspension == 1 || valider == 0) ? "" : ")" %>" 
                            title="Imprimer">
                      <i class="fas fa-print"></i>
                    </button>
                    <% if (resiliation == 1 || suspension == 1 || valider == 0) { %>
                      <span class="tooltip-text">
                        <%= (resiliation == 1) ? "Impression impossible - Assurance résiliée" : 
                          (suspension == 1) ? "Impression impossible - Assurance suspendue" : 
                          "Impression impossible - Assurance non payée" %>
                      </span>
                    <% } %>
                  </div>

                  <div class="tooltip-container">
                    <button class="btn-action btn-dark" 
                            <%= canSuspend ? "" : "disabled" %>
                            <%= canSuspend ? "onclick=\"if(confirm('Êtes-vous sûr de vouloir suspendre ?')) location.href='suspassurance.jsp?id=" + rs.getInt("id_assurance") + "'\"" : "" %>
                            title="Suspendre">
                      <i class="fas fa-hand-paper"></i>
                    </button>
                    <% if (!canSuspend) { %>
                      <span class="tooltip-text">
                        <%= resiliation == 1 ? "Impossible de suspendre une assurance résiliée" : "Déjà suspendue" %>
                      </span>
                    <% } %>
                  </div>
                  
                  <div class="tooltip-container">
                    <button class="btn-action btn-success" 
                            <%= canReactivate ? "" : "disabled" %>
                            <%= canReactivate ? "onclick=\"if(confirm('Êtes-vous sûr de vouloir réactiver ?')) location.href='repassurance.jsp?id=" + rs.getInt("id_assurance") + "'\"" : "" %>
                            title="Réactiver">
                      <i class="fas fa-redo"></i>
                    </button>
                    <% if (!canReactivate) { %>
                      <span class="tooltip-text">
                        <%= resiliation == 1 ? "Impossible de réactiver une assurance résiliée" : "L'assurance n'est pas suspendue" %>
                      </span>
                    <% } %>
                  </div>
                  
                  <div class="tooltip-container">
                    <button class="btn-action btn-dark" 
                            <%= canResiliate ? "" : "disabled" %>
                            <%= canResiliate ? "onclick=\"if(confirm('Êtes-vous sûr de vouloir résilier ?')) location.href='resilassurance.jsp?id=" + rs.getInt("id_assurance") + "'\"" : "" %>
                            title="Résilier">
                      <i class="fas fa-times"></i>
                    </button>
                    <% if (!canResiliate) { %>
                      <span class="tooltip-text">
                        Impossible de résilier une assurance suspendue
                      </span>
                    <% } %>
                  </div>
                </div>
              </td>
            </tr>
          <% } while(rs.next()); %>
          </tbody>
        </table>
      </div>
      
      <% } else { %>
      <div class="result-message error">
        <i class="fas fa-exclamation-triangle"></i> Aucune assurance trouvée pour "<%= search %>"
      </div>
      
      <div class="empty-state">
        <i class="fas fa-search"></i>
        <p>Veuillez vérifier l'identifiant ou l'immatriculation et réessayer.</p>
      </div>
      <% } %>
      
      <% 
        } catch(Exception e) {
          out.println("<div class='result-message error'>");
          out.println("<i class='fas fa-exclamation-triangle'></i> Erreur : " + e.getMessage());
          out.println("</div>");
        } finally {
          if(rs != null) try { rs.close(); } catch(SQLException ignore) {}
          if(stmt != null) try { stmt.close(); } catch(SQLException ignore) {}
          if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
        }
      %>
    </div>
    <% } else { %>
    <!-- Message initial quand aucune recherche n'a encore été faite -->
    <div class="empty-state">
      <i class="fas fa-search"></i>
      <p>Utilisez le formulaire de recherche ci-dessus pour trouver une assurance.</p>
    </div>
    <% } %>
    
  </div>

  <!-- Scripts -->
  <script src="../public/js/1jquery.js"></script>
  <script src="../public/js/2bootstrap.bundle.min.js"></script>
  <script>
    // Fonction Print avec jsPDF : imprime tous les champs
    function printAssurance(id, marque, client, tel, dateDebut, dateFin, immat, puissance, energie, nbMois, prixTtc, valide, agents, resiliation = 0, suspension = 0) {
      // Vérifier si l'assurance est payée
      if (valide === "Non paye" || valide === 0) {
        alert("L'impression n'est pas disponible car l'assurance n'est pas payée.");
        return;
      }
      
      // Vérifier si l'assurance est résiliée ou suspendue
      if (resiliation == 1) {
        alert("L'impression n'est pas disponible car l'assurance est résiliée.");
        return;
      }
      
      if (suspension == 1) {
        alert("L'impression n'est pas disponible car l'assurance est suspendue.");
        return;
      }
      
      const { jsPDF } = window.jspdf;
      const doc = new jsPDF();

      // Charger l'image d'entête
      let img = new Image();
      img.src = "../images/entete.JPG";
      img.crossOrigin = "Anonymous";
      img.onload = function() {
        let canvas = document.createElement("canvas");
        canvas.width = img.width;
        canvas.height = img.height;
        let ctx = canvas.getContext("2d");
        ctx.drawImage(img, 0, 0);
        let imgData = canvas.toDataURL("image/png");

        // Ajouter l'image en entête
        doc.addImage(imgData, 'PNG', 10, 10, 190, 30);
        let startY = 45; // Position de départ pour le titre et le tableau

        // Ajouter un titre sous l'image
        doc.setFontSize(16);
        doc.text("Détails de l'Assurance", 14, startY);

        // Préparer les données pour le tableau
        const tableColumns = ["Champ", "Valeur"];
        const tableData = [
          ["ID Assurance", id],
          ["Marque", marque],
          ["Client", client],
          ["Téléphone", tel],
          ["Date Début", dateDebut],
          ["Date Fin", dateFin],
          ["Immatriculation", immat],
          ["Puissance", puissance],
          ["Énergie", energie],
          ["Nombre de Mois", nbMois],
          ["Prix TTC", prixTtc],
          ["Validé", valide]
        ];

        // Générer le tableau dans le PDF
        doc.autoTable({
          startY: startY + 10,
          head: [tableColumns],
          body: tableData,
          theme: 'grid',
          headStyles: { fillColor: [46, 125, 50] },
          styles: { fontSize: 10 }
        });

        // Récupérer la position finale du tableau
        const finalY = doc.lastAutoTable.finalY;

        // Ajouter le message NB juste après le tableau
        doc.setFontSize(10);
        const nbMessage = "NB: Ce présent attestation est valide pour 7 jours, veuillez vous rendre dans une de nos agences pour obtenir l'attestation originale avant son expiration. Merci";
        // On limite la largeur du texte pour qu'il s'affiche sur plusieurs lignes si besoin
        doc.text(nbMessage, 14, finalY + 10, { maxWidth: 185 });
        
        // Ajout de la date et heure d'impression en bas à gauche
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        const currentDate = new Date();
        const formattedDate = currentDate.toLocaleDateString();
        const formattedTime = currentDate.toLocaleTimeString();
        doc.text('Niamey le: '+formattedDate+' a '+formattedTime, 10, pageHeight - 10);

        // Ajout de l'information "Agent" en bas à droite, avec soulignement
        const agentLabel = "Agent :";
        const agentLabelWidth = doc.getTextWidth(agentLabel);
        const agentX = pageWidth - 30; // marge de 10 mm du bord droit
        const agentY = pageHeight - 40; // position verticale
        doc.setFontSize(12);
        doc.text(agentLabel, agentX - agentLabelWidth, agentY);
        // Dessiner la ligne soulignée sous "Agent :"
        doc.setLineWidth(0.5);
        doc.line(agentX - agentLabelWidth, agentY + 2, agentX, agentY + 2);
        // Afficher le nom de l'agent en dessous, aligné à droite
        const agentName = agents;
        const agentNameWidth = doc.getTextWidth(agentName);
        doc.text(agentName, pageWidth - agentNameWidth - 10, agentY + 10);

        // Sauvegarder le PDF
        doc.save("assurance_" + id + ".pdf");
      };

      img.onerror = function() {
        alert("Erreur lors du chargement de l'image d'entête.");
      };
    }
    
    // Filtrer le tableau si nécessaire
    document.addEventListener('DOMContentLoaded', function() {
      const searchInput = document.getElementById('searchTableInput');
      if (searchInput) {
        searchInput.addEventListener('keyup', function() {
          const searchTerm = searchInput.value.toLowerCase();
          const table = document.getElementById('assuranceTable');
          if (table) {
            const rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
            
            for (let i = 0; i < rows.length; i++) {
              let found = false;
              const cells = rows[i].getElementsByTagName('td');
              
              for (let j = 0; j < cells.length; j++) {
                if (cells[j].textContent.toLowerCase().indexOf(searchTerm) > -1) {
                  found = true;
                  break;
                }
              }
              
              rows[i].style.display = found ? '' : 'none';
            }
          }
        });
      }
    });
  </script>
</body>
</html>