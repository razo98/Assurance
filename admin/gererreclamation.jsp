<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
   // Vérification de la session admin
   Integer idadmin = (Integer) session.getAttribute("idadmin");
   String firstname = (String) session.getAttribute("firstname");
   String lastname = (String) session.getAttribute("lastname");
   String fullName = (String) session.getAttribute("fullname");
   String role = (String) session.getAttribute("role");
   if(idadmin == null || role == null || !"soleil".equals(role)) {
      response.sendRedirect("../login.jsp");
      return;
   }
   
   // Récupérer l'historique des réclamations
   Connection conn = null;
   PreparedStatement stmt = null;
   ResultSet rs = null;
   boolean hasReclamations = false;
%>
<!DOCTYPE html>
<html lang="fr">
<head>
  <title>Gestion des Réclamations</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
  
  <style>
    /* Variables de thème identiques à la page précédente */
    :root {
      --primary-color: #006652;
      --secondary-color: #FF8C00;
      --text-color: #333;
      --light-bg: #f5f5f5;
      --white: #ffffff;
      --border-color: #ddd;
      
      --success-color: #28a745;
      --warning-color: #ffc107;
      --danger-color: #dc3545;
      --info-color: #17a2b8;
    }
    
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
      padding: 0 15px;
    }
    
    /* Messages d'alerte */
    .alert-dismissible .btn-close {
      padding: 0.5rem 0.75rem;
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
    
    /* Styles de la table et des actions */
    .reclamations-container {
      background-color: var(--white);
      border-radius: 10px;
      padding: 20px;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      margin-top: 20px;
    }
    
    .search-container {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
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
    
    .data-table {
      width: 100%;
      border-collapse: collapse;
    }
    
    .data-table th {
      background-color: var(--primary-color);
      color: var(--white);
      padding: 12px 15px;
      text-align: left;
    }
    
    .data-table tbody tr {
      border-bottom: 1px solid var(--border-color);
      transition: background-color 0.3s;
    }
    
    .data-table tbody tr:hover {
      background-color: rgba(0, 102, 82, 0.05);
    }
    
    .data-table td {
      padding: 12px 15px;
      vertical-align: middle;
    }
    
    /* Styles des statuts */
    .status-badge {
      display: inline-block;
      padding: 5px 10px;
      border-radius: 20px;
      font-size: 0.8em;
      font-weight: 600;
    }
    
    .status-pending {
      background-color: rgba(255, 193, 7, 0.15);
      color: #856404;
    }
    
    .status-processed {
      background-color: rgba(40, 167, 69, 0.15);
      color: #155724;
    }
    
    /* Boutons d'action */
    .row-actions {
      display: flex;
      gap: 10px;
    }
    
    .btn-action {
      padding: 6px 12px;
      border-radius: 5px;
      text-decoration: none;
      transition: all 0.3s ease;
      display: inline-flex;
      align-items: center;
      font-size: 0.9em;
    }
    
    .btn-view {
      background-color: var(--info-color);
      color: var(--white);
    }
    
    .btn-view:hover {
      background-color: #138496;
    }
    
    /* Modal pour les détails de la réclamation */
    .modal {
      display: none;
      position: fixed;
      z-index: 1000;
      left: 0;
      top: 0;
      width: 100%;
      height: 100%;
      overflow: auto;
      background-color: rgba(0, 0, 0, 0.5);
      backdrop-filter: blur(3px);
    }
    
    .modal-content {
      background-color: var(--white);
      margin: 5% auto;
      padding: 25px;
      border-radius: 10px;
      max-width: 700px;
      position: relative;
      box-shadow: 0 5px 20px rgba(0, 0, 0, 0.2);
      max-height: 90vh;
      overflow-y: auto;
    }
    
    .modal-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 1px solid var(--border-color);
      padding-bottom: 15px;
      margin-bottom: 15px;
    }
    
    .modal-close {
      background: none;
      border: none;
      font-size: 24px;
      cursor: pointer;
      color: #aaa;
      transition: color 0.3s;
    }
    
    .modal-close:hover {
      color: var(--text-color);
    }
    
    .modal-body {
      margin-bottom: 15px;
    }
    
    .response-form {
      margin-top: 20px;
      border-top: 1px solid var(--border-color);
      padding-top: 20px;
    }
    
    .form-control-response {
      width: 100%;
      padding: 10px;
      border: 1px solid var(--border-color);
      border-radius: 5px;
      min-height: 100px;
      font-family: inherit;
      resize: vertical;
    }
    
    .form-control-response:focus {
      border-color: var(--primary-color);
      box-shadow: 0 0 0 3px rgba(0, 102, 82, 0.2);
      outline: none;
    }
    
    .btn-response {
      background-color: var(--primary-color);
      color: var(--white);
      border: none;
      padding: 10px 20px;
      border-radius: 5px;
      margin-top: 10px;
      cursor: pointer;
      transition: background-color 0.3s;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    .btn-response:hover {
      background-color: #004f3f;
    }
    
    .btn-response:disabled {
      background-color: #ccc;
      cursor: not-allowed;
    }
    
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
    }
    
    .user-badge i {
      margin-right: 8px;
      font-size: 16px;
    }
    
    .urgence-urgente { color: #dc3545; font-weight: bold; }
    .urgence-elevee { color: #ffc107; font-weight: 600; }
    .urgence-normale { color: var(--text-color); }
    
    /* Animations */
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    @keyframes modalFadeIn {
      from { opacity: 0; transform: scale(0.9); }
      to { opacity: 1; transform: scale(1); }
    }
    
    .modal-content {
      animation: modalFadeIn 0.3s ease;
    }
    
    /* Responsive */
    @media (max-width: 768px) {
      .search-container {
        flex-direction: column;
        align-items: flex-start;
      }
      
      .search-input {
        width: 100%;
        margin-top: 10px;
      }
      
      .modal-content {
        margin: 2% auto;
        max-width: 95%;
      }
    }
  </style>
</head>
<body>
  <%@ include file="../mead.jsp" %>
  
  <div class="container">
    <%
        // Gestion des messages de succès et d'erreur
        String successMessage = (String) session.getAttribute("successMessage");
        String errorMessage = (String) session.getAttribute("errorMessage");
        
        if (successMessage != null) {
    %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <%= successMessage %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <%
            // Effacer le message de la session
            session.removeAttribute("successMessage");
        }
        
        if (errorMessage != null) {
    %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <%= errorMessage %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <%
            // Effacer le message de la session
            session.removeAttribute("errorMessage");
        }
    %>
    
    <div class="page-header">
      <h1 class="page-title">Gestion des Réclamations</h1>
    </div>
    
    <div class="reclamations-container">
      <div class="search-container">
        <h2 class="section-title"><i class="fas fa-list"></i> Liste des réclamations</h2>
        <input type="text" id="searchInput" class="search-input" placeholder="Rechercher une réclamation...">
      </div>
      
      <div class="table-responsive">
        <table id="dataTable" class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Client</th>
              <th>Sujet</th>
              <th>Date</th>
              <th>Statut</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
          <%
            try {
              Class.forName("org.mariadb.jdbc.Driver");
              conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
              
              String sqlReclamations = "SELECT r.id_reclamation, u.firstname, u.lastname, r.sujet, r.date_reclamation, r.etat, r.libelle, r.reponse, r.urgence " +
                                       "FROM reclamation r " +
                                       "JOIN users u ON r.iduser = u.iduser " +
                                       "WHERE r.etat NOT IN ('Traitee', 'Traitée') " + // Filtrer les réclamations non traitées (avec et sans accent)
                                       "ORDER BY " +
                                       "CASE " +
                                       "  WHEN r.urgence = 'Urgente' THEN 1 " +
                                       "  WHEN r.urgence = 'Élevée' OR r.urgence = 'Elevee' THEN 2 " +
                                       "  WHEN r.urgence = 'Normale' THEN 3 " +
                                       "  ELSE 4 " +
                                       "END, r.date_reclamation ASC";
              stmt = conn.prepareStatement(sqlReclamations);
              rs = stmt.executeQuery();
              
              while(rs.next()) {
                int idReclamation = rs.getInt("id_reclamation");
                String client = rs.getString("firstname") + " " + rs.getString("lastname");
                String sujet = rs.getString("sujet");
                java.sql.Timestamp dateReclamation = rs.getTimestamp("date_reclamation");
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
                String formattedDate = sdf.format(dateReclamation);
                
                String etat = rs.getString("etat");
                String urgence = rs.getString("urgence") != null ? rs.getString("urgence") : "Normale";
                String libelle = rs.getString("libelle") != null ? rs.getString("libelle") : "";
                String reponse = rs.getString("reponse") != null ? rs.getString("reponse") : "";
                
                String statusClass = "status-pending";
                String statusText = "En attente";
                String urgenceClass = "urgence-normale";
                
                if ("Urgente".equals(urgence)) {
                    urgenceClass = "urgence-urgente";
                } else if ("Elevee".equals(urgence)) {
                    urgenceClass = "urgence-elevee";
                }
          %>
            <tr>
              <td><%= idReclamation %></td>
              <td><%= client %></td>
              <td>
                <span class="<%= urgenceClass %>">
                  <%= sujet %>
                  <% if (!"Normale".equals(urgence)) { %>
                    (<%= urgence %>)
                  <% } %>
                </span>
              </td>
              <td><%= formattedDate %></td>
              <td><span class="status-badge <%= statusClass %>"><%= statusText %></span></td>
              <td>
                <div class="row-actions">
                  <button class="btn-action btn-view btn-details" 
                          data-id="<%= idReclamation %>"
                          data-client="<%= client %>"
                          data-sujet="<%= sujet %>"
                          data-libelle="<%= libelle.replace("\"", "&quot;").replace("'", "&#39;") %>"
                          data-urgence="<%= urgence %>"
                          data-reponse="<%= reponse.replace("\"", "&quot;").replace("'", "&#39;") %>"
                          type="button">
                    <i class="fas fa-eye"></i> Détails
                  </button>
                </div>
              </td>
            </tr>
          <%
              }
            } catch(Exception e) {
              out.println("Erreur : " + e.getMessage());
            }finally {
              if(rs != null) try { rs.close(); } catch(SQLException ignore) {}
              if(stmt != null) try { stmt.close(); } catch(SQLException ignore) {}
              if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
            }
          %>
          </tbody>
        </table>
      </div>
    </div>
    
    <!-- Modal Détails Réclamation -->
    <div class="modal" id="detailsModal">
      <div class="modal-content">
        <div class="modal-header">
          <h3 id="modalTitle">Détails de la Réclamation</h3>
          <button class="modal-close" id="closeModal" type="button">&times;</button>
        </div>
        <div class="modal-body">
          <div id="reclamationDetails">
            <div class="row mb-3">
              <div class="col-md-6">
                <strong>Client :</strong> <span id="modalClient"></span>
              </div>
              <div class="col-md-6">
                <strong>Urgence :</strong> <span id="modalUrgence"></span>
              </div>
            </div>
            <p><strong>Sujet :</strong> <span id="modalSujet"></span></p>
            <p><strong>Message :</strong></p>
            <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin-bottom: 15px;">
              <span id="modalLibelle"></span>
            </div>
            
            <div class="response-form">
              <form id="responseForm" action="traiterReclamation.jsp" method="post">
                <input type="hidden" name="id_reclamation" id="modalReclamationId">
                <label for="reponseTextarea" class="form-label"><strong>Votre réponse :</strong></label>
                <textarea name="reponse" id="reponseTextarea" class="form-control-response" 
                          placeholder="Rédigez votre réponse détaillée..." required minlength="10"></textarea>
                <button type="submit" class="btn-response" id="submitResponse">
                  <i class="fas fa-paper-plane"></i> Envoyer la réponse
                </button>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
    
  </div>
  
  <!-- Scripts -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    $(document).ready(function() {
      // Gestion de la modal des détails de réclamation
      const detailsModal = $('#detailsModal');
      const closeModal = $('#closeModal');
      const responseForm = $('#responseForm');
      
      // Ouvrir la modal
      $(document).on('click', '.btn-details', function(e) {
        e.preventDefault();
        
        // Récupérer les données du bouton
        const id = $(this).attr('data-id');
        const client = $(this).attr('data-client');
        const sujet = $(this).attr('data-sujet');
        const libelle = $(this).attr('data-libelle');
        const urgence = $(this).attr('data-urgence');
        const reponse = $(this).attr('data-reponse');
        
        console.log('Données récupérées:', { id, client, sujet, libelle, urgence }); // Debug
        
        // Remplir les détails de la réclamation
        $('#modalClient').text(client);
        $('#modalSujet').text(sujet);
        $('#modalLibelle').text(libelle);
        $('#modalUrgence').text(urgence);
        $('#modalReclamationId').val(id);
        
        // Vider le textarea de réponse
        $('#reponseTextarea').val('');
        
        // Afficher la modal
        detailsModal.show();
      });
      
      // Fermer la modal
      closeModal.on('click', function() {
        detailsModal.hide();
      });
      
      // Fermer la modal si clic en dehors
      $(window).on('click', function(event) {
        if (event.target.id === 'detailsModal') {
          detailsModal.hide();
        }
      });
      
      // Validation du formulaire de réponse
      responseForm.on('submit', function(e) {
        const reponseTextarea = $('#reponseTextarea');
        const submitBtn = $('#submitResponse');
        
        if (reponseTextarea.val().trim().length < 10) {
          e.preventDefault();
          alert('Veuillez saisir une réponse d\'au moins 10 caractères.');
          reponseTextarea.focus();
          return false;
        }
        
        // Désactiver le bouton pour éviter les doubles soumissions
        submitBtn.prop('disabled', true);
        submitBtn.html('<i class="fas fa-spinner fa-spin"></i> Envoi en cours...');
        
        return true;
      });
      
      // Fonction de recherche simple
      $('#searchInput').on('keyup', function() {
        const value = $(this).val().toLowerCase();
        $('#dataTable tbody tr').filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
      });
    });
  </script>
</body>
</html>