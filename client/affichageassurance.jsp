<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
   Integer iduser = (Integer) session.getAttribute("iduser");
   String firstname = (String) session.getAttribute("firstname");
   String lastname = (String) session.getAttribute("lastname");
   String fullName = (String) session.getAttribute("fullname");
   if(iduser == null) {
      response.sendRedirect("../login.jsp");
      return;
   }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
  <!-- jsPDF -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.23/jspdf.plugin.autotable.min.js"></script>
  
  <title>Mes Assurances</title>
  <style>
    /* Styles de base */
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
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
    
    /* Header et titre */
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
    
    /* Tableau d'assurances */
    .table-container {
      background-color: var(--white);
      border-radius: 10px;
      padding: var(--spacing-lg);
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      margin-bottom: var(--spacing-xl);
      animation: fadeIn 0.8s ease 0.4s both;
      overflow: hidden;
    }
    
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
    
    .table-responsive {
      overflow-x: auto;
    }
    
    .assurance-table {
      width: 100%;
      border-collapse: collapse;
      border-spacing: 0;
    }
    
    .assurance-table th {
      background-color: var(--primary-color);
      color: var(--white);
      padding: 12px 15px;
      text-align: left;
      font-weight: 600;
      position: relative;
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
      border-bottom: 1px solid #f0f0f0;
      transition: background-color 0.3s;
    }
    
    .assurance-table tbody tr:hover {
      background-color: rgba(0, 102, 82, 0.05);
    }
    
    .assurance-table td {
      padding: 12px 15px;
      vertical-align: middle;
    }
    
    /* Badges de status */
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
    
    /* Boutons d'action */
    .action-buttons {
      display: flex;
      gap: 5px;
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
    
    .btn-print {
      background-color: var(--primary-color);
      color: var(--white);
    }
    
    .btn-print:hover {
      background-color: #00574b;
      transform: scale(1.1);
    }
    
    .btn-view {
      background-color: var(--info-color);
      color: var(--white);
    }
    
    .btn-view:hover {
      background-color: #138496;
      transform: scale(1.1);
    }
    
    /* Pagination */
    .pagination {
      display: flex;
      justify-content: center;
      margin-top: var(--spacing-lg);
    }
    
    .page-item {
      margin: 0 3px;
    }
    
    .page-link {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 36px;
      height: 36px;
      border-radius: 50%;
      background-color: var(--white);
      color: var(--text-color);
      text-decoration: none;
      transition: background-color 0.3s;
    }
    
    .page-link:hover, .page-link.active {
      background-color: var(--primary-color);
      color: var(--white);
    }
    
    /* Modal */
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
      background-color: var(--white);
      margin: 10% auto;
      width: 90%;
      max-width: 600px;
      border-radius: 10px;
      box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
      transform: translateY(-50px);
      opacity: 0;
      transition: transform 0.4s ease, opacity 0.4s ease;
      overflow: hidden;
    }
    
    .modal.show .modal-content {
      transform: translateY(0);
      opacity: 1;
    }
    
    .modal-header {
      position: relative;
      padding: 15px 20px;
      color: var(--white);
    }
    
    .modal-header.success {
      background-color: var(--success-color);
    }
    
    .modal-header.warning {
      background-color: var(--warning-color);
    }
    
    .modal-header.danger {
      background-color: var(--danger-color);
    }
    
    .modal-title {
      margin: 0;
      font-size: 18px;
      font-weight: 600;
    }
    
    .modal-close {
      position: absolute;
      top: 15px;
      right: 20px;
      background: none;
      border: none;
      color: var(--white);
      font-size: 20px;
      cursor: pointer;
      opacity: 0.8;
      transition: opacity 0.3s;
    }
    
    .modal-close:hover {
      opacity: 1;
    }
    
    .modal-body {
      padding: 20px;
    }
    
    .modal-footer {
      padding: 15px 20px;
      background-color: #f8f9fa;
      text-align: right;
    }
    
    /* État vide et chargement */
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
    
    .loading {
      display: flex;
      align-items: center;
      justify-content: center;
      padding: var(--spacing-xl);
    }
    
    .spinner {
      width: 40px;
      height: 40px;
      border: 4px solid rgba(0, 102, 82, 0.2);
      border-top-color: var(--primary-color);
      border-radius: 50%;
      animation: spin 1s infinite linear;
    }
    
    @keyframes spin {
      to { transform: rotate(360deg); }
    }
    
    /* Badge utilisateur */
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
    
    /* Animations */
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    /* Adaptations responsives */
    @media (max-width: 768px) {
      .stats-container {
        flex-direction: column;
        align-items: center;
      }
      
      .stat-card {
        width: 100%;
        max-width: none;
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
    <%@ include file="../me.jsp" %>
    <br><br>
    <div class="page-header">
      <h1 class="page-title">Mes Assurances</h1>
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
        String sqlActive = "SELECT COUNT(*) FROM assurance WHERE iduser = ? AND valider = 1 AND resiliation = 0 AND suspension = 0 AND date_fin >= CURDATE()";
        stmtStat = connStat.prepareStatement(sqlActive);
        stmtStat.setInt(1, iduser);
        rsStat = stmtStat.executeQuery();
        if(rsStat.next()) {
          activeCount = rsStat.getInt(1);
        }
        
        // Compte des assurances en attente
        String sqlPending = "SELECT COUNT(*) FROM assurance WHERE iduser = ? AND (status = 'En attente' OR valider = 0 OR suspension =1)";
        stmtStat = connStat.prepareStatement(sqlPending);
        stmtStat.setInt(1, iduser);
        rsStat = stmtStat.executeQuery();
        if(rsStat.next()) {
          pendingCount = rsStat.getInt(1);
        }
        
        // Compte des assurances expirées
        String sqlExpired = "SELECT COUNT(*) FROM assurance WHERE iduser = ? AND (date_fin < CURDATE() OR resiliation = 1)";
        stmtStat = connStat.prepareStatement(sqlExpired);
        stmtStat.setInt(1, iduser);
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
    
    <!-- Tableau des assurances -->
    <div class="table-container">
      <div class="search-container">
        <input type="text" id="searchInput" class="search-input" placeholder="Rechercher une assurance...">
      </div>
      
      <div class="table-responsive">
        <table class="assurance-table" id="assuranceTable">
          <thead>
            <tr>
              <th>Marque <span class="sort-icon"><i class="fas fa-sort"></i></span></th>
              <th>Date début <span class="sort-icon"><i class="fas fa-sort"></i></span></th>
              <th>Date fin <span class="sort-icon"><i class="fas fa-sort"></i></span></th>
              <th>Immatriculation</th>
              <th>Prix TTC <span class="sort-icon"><i class="fas fa-sort"></i></span></th>
              <th>Statut</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <%
              Connection conn = null;
              PreparedStatement stmt = null;
              ResultSet rs = null;
              boolean hasAssurances = false;
              
              try {
                Class.forName("org.mariadb.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
                
                String sql = "SELECT a.id_assurance, a.id_voiture, v.marque, a.id_categorie, c.genre, a.iduser, " +
                             "u.firstname, u.lastname, u.number, a.date_debut, a.date_fin, a.immatriculation, " +
                             "a.puissance, a.nombre_place, a.energie, a.nombre_mois, a.prix_ttc, " +
                             "a.valider, a.resiliation, a.suspension, a.agents, a.status " +
                             "FROM assurance a " +
                             "JOIN voiture v ON a.id_voiture = v.id_voiture " +
                             "JOIN categorie c ON a.id_categorie = c.id_categorie " +
                             "JOIN users u ON a.iduser = u.iduser " +
                             "WHERE a.iduser = ? " +
                             "ORDER BY a.date_fin DESC";
                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, iduser);
                rs = stmt.executeQuery();
                
                while(rs.next()) {
                  hasAssurances = true;
                  int id = rs.getInt("id_assurance");
                  String marque = rs.getString("marque");
                  Date dateDebut = rs.getDate("date_debut");
                  Date dateFin = rs.getDate("date_fin");
                  String immatriculation = rs.getString("immatriculation");
                  double prixTtc = rs.getDouble("prix_ttc");
                  int valider = rs.getInt("valider");
                  String status = rs.getString("status");
                  String agents = rs.getString("agents");
                  int resiliation = rs.getInt("resiliation");
                  int suspension = rs.getInt("suspension");
                  
                  // Déterminer le statut
                  String statusClass;
                  String statusText;
                  
                  java.util.Date today = new java.util.Date();
                  boolean isExpired = dateFin.before(today);
                  
                  if (isExpired) {
                    statusClass = "status-expired";
                    statusText = "Expirée";
                  } else if (status != null && status.equals("En attente") || valider == 0) {
                    statusClass = "status-pending";
                    statusText = "En attente";
                  }
                  else if (status != null && status.equals("Resilié") || resiliation ==1){
                    statusClass = "status-pending";
                    statusText = "resilié";
                  }else if (status != null && status.equals("suspendu") || suspension == 1){
                  statusClass = "status-pending";
                  statusText = "suspendu";
                } else {
                    statusClass = "status-active";
                    statusText = "Active";
                  }
                  
                  // Formater les dates
                  java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                  String formattedDateDebut = sdf.format(dateDebut);
                  String formattedDateFin = sdf.format(dateFin);
            %>
            <tr>
              <td><%= marque %></td>
              <td><%= formattedDateDebut %></td>
              <td><%= formattedDateFin %></td>
              <td><%= immatriculation %></td>
              <td><%= String.format("%,.2f", prixTtc) %> CFA</td>
              <td><span class="status-badge <%= statusClass %>"><%= statusText %></span></td>
              <td>
                <div class="action-buttons">
                   <button class="btn-action btn-view" onclick="viewDetails('<%= id %>')" title="Voir détails">
                    <i class="fas fa-eye"></i>
                  </button>
                  <button class="btn-action btn-print" onclick="printAssurance(
                    '<%= id %>',
                    '<%= marque %>',
                    '<%= rs.getString("firstname") %> <%= rs.getString("lastname") %>',
                    '<%= rs.getString("number") %>',
                    '<%= rs.getDate("date_debut") %>',
                    '<%= rs.getDate("date_fin") %>',
                    '<%= immatriculation %>',
                    '<%= rs.getInt("puissance") %>',
                    '<%= rs.getInt("nombre_place") %>',
                    '<%= (rs.getInt("energie")==0) ? "Essence" : "Gazoil" %>',
                    '<%= rs.getInt("nombre_mois") %>',
                    '<%= prixTtc %>',
                    '<%= (valider==1) ? "Payé" : "Non payé" %>',
                    '<%= agents %>'
                  )" title="Imprimer">
                    <i class="fas fa-print"></i>
                  </button>
                </div>
              </td>
            </tr>
            <% 
                }
              } catch(Exception e) {
                out.println("Erreur : " + e.getMessage());
              } finally {
                if(rs != null) try { rs.close(); } catch(SQLException ignore) {}
                if(stmt != null) try { stmt.close(); } catch(SQLException ignore) {}
                if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
              }
              
              if (!hasAssurances) {
            %>
            <tr>
              <td colspan="7">
                <div class="empty-state">
                  <i class="fas fa-file-alt"></i>
                  <p>Vous n'avez pas encore d'assurance. Demandez votre premier devis dès maintenant.</p>
                  <a href="devis.jsp" class="btn-print" style="margin-top: 10px; display: inline-block; padding: 8px 15px; border-radius: 5px; text-decoration: none;">
                    Demander un devis
                  </a>
                </div>
              </td>
            </tr>
            <%
              }
            %>
          </tbody>
        </table>
      </div>
      
      <!-- Pagination (à implémenter si besoin) -->
      <!--
      <div class="pagination">
        <div class="page-item"><a href="#" class="page-link"><i class="fas fa-chevron-left"></i></a></div>
        <div class="page-item"><a href="#" class="page-link active">1</a></div>
        <div class="page-item"><a href="#" class="page-link">2</a></div>
        <div class="page-item"><a href="#" class="page-link">3</a></div>
        <div class="page-item"><a href="#" class="page-link"><i class="fas fa-chevron-right"></i></a></div>
      </div>
      -->
    </div>
    
    <!-- Modal de détails -->
    <div class="modal" id="detailsModal">
      <div class="modal-content">
        <div class="modal-header success" id="modalHeader">
          <h3 class="modal-title">Détails de l'assurance</h3>
          <button class="modal-close" id="closeModal">&times;</button>
        </div>
        <div class="modal-body" id="detailsContent">
          <div class="loading">
            <div class="spinner"></div>
          </div>
        </div>
      </div>
    </div>
    

  </div>
  
  <!-- Script pour imprimer et afficher les détails -->
  <script>
    // Fonction pour filtrer le tableau
    document.addEventListener('DOMContentLoaded', function() {
      const searchInput = document.getElementById('searchInput');
      const table = document.getElementById('assuranceTable');
      const rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
      
      searchInput.addEventListener('keyup', function() {
        const searchTerm = searchInput.value.toLowerCase();
        
        for (let i = 0; i < rows.length; i++) {
          let found = false;
          const cells = rows[i].getElementsByTagName('td');
          
          // Ignorer la ligne d'état vide
          if (cells.length === 1) continue;
          
          for (let j = 0; j < cells.length; j++) {
            if (cells[j].textContent.toLowerCase().indexOf(searchTerm) > -1) {
              found = true;
              break;
            }
          }
          
          if (found) {
            rows[i].style.display = '';
          } else {
            rows[i].style.display = 'none';
          }
        }
      });
      
      // Tri des colonnes
      const headers = table.getElementsByTagName('thead')[0].getElementsByTagName('th');
      
      for (let i = 0; i < headers.length; i++) {
        if (headers[i].querySelector('.sort-icon')) {
          headers[i].addEventListener('click', function() {
            sortTable(i);
          });
        }
      }
      
      function sortTable(columnIndex) {
        let switching = true;
        let dir = 'asc';
        let switchcount = 0;
        
        while (switching) {
          switching = false;
          let shouldSwitch = false;
          
          for (let i = 0; i < rows.length - 1; i++) {
            const x = rows[i].getElementsByTagName('td')[columnIndex];
            const y = rows[i + 1].getElementsByTagName('td')[columnIndex];
            
            if (!x || !y) continue;
            
            // Ignorer la ligne d'état vide
            if (rows[i].getElementsByTagName('td').length === 1 || 
                rows[i + 1].getElementsByTagName('td').length === 1) continue;
            
            let xContent = x.textContent.toLowerCase();
            let yContent = y.textContent.toLowerCase();
            
            // Traitement spécial pour les colonnes de date
            if (columnIndex === 1 || columnIndex === 2) {
              const xDate = parseDate(xContent);
              const yDate = parseDate(yContent);
              
              if (dir === 'asc') {
                shouldSwitch = xDate > yDate;
              } else {
                shouldSwitch = xDate < yDate;
              }
            } 
            // Traitement pour la colonne de prix
            else if (columnIndex === 4) {
              const xPrice = parseFloat(xContent.replace(/[^0-9.,]/g, '').replace(',', '.'));
              const yPrice = parseFloat(yContent.replace(/[^0-9.,]/g, '').replace(',', '.'));
              
              if (dir === 'asc') {
                shouldSwitch = xPrice > yPrice;
              } else {
                shouldSwitch = xPrice < yPrice;
              }
            }
            // Tri alphabétique pour les autres colonnes
            else {
              if (dir === 'asc') {
                shouldSwitch = xContent > yContent;
              } else {
                shouldSwitch = xContent < yContent;
              }
            }
            
            if (shouldSwitch) {
              rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
              switching = true;
              switchcount++;
              break;
            }
          }
          
          if (switchcount === 0 && dir === 'asc') {
            dir = 'desc';
            switching = true;
          }
        }
        
        // Mise à jour des icônes de tri
        for (let i = 0; i < headers.length; i++) {
          const icon = headers[i].querySelector('.sort-icon i');
          if (icon) {
            icon.className = 'fas fa-sort';
          }
        }
        
        const currentIcon = headers[columnIndex].querySelector('.sort-icon i');
        if (currentIcon) {
          currentIcon.className = dir === 'asc' ? 'fas fa-sort-up' : 'fas fa-sort-down';
        }
      }
      
      function parseDate(dateStr) {
        // Format attendu: JJ/MM/AAAA
        const parts = dateStr.split('/');
        if (parts.length === 3) {
          return new Date(parts[2], parts[1] - 1, parts[0]);
        }
        return new Date(0); // Date par défaut
      }
      
      // Modal de détails
      const modal = document.getElementById('detailsModal');
      const closeModal = document.getElementById('closeModal');
      
      closeModal.addEventListener('click', function() {
        modal.classList.remove('show');
        setTimeout(() => {
          modal.style.display = 'none';
        }, 400);
      });
      
      window.addEventListener('click', function(event) {
        if (event.target === modal) {
          modal.classList.remove('show');
          setTimeout(() => {
            modal.style.display = 'none';
          }, 400);
        }
      });
      
      // Animation des cartes statistiques
      const statValues = document.querySelectorAll('.stat-value');
      
      statValues.forEach(value => {
        const finalValue = parseInt(value.textContent);
        let startValue = 0;
        const duration = 1000; // 1 seconde
        const frameDuration = 1000 / 60; // 60 FPS
        const totalFrames = Math.round(duration / frameDuration);
        let frame = 0;
        
        function animate() {
          frame++;
          const progress = frame / totalFrames;
          const currentValue = Math.round(progress * finalValue);
          
          if (frame < totalFrames) {
            value.textContent = currentValue;
            requestAnimationFrame(animate);
          } else {
            value.textContent = finalValue;
          }
        }
        
        animate();
      });
    });
    
    // Fonction pour voir les détails d'une assurance
    function viewDetails(id) {
      const modal = document.getElementById('detailsModal');
      const modalHeader = document.getElementById('modalHeader');
      const detailsContent = document.getElementById('detailsContent');
      const printDetailBtn = document.getElementById('printDetailBtn');
      
      // Afficher le modal avec animation
      modal.style.display = 'block';
      setTimeout(() => {
        modal.classList.add('show');
      }, 10);
      
      // Afficher le chargement
      detailsContent.innerHTML = '<div class="loading"><div class="spinner"></div></div>';
      
      // Simuler un chargement (à remplacer par une vraie requête AJAX)
      setTimeout(() => {
        // Créer un objet XMLHttpRequest
        const xhr = new XMLHttpRequest();
        xhr.open('GET', 'getAssuranceDetails.jsp?id=' + id, true);
        
        xhr.onload = function() {
          if (xhr.status === 200) {
            detailsContent.innerHTML = xhr.responseText;
            
            // Déterminer la classe du header en fonction du statut
            const statusBadge = detailsContent.querySelector('.status-badge');
            if (statusBadge) {
              if (statusBadge.classList.contains('status-active')) {
                modalHeader.className = 'modal-header success';
              } else if (statusBadge.classList.contains('status-pending')) {
                modalHeader.className = 'modal-header warning';
              } else if (statusBadge.classList.contains('status-expired')) {
                modalHeader.className = 'modal-header danger';
              }
            }
            
            // Configurer le bouton d'impression
            printDetailBtn.onclick = function() {
              const assuranceId = detailsContent.querySelector('.assurance-id');
              if (assuranceId) {
                const id = assuranceId.textContent;
                // Récupérer les autres informations nécessaires
                const marque = detailsContent.querySelector('.assurance-marque').textContent;
                const client = detailsContent.querySelector('.assurance-client').textContent;
                const telephone = detailsContent.querySelector('.assurance-telephone').textContent;
                const dateDebut = detailsContent.querySelector('.assurance-date-debut').textContent;
                const dateFin = detailsContent.querySelector('.assurance-date-fin').textContent;
                const immatriculation = detailsContent.querySelector('.assurance-immatriculation').textContent;
                const puissance = detailsContent.querySelector('.assurance-puissance').textContent;
                const places = detailsContent.querySelector('.assurance-places').textContent;
                const energie = detailsContent.querySelector('.assurance-energie').textContent;
                const mois = detailsContent.querySelector('.assurance-mois').textContent;
                const prix = detailsContent.querySelector('.assurance-prix').textContent;
                const valider = detailsContent.querySelector('.assurance-valider').textContent;
                const agent = detailsContent.querySelector('.assurance-agent').textContent;
                
                printAssurance(id, marque, client, telephone, dateDebut, dateFin, immatriculation, 
                            puissance, places, energie, mois, prix, valider, agent);
              }
            };
          } else {
            detailsContent.innerHTML = '<div class="error-message">Erreur lors du chargement des détails.</div>';
          }
        };
        
        xhr.onerror = function() {
          detailsContent.innerHTML = '<div class="error-message">Erreur de connexion.</div>';
        };
        
        xhr.send();
      }, 500);
    }
    
    // Fonction pour imprimer une assurance
    function printAssurance(id, marque, client, tel, dateDebut, dateFin, immat, puissance, nbPlaces, energie, nbMois, prixTtc, valide, agents) {
      if (valide === "Non payé" || valide === 0) {
        alert("L'impression n'est pas disponible car l'assurance n'est pas payée.");
        return;
      }
      
      // Utiliser jsPDF
      const { jsPDF } = window.jspdf;
      const doc = new jsPDF();

      // Configuration du document
      doc.setFontSize(16);
      doc.text("Attestation d'Assurance", 105, 20, { align: 'center' });
      
      // Logo ou entête
      doc.setFontSize(12);
      doc.text("ASSURANCE AUTOMOBILE", 105, 30, { align: 'center' });
      
      // Ligne de séparation
      doc.setLineWidth(0.5);
      doc.line(20, 35, 190, 35);
      
      // Informations de l'assurance
      doc.setFontSize(10);
      
      // Tableau des données
      const tableColumns = ["Information", "Détail"];
      const tableData = [
        ["Numéro d'assurance", id],
        ["Marque du véhicule", marque],
        ["Client", client],
        ["Téléphone", tel],
        ["Immatriculation", immat],
        ["Puissance", puissance + " CV"],
        ["Places", nbPlaces],
        ["Énergie", energie],
        ["Date de début", dateDebut],
        ["Date de fin", dateFin],
        ["Durée", nbMois + " mois"],
        ["Prix TTC", prixTtc + " €"],
        ["Agent", agents || "Non assigné"]
      ];
      
      // Générer le tableau
      doc.autoTable({
        startY: 45,
        head: [tableColumns],
        body: tableData,
        theme: 'grid',
        headStyles: { fillColor: [0, 102, 82], textColor: [255, 255, 255] },
        alternateRowStyles: { fillColor: [240, 240, 240] },
        margin: { top: 45, right: 20, bottom: 60, left: 20 },
      });
      
      // Note en bas de page
      const finalY = doc.lastAutoTable.finalY || 200;
      doc.setFontSize(8);
      doc.setTextColor(100, 100, 100);
      doc.text("NB: Cette attestation est valable pour 7 jours. Veuillez vous rendre dans l'une de nos agences", 20, finalY + 10);
      doc.text("pour obtenir l'attestation originale avant son expiration. Merci pour votre confiance.", 20, finalY + 15);
      
      // Pied de page avec date et signature
      const pageWidth = doc.internal.pageSize.getWidth();
      const pageHeight = doc.internal.pageSize.getHeight();
      
      // Date d'impression
      const today = new Date();
      const formattedDate = today.toLocaleDateString('fr-FR');
      doc.setFontSize(9);
      doc.text("Imprimé le " + formattedDate, 20, pageHeight - 20);
      
      // Agent signature
      doc.setFontSize(9);
      doc.text("Agent:", pageWidth - 50, pageHeight - 30);
      doc.line(pageWidth - 50, pageHeight - 28, pageWidth - 20, pageHeight - 28);
      doc.text(agents || "Non assigné", pageWidth - 50, pageHeight - 20);
      
      // Sauvegarder le PDF
      doc.save("attestation_assurance_" + id + ".pdf");
    }
  </script>
</body>
</html>