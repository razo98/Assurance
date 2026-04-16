<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
   // Récupération des informations de l'admin depuis la session
   Integer idadmin = (Integer) session.getAttribute("idadmin");
   String firstname = (String) session.getAttribute("firstname");
   String lastname = (String) session.getAttribute("lastname");
   String fullName = (String) session.getAttribute("fullname");
   String role = (String) session.getAttribute("role");
   
   // Vérification des droits d'accès
   if(idadmin == null || role == null || !"soleil".equals(role)) {
      response.sendRedirect("../login.jsp");
      return;
   }
   
   // Traitement de la validation si un ID est fourni
   String assuranceId = request.getParameter("id");
   
   if(assuranceId != null) {
      Connection updateConn = null;
      PreparedStatement updateStmt = null;
      
      try {
         Class.forName("org.mariadb.jdbc.Driver");
         updateConn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
         
         // Requête SQL pour mettre à jour l'assurance (uniquement valider = 1)
         String updateSql = "UPDATE assurance SET valider = 1 WHERE id_assurance = ?";
         updateStmt = updateConn.prepareStatement(updateSql);
         updateStmt.setInt(1, Integer.parseInt(assuranceId));
         
         int result = updateStmt.executeUpdate();
         if(result > 0) {
            // La mise à jour a réussi
            response.sendRedirect("validerAssurance.jsp?success=1");
            return;
         } else {
            // Aucune ligne mise à jour
            response.sendRedirect("validerAssurance.jsp?error=1");
            return;
         }
      } catch(Exception e) {
         // Une erreur s'est produite
         response.sendRedirect("validerAssurance.jsp?error=" + e.getMessage());
         return;
      } finally {
         if(updateStmt != null) try { updateStmt.close(); } catch(SQLException ignore) {}
         if(updateConn != null) try { updateConn.close(); } catch(SQLException ignore) {}
      }
   }
   
   // Récupérer le paramètre de succès/erreur pour afficher des messages
   String success = request.getParameter("success");
   String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Validation des Assurances</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
  
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
      max-width: 1400px;
      margin: 0 auto;
      padding: 0 15px;
    }
    
    /* Page Header */
    .page-header {
      text-align: center;
      margin: 30px 0;
      animation: fadeIn 0.8s ease;
    }
    
    .page-title {
      color: var(--primary-color);
      font-size: 28px;
      font-weight: 700;
      position: relative;
      display: inline-block;
      padding-bottom: 10px;
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
    
    /* Alert Messages */
    .alert {
      padding: 15px;
      margin-bottom: 20px;
      border-radius: 5px;
      animation: fadeIn 0.5s ease;
    }
    
    .alert-success {
      background-color: rgba(40, 167, 69, 0.1);
      border-left: 4px solid var(--success-color);
      color: var(--success-color);
    }
    
    .alert-danger {
      background-color: rgba(220, 53, 69, 0.1);
      border-left: 4px solid var(--danger-color);
      color: var(--danger-color);
    }
    
    /* Table Container */
    .table-container {
      background-color: var(--white);
      border-radius: 10px;
      padding: 20px;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      margin-bottom: 30px;
      animation: fadeIn 0.8s ease 0.4s both;
      overflow: hidden;
    }
    
    /* Search Container */
    .search-container {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 15px;
    }
    
    .section-title {
      font-size: 18px;
      font-weight: 600;
      color: var(--primary-color);
      margin: 0;
      display: flex;
      align-items: center;
    }
    
    .section-title i {
      margin-right: 8px;
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
    
    /* Buttons */
    .btn-validate {
      background-color: var(--success-color);
      color: var(--white);
      padding: 8px 12px;
      border: none;
      border-radius: 5px;
      font-size: 14px;
      cursor: pointer;
      transition: background-color 0.3s, transform 0.3s;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    .btn-validate:hover {
      background-color: #218838;
      transform: translateY(-2px);
    }
    
    .btn-validate i {
      margin-right: 5px;
    }
    
    /* Empty State */
    .empty-state {
      text-align: center;
      padding: 50px 20px;
      color: #6c757d;
    }
    
    .empty-state i {
      font-size: 48px;
      margin-bottom: 15px;
      color: #dee2e6;
    }
    
    .empty-state p {
      font-size: 16px;
      margin-bottom: 0;
    }
    
    /* Status Badges */
    .status-badge {
      display: inline-block;
      padding: 3px 8px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
      text-align: center;
    }
    
    .status-pending {
      background-color: rgba(255, 193, 7, 0.1);
      color: var(--warning-color);
    }
    
    /* Animations */
    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }
    
    /* Responsive Adjustments */
    @media (max-width: 768px) {
      .search-container {
        flex-direction: column;
        align-items: flex-start;
      }
      
      .search-input {
        width: 100%;
        margin-top: 10px;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <%@ include file="../mead.jsp" %>
    <br><br>
    
    <div class="page-header">
      <h1 class="page-title">Validation des Assurances</h1>
    </div>
    
    <% if("1".equals(success)) { %>
      <div class="alert alert-success">
        <i class="fas fa-check-circle"></i> L'assurance a été validée avec succès.
      </div>
    <% } else if(error != null) { %>
      <div class="alert alert-danger">
        <i class="fas fa-exclamation-circle"></i> Erreur: <%= error %>
      </div>
    <% } %>
    
    <div class="table-container">
      <div class="search-container">
        <h2 class="section-title"><i class="fas fa-file-invoice-dollar"></i> Assurances en attente de validation</h2>
        <input type="text" id="searchInput" class="search-input" placeholder="Rechercher...">
      </div>
      
      <div class="table-responsive">
        <table class="assurance-table" id="assuranceTable">
          <thead>
            <tr>
              <th>Client</th>
              <th>Marque</th>
              <th>Immatriculation</th>
              <th>PrixTTC</th>
              <th>Mode Paiement</th>
              <th>Code Transaction</th>
              <th>Action</th>
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
                
                // Requête : récupération des assurances non validées avec les informations essentielles
                String sql = "SELECT a.id_assurance, a.clients, v.marque, a.immatriculation, " +
                             "a.mode_paiement, a.code_transaction, a.prix_ttc " +
                             "FROM assurance a " +
                             "JOIN voiture v ON a.id_voiture = v.id_voiture " +
                             "WHERE a.valider = 0";
                stmt = conn.prepareStatement(sql);
                rs = stmt.executeQuery();
                
                boolean hasRecords = false;
                while(rs.next()){
                  hasRecords = true;
                  String modePaiement = rs.getString("mode_paiement");
                  String codeTransaction = rs.getString("code_transaction");
            %>
            <tr>
              <td><%= rs.getString("clients") %></td>
              <td><%= rs.getString("marque") %></td>
              <td><%= rs.getString("immatriculation") %></td>
              <td><%= rs.getInt("prix_ttc") %></td>
              <td>
                <% if(modePaiement != null && !modePaiement.isEmpty()) { %>
                  <%= modePaiement %>
                <% } else { %>
                  <span class="status-badge status-pending">Non renseigné</span>
                <% } %>
              </td>
              <td>
                <% if(codeTransaction != null && !codeTransaction.isEmpty()) { %>
                  <%= codeTransaction %>
                <% } else { %>
                  <span class="status-badge status-pending">Non renseigné</span>
                <% } %>
              </td>
              <td>
                <button class="btn-validate" onclick="confirmValidation(<%= rs.getInt("id_assurance") %>)">
                  <i class="fas fa-check-circle"></i> Valider
                </button>
              </td>
            </tr>
            <%
                }
                
                if(!hasRecords) {
            %>
            <tr>
              <td colspan="6" class="empty-state">
                <i class="fas fa-check-circle"></i>
                <p>Aucune assurance en attente de validation</p>
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
    
    <!-- User Badge -->
    <div class="user-badge">
      <i class="fas fa-user-tie"></i> <%= fullName != null ? fullName : firstname + " " + lastname %>
    </div>
  </div>

  <script>
    // Confirmer avant validation
    function confirmValidation(assuranceId) {
      if(confirm("Confirmez-vous la validation de cette assurance ?")) {
        window.location.href = "validerAssurance.jsp?id=" + assuranceId;
      }
    }
    
    // Recherche dans le tableau
    document.addEventListener('DOMContentLoaded', function() {
      const searchInput = document.getElementById('searchInput');
      const table = document.getElementById('assuranceTable');
      
      if (searchInput && table) {
        const rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
        
        searchInput.addEventListener('keyup', function() {
          const searchTerm = searchInput.value.toLowerCase();
          
          for (let i = 0; i < rows.length; i++) {
            let found = false;
            const cells = rows[i].getElementsByTagName('td');
            
            // Ne pas filtrer la ligne "Aucune assurance en attente"
            if (cells.length === 1 && cells[0].classList.contains('empty-state')) {
              continue;
            }
            
            for (let j = 0; j < cells.length - 1; j++) { // Exclure la dernière colonne (actions)
              if (cells[j].textContent.toLowerCase().indexOf(searchTerm) > -1) {
                found = true;
                break;
              }
            }
            
            rows[i].style.display = found ? '' : 'none';
          }
        });
      }
    });
  </script>
  
  <!-- DataTables pour des fonctionnalités avancées de tableau -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
  <script>
    $(document).ready(function() {
      // Initialiser DataTables avec options minimalistes
      $('#assuranceTable').DataTable({
        "paging": false,
        "info": false,
        "searching": false,
        "ordering": true,
        "language": {
          "emptyTable": "Aucune assurance en attente de validation",
          "zeroRecords": "Aucun résultat trouvé"
        }
      });
      
      // Cacher les éléments de DataTables pour utiliser notre recherche personnalisée
      $('.dataTables_wrapper .dataTables_filter').hide();
    });
  </script>
</body>
</html>