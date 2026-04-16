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
%>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Mes Assurances Admin</title>
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
    
    /* Animations */
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    /* Responsive Adjustments */
    @media (max-width: 768px) {
      .search-input {
        width: 100%;
      }
      
      .action-buttons {
        flex-direction: column;
      }
    }
    /* Cartes résumé */
    .stats-container {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: var(--spacing-lg);
      margin-bottom: var(--spacing-xl);
      animation: fadeIn 0.8s ease 0.2s both;
    }
    .stat-card {
      flex: 1;
      min-width: 200px;
      max-width: 300px;
      background-color: var(--white);
      border-radius: 10px;
      padding: var(--spacing-lg);
      text-align: center;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      transition: transform 0.3s ease, box-shadow 0.3s ease;
      position: relative;
      overflow: hidden;
    }
    
    .stat-card:hover {
      transform: translateY(-5px);
      box-shadow: 0 8px 15px rgba(0, 0, 0, 0.15);
    }
    
    .stat-card::before {
      content: "";
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 5px;
    }
    
    .stat-card.active::before {
      background-color: var(--success-color);
    }
    
    .stat-card.pending::before {
      background-color: var(--warning-color);
    }
    
    .stat-card.expired::before {
      background-color: var(--danger-color);
    }
    
    .stat-icon {
      width: 60px;
      height: 60px;
      margin: 0 auto var(--spacing-md);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 24px;
      border-radius: 50%;
    }
    
    .stat-card.active .stat-icon {
      background-color: rgba(40, 167, 69, 0.1);
      color: var(--success-color);
    }
    
    .stat-card.pending .stat-icon {
      background-color: rgba(255, 193, 7, 0.1);
      color: var(--warning-color);
    }
    
    .stat-card.expired .stat-icon {
      background-color: rgba(220, 53, 69, 0.1);
      color: var(--danger-color);
    }
    
    .stat-value {
      font-size: 36px;
      font-weight: 700;
      margin-bottom: var(--spacing-xs);
      transition: transform 0.3s ease;
    }
    
    .stat-card:hover .stat-value {
      transform: scale(1.1);
    }
    
    .stat-label {
      font-size: 14px;
      color: #666;
    }
    
    /* Tooltip styles */
    .tooltip-custom {
      position: relative;
      display: inline-block;
    }
    
    .tooltip-custom .tooltip-text {
      visibility: hidden;
      width: 120px;
      background-color: #333;
      color: #fff;
      text-align: center;
      border-radius: 6px;
      padding: 5px;
      position: absolute;
      z-index: 1;
      bottom: 125%;
      left: 50%;
      margin-left: -60px;
      opacity: 0;
      transition: opacity 0.3s;
    }
    
    .tooltip-custom:hover .tooltip-text {
      visibility: visible;
      opacity: 1;
    }
  </style>
</head>
<body>
  <div class="container">
    <%@ include file="../meag.jsp" %>
    <br><br>
    <div class="page-header">
      <h1 class="page-title">Mes Assurances Admin</h1>
    </div>
    
    <%
      // Variables pour les statistiques
      int activeCount = 0;
      int pendingCount = 0;
      int expiredCount = 0;
      
      Connection connStat = null;
      PreparedStatement stmtStat = null;
      ResultSet rsStat = null;
      
      try {
        Class.forName("org.mariadb.jdbc.Driver");
        connStat = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
        
        // Compte des assurances actives
        String sqlActive = "SELECT COUNT(*) FROM assurance WHERE matricule = ? AND valider = 1 and resiliation=0 and suspension=0 AND date_fin >= CURDATE()";
        stmtStat = connStat.prepareStatement(sqlActive);
        stmtStat.setString(1, matric);
        rsStat = stmtStat.executeQuery();
        if(rsStat.next()) {
          activeCount = rsStat.getInt(1);
        }
        
        // Compte des assurances en attente
        String sqlPending = "SELECT COUNT(*) FROM assurance WHERE matricule = ? AND (status = 'En attente' OR suspension =1)";
        stmtStat = connStat.prepareStatement(sqlPending);
        stmtStat.setString(1, matric);
        rsStat = stmtStat.executeQuery();
        if(rsStat.next()) {
          pendingCount = rsStat.getInt(1);
        }
        
        // Compte des assurances expirées
        String sqlExpired = "SELECT COUNT(*) FROM assurance WHERE matricule = ? AND (date_fin < CURDATE() OR resiliation = 1)";
        stmtStat = connStat.prepareStatement(sqlExpired);
        stmtStat.setString(1, matric);
        rsStat = stmtStat.executeQuery();
        if(rsStat.next()) {
          expiredCount = rsStat.getInt(1);
        }
      } catch(Exception e) {
        out.println("Erreur lors du calcul des statistiques : " + e.getMessage());
      } finally {
        if(rsStat != null) try { rsStat.close(); } catch(SQLException ignore) {}
        if(stmtStat != null) try { stmtStat.close(); } catch(SQLException ignore) {}
        if(connStat != null) try { connStat.close(); } catch(SQLException ignore) {}
      }
    %>
    
    <!-- Cartes de statistiques -->
    <div class="stats-container">
      <div class="stat-card active">
        <div class="stat-icon">
          <i class="fas fa-shield-alt"></i>
        </div>
        <div class="stat-value"><%= activeCount %></div>
        <div class="stat-label">Assurances actives</div>
      </div>
      
      <div class="stat-card pending">
        <div class="stat-icon">
          <i class="fas fa-clock"></i>
        </div>
        <div class="stat-value"><%= pendingCount %></div>
        <div class="stat-label">En attente</div>
      </div>
      
      <div class="stat-card expired">
        <div class="stat-icon">
          <i class="fas fa-calendar-times"></i>
        </div>
        <div class="stat-value"><%= expiredCount %></div>
        <div class="stat-label">Expirées</div>
      </div>
    </div>
    
    <!-- Table Container -->
    <div class="table-container">
      <div class="search-container">
        <input type="text" id="searchInput" class="search-input" placeholder="Rechercher une assurance...">
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
            <%
              Connection conn = null;
              PreparedStatement stmt = null;
              ResultSet rs = null;
              
              try {
                Class.forName("org.mariadb.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
                
                // Requête : récupération des informations depuis assurance avec jointures sur voiture et catégorie
                String sql = "SELECT a.id_assurance, a.id_voiture, v.marque, a.id_categorie, c.genre, " +
                             "a.clients, a.telephone, a.date_debut, a.date_fin, a.heure, a.immatriculation, " +
                             "a.puissance, a.nombre_place, a.energie, a.nombre_mois, a.prix_ht, a.prix_ttc, " +
                             "a.resiliation, a.suspension, a.valider, a.quartier, a.agents,a.matricule,a.status " +
                             "FROM assurance a " +
                             "JOIN voiture v ON a.id_voiture = v.id_voiture " +
                             "JOIN categorie c ON a.id_categorie = c.id_categorie "+
                             "JOIN admins u ON a.matricule = u.matricule " +
                             "WHERE a.matricule=?";
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, matric);
                rs = stmt.executeQuery();
                
                while(rs.next()){
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
                    '<%= rs.getInt("resiliation") %>',
                    '<%= rs.getInt("suspension") %>'
                  <%= (resiliation == 1 || suspension == 1 || valider == 0) ? "" : ")" %>" 
                  title="<%= (resiliation == 1) ? "Impression impossible - Assurance résiliée" : 
                           (suspension == 1) ? "Impression impossible - Assurance suspendue" : 
                           (valider == 0) ? "Impression impossible - Assurance non payée" : "Imprimer" %>">
                    <i class="fas fa-print"></i>
                  </button>

                  <button class="btn-action btn-dark" 
                          <%= canSuspend ? "" : "disabled" %>
                          title="<%= canSuspend ? "Suspendre" : resiliation == 1 ? "Impossible de suspendre une assurance résiliée" : "Déjà suspendue" %>"
                          onclick="<%= canSuspend ? "if(confirm('Êtes-vous sûr de vouloir suspendre ?')) location.href='suspassurance.jsp?id=" + rs.getInt("id_assurance") + "'" : "" %>">
                    <i class="fas fa-hand-paper"></i>
                  </button>
                  
                  <button class="btn-action btn-success" 
                          <%= canReactivate ? "" : "disabled" %>
                          title="<%= canReactivate ? "Réactiver" : resiliation == 1 ? "Impossible de réactiver une assurance résiliée" : "Déjà active" %>"
                          onclick="<%= canReactivate ? "if(confirm('Êtes-vous sûr de vouloir réactiver ?')) location.href='repassurance.jsp?id=" + rs.getInt("id_assurance") + "'" : "" %>">
                    <i class="fas fa-redo"></i>
                  </button>
                  
                  <button class="btn-action btn-danger" 
                          <%= canResiliate ? "" : "disabled" %>
                          title="<%= canResiliate ? "Résilier" : "Impossible de résilier une assurance suspendue" %>"
                          onclick="<%= canResiliate ? "if(confirm('Êtes-vous sûr de vouloir résilier ?')) location.href='resilassurance.jsp?id=" + rs.getInt("id_assurance") + "'" : "" %>">
                    <i class="fas fa-times"></i>
                  </button>
                </div>
              </td>
            </tr>
            <%
                }
              } catch(Exception e){
                 out.println("Erreur : " + e.getMessage());
              } finally {
                 if(rs != null) try { rs.close(); } catch(SQLException ignore) {}
                 if(stmt != null) try { stmt.close(); } catch(SQLException ignore) {}
                 if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
              }
            %>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- Scripts -->
  <script src="../public/js/1jquery.js"></script>
  <script src="../public/js/2bootstrap.bundle.min.js"></script>
  <script src="../public/js/3jquery.dataTables.min.js"></script>
  <script src="../public/js/4dataTables.bootstrap5.min.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      const searchInput = document.getElementById('searchInput');
      const table = document.getElementById('assuranceTable');
      const rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
      
      searchInput.addEventListener('keyup', function() {
        const searchTerm = searchInput.value.toLowerCase();
        
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
      });
      
      // Ajouter des tooltips pour les boutons désactivés
      const disabledButtons = document.querySelectorAll('.btn-action[disabled]');
      disabledButtons.forEach(button => {
        const title = button.getAttribute('title');
        if (title) {
          button.classList.add('tooltip-custom');
          const tooltipSpan = document.createElement('span');
          tooltipSpan.className = 'tooltip-text';
          tooltipSpan.textContent = title;
          button.appendChild(tooltipSpan);
        }
      });
    });

function printAssurance(id, marque, client, tel, dateDebut, dateFin, immat, puissance, energie, nbMois, prixTtc, valide, agents, resiliation = 0, suspension = 0) {
  console.log("Fonction printAssurance appelée avec ID:", id);
  
  // Vérifications habituelles
  if (valide === "Non paye" || valide === 0) {
    alert("L'impression n'est pas disponible car l'assurance n'est pas payée.");
    return;
  }
  
  if (resiliation == 1) {
    alert("L'impression n'est pas disponible car l'assurance est résiliée.");
    return;
  }
  
  if (suspension == 1) {
    alert("L'impression n'est pas disponible car l'assurance est suspendue.");
    return;
  }
  
  console.log("Vérification du PDF existant...");
  
  // Vérifier si l'impression a déjà été faite
  fetch('verifierPDF.jsp?id=' + id)
  .then(response => {
    console.log("Réponse reçue:", response);
    return response.text(); // Assurez-vous que c'est bien .text() et non .json()
  })
  .then(.then(data => {
    console.log("Données reçues:", data, typeof data); // Affiche le type pour déboguer
    
    // Convertir explicitement en chaîne au cas où
    let dataStr = String(data);
    
    // Vérifier si la chaîne contient "1" (avec ou sans espaces)
    if (dataStr.trim() === "1") {
      alert("Cette assurance a déjà été imprimée. Contactez l'administrateur pour une nouvelle impression.");
    } else {
      console.log("Génération d'un nouveau PDF...");
      // Générer et télécharger le PDF
      genererPDF();
      // Marquer comme imprimé dans la base de données
      fetch('marquerImprime.jsp?id=' + id)
        .then(response => response.text())
        .then(result => console.log("Marquage imprimé résultat:", result))
        .catch(error => console.error("Erreur de marquage:", error));
    }
  })
  .catch(error => {
    console.error("Erreur lors de la vérification:", error);
    alert("Erreur lors de la vérification du PDF: " + error);
    // En cas d'erreur, générer quand même le PDF
    genererPDF();
  });
  
  function genererPDF() {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF()
    
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

      doc.save("assurance_" + id + ".pdf");
    };
    
    img.onerror = function() {
      alert("Erreur lors du chargement de l'image d'entête.");
    };
  }
}
  </script>
</body>
</html>