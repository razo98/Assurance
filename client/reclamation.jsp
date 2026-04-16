<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

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
  <title>Faire une Réclamation</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="../public/css/1bootstrap.min.css" rel="stylesheet">
  <link href="../public/css/2dataTables.bootstrap5.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
  <link rel="stylesheet" href="../css/global.css">
  <style>
    /* Variables de thème cohérentes */
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
    
    .reclamation-container {
      display: flex;
      flex-wrap: wrap;
      gap: 2rem;
      margin-top: 2rem;
    }
    
    .form-section {
      flex: 1;
      min-width: 300px;
      background-color: rgba(255, 255, 255, 0.9);
      border-radius: 10px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
      padding: 1.5rem;
    }
    
    .history-section {
      flex: 1;
      min-width: 300px;
      background-color: rgba(255, 255, 255, 0.9);
      border-radius: 10px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
      padding: 1.5rem;
      overflow: hidden;
    }
    
    .section-title {
      margin-bottom: 1.5rem;
      color: var(--primary-color);
      font-weight: 600;
      font-size: 1.25rem;
      display: flex;
      align-items: center;
    }
    
    .section-title i {
      margin-right: 0.75rem;
    }
    
    .form-group {
      margin-bottom: 1.25rem;
    }
    
    .form-label {
      display: block;
      margin-bottom: 0.5rem;
      font-weight: 500;
      color: var(--text-color);
    }
    
    .form-control {
      width: 100%;
      padding: 0.75rem 1rem;
      font-size: 1rem;
      line-height: 1.5;
      color: var(--text-color);
      background-color: #f8f9fa;
      border: 1px solid #ced4da;
      border-radius: 0.25rem;
      transition: all 0.3s;
    }
    
    .form-control:focus {
      background-color: #fff;
      border-color: var(--primary-color);
      outline: 0;
      box-shadow: 0 0 0 0.2rem rgba(0, 102, 82, 0.25);
    }
    
    .form-select {
      width: 100%;
      padding: 0.75rem 1rem;
      font-size: 1rem;
      line-height: 1.5;
      color: var(--text-color);
      background-color: #f8f9fa;
      border: 1px solid #ced4da;
      border-radius: 0.25rem;
      transition: all 0.3s;
      cursor: pointer;
    }
    
    .form-select:focus {
      background-color: #fff;
      border-color: var(--primary-color);
      outline: 0;
      box-shadow: 0 0 0 0.2rem rgba(0, 102, 82, 0.25);
    }
    
    .btn-submit {
      display: inline-block;
      font-weight: 500;
      color: white;
      text-align: center;
      vertical-align: middle;
      cursor: pointer;
      background-color: var(--primary-color);
      border: 1px solid var(--primary-color);
      padding: 0.75rem 1.5rem;
      font-size: 1rem;
      line-height: 1.5;
      border-radius: 0.25rem;
      transition: all 0.3s;
    }
    
    .btn-submit:hover {
      background-color: #004f3f;
      border-color: #004f3f;
      transform: translateY(-1px);
    }
    
    .btn-submit:disabled {
      background-color: #6c757d;
      border-color: #6c757d;
      cursor: not-allowed;
      transform: none;
    }
    
    .empty-history {
      text-align: center;
      padding: 2rem;
      color: var(--text-light);
    }
    
    .empty-history i {
      font-size: 3rem;
      margin-bottom: 1rem;
      color: #6c757d;
    }
    
    .reclamation-card {
      background-color: white;
      border-radius: 8px;
      padding: 1rem;
      margin-bottom: 1rem;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
      border-left: 4px solid var(--primary-color);
      transition: transform 0.2s, box-shadow 0.2s;
      overflow: hidden;
      word-break: break-word;
    }
    
    .reclamation-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }
    
    .reclamation-card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 0.75rem;
      font-size: 0.9rem;
    }
    
    .reclamation-date {
      color: #6c757d;
      font-weight: 500;
    }
    
    .reclamation-status {
      display: inline-block;
      padding: 0.25rem 0.75rem;
      border-radius: 20px;
      font-size: 0.75rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    
    .status-pending {
      background-color: rgba(255, 193, 7, 0.15);
      color: #856404;
      border: 1px solid rgba(255, 193, 7, 0.3);
    }
    
    .status-processed {
      background-color: rgba(40, 167, 69, 0.15);
      color: #155724;
      border: 1px solid rgba(40, 167, 69, 0.3);
    }
    
    .reclamation-sujet {
      font-weight: 600;
      color: var(--primary-color);
      margin-bottom: 0.5rem;
    }
    
    .reclamation-content {
      margin-bottom: 0.75rem;
      color: var(--text-color);
      line-height: 1.6;
      word-wrap: break-word;
      overflow-wrap: break-word;
      max-width: 100%;
    }
    
    .reclamation-response {
      background-color: #e8f5e8;
      padding: 0.75rem;
      border-radius: 4px;
      margin-top: 0.5rem;
      border-left: 3px solid var(--success-color);
      word-wrap: break-word;
      overflow-wrap: break-word;
      max-width: 100%;
    }
    
    .reclamation-response strong {
      color: var(--success-color);
    }
    
    .urgence-badge {
      display: inline-block;
      padding: 0.2rem 0.5rem;
      border-radius: 10px;
      font-size: 0.7rem;
      font-weight: 600;
      margin-left: 0.5rem;
    }
    
    .urgence-normale {
      background-color: rgba(108, 117, 125, 0.15);
      color: #495057;
    }
    
    .urgence-elevee {
      background-color: rgba(255, 193, 7, 0.15);
      color: #856404;
    }
    
    .urgence-urgente {
      background-color: rgba(220, 53, 69, 0.15);
      color: #721c24;
    }
    
    /* Badge utilisateur flottant */
    .user-badge {
      position: fixed;
      bottom: 20px;
      right: 20px;
      background-color: var(--primary-color);
      color: white;
      padding: 0.5rem 1rem;
      border-radius: 30px;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
      display: flex;
      align-items: center;
      z-index: 1000;
    }
    
    .user-badge i {
      margin-right: 8px;
      font-size: 1.2rem;
    }
    
    /* Loader pour le formulaire */
    .btn-loading {
      position: relative;
    }
    
    .btn-loading::after {
      content: "";
      position: absolute;
      width: 16px;
      height: 16px;
      margin: auto;
      border: 2px solid transparent;
      border-top-color: #fff;
      border-radius: 50%;
      animation: spin 1s linear infinite;
    }
    
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    
    @media (max-width: 768px) {
      .reclamation-container {
        flex-direction: column;
        gap: 1.5rem;
      }
      
      .reclamation-card-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 0.5rem;
      }
    }
  </style>
</head>
<body>
    <div class="container">
    <%@ include file="../me.jsp" %>
    <br><br>
    
    <!-- Messages de succès et d'erreur -->
    <%
        String successMessage = (String) session.getAttribute("successMessage");
        String errorMessage = (String) session.getAttribute("errorMessage");
        
        if (successMessage != null) {
    %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle"></i> <%= successMessage %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <%
            session.removeAttribute("successMessage");
        }
        
        if (errorMessage != null) {
    %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-triangle"></i> <%= errorMessage %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <%
            session.removeAttribute("errorMessage");
        }
    %>
    
    <div class="reclamation-container">
      <!-- Formulaire de réclamation -->
      <div class="form-section">
        <h2 class="section-title">
          <i class="fas fa-comment-alt"></i> Faire une réclamation
        </h2>
        
        <form action="traitementReclamation.jsp" method="post" id="reclamationForm">
          <div class="form-group">
            <label for="assurance_id" class="form-label">
              <i class="fas fa-car"></i> Concerne l'assurance (optionnel)
            </label>
            <select name="assurance_id" id="assurance_id" class="form-select">
              <option value="">-- Sélectionner une assurance --</option>
              <%
                Connection connAssurance = null;
                PreparedStatement stmtAssurance = null;
                ResultSet rsAssurance = null;
                try {
                  Class.forName("org.mariadb.jdbc.Driver");
                  connAssurance = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
                  
                  String sql = "SELECT a.id_assurance, v.marque, a.immatriculation, a.status " +
                               "FROM assurance a " +
                               "JOIN voiture v ON a.id_voiture = v.id_voiture " +
                               "WHERE a.iduser = ? " +
                               "ORDER BY a.date_fin DESC";
                  stmtAssurance = connAssurance.prepareStatement(sql);
                  stmtAssurance.setInt(1, iduser);
                  rsAssurance = stmtAssurance.executeQuery();
                  
                  while(rsAssurance.next()) {
              %>
              <option value="<%= rsAssurance.getInt("id_assurance") %>">
                <%= rsAssurance.getString("marque") %> - <%= rsAssurance.getString("immatriculation") %>
              </option>
              <%
                  }
                } catch(Exception e) {
                  out.println("<!-- Erreur assurances : " + e.getMessage() + " -->");
                } finally {
                    if(rsAssurance != null) try { rsAssurance.close(); } catch(SQLException ignore) {}
                    if(stmtAssurance != null) try { stmtAssurance.close(); } catch(SQLException ignore) {}
                    if(connAssurance != null) try { connAssurance.close(); } catch(SQLException ignore) {}
                }
              %>
            </select>
          </div>
          
          <div class="form-group">
            <label for="sujet" class="form-label">
              <i class="fas fa-tag"></i> Sujet *
            </label>
            <select name="sujet" id="sujet" class="form-select" required>
              <option value="" disabled selected>-- Sélectionner un sujet --</option>
              <option value="Problème de paiement">Problème de paiement</option>
              <option value="Demande d'information">Demande d'information</option>
              <option value="Attestation non reçue">Attestation non reçue</option>
              <option value="Modification de contrat">Modification de contrat</option>
              <option value="Sinistre">Déclaration de sinistre</option>
              <option value="Résiliation">Demande de résiliation</option>
              <option value="Renouvellement">Question sur renouvellement</option>
              <option value="Autre">Autre</option>
            </select>
          </div>
          
          <div class="form-group">
            <label for="libelle" class="form-label">
              <i class="fas fa-pen"></i> Votre message *
            </label>
            <textarea class="form-control" name="libelle" id="libelle" rows="5" 
                      placeholder="Décrivez votre problème ou votre demande en détail (minimum 10 caractères)" required></textarea>
            <small class="form-text text-muted">
              <span id="charCount">0</span> caractères (minimum 10 requis)
            </small>
          </div>
          
          <div class="form-group">
            <label for="urgence" class="form-label">
              <i class="fas fa-exclamation-circle"></i> Niveau d'urgence
            </label>
            <select name="urgence" id="urgence" class="form-select" required>
              <option value="Normale">Normale</option>
              <option value="Élevée">Élevée</option>
              <option value="Urgente">Urgente</option>
            </select>
            <small class="form-text text-muted">
              Les réclamations urgentes sont traitées en priorité
            </small>
          </div>
          
          <div class="text-center">
            <button type="submit" class="btn-submit" id="submitBtn">
              <i class="fas fa-paper-plane"></i> Envoyer ma réclamation
            </button>
          </div>
        </form>
      </div>
      
      <!-- Historique des réclamations -->
      <div class="history-section">
        <h2 class="section-title">
          <i class="fas fa-history"></i> Historique de vos réclamations
        </h2>
        
        <div id="reclamation-history">
          <%
          Connection connRec = null;
          PreparedStatement stmtRec = null;
          ResultSet rsRec = null;
          boolean hasReclamations = false;
          try {
            Class.forName("org.mariadb.jdbc.Driver");
            connRec = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
            String sqlReclamations =
              "SELECT id_reclamation, sujet, libelle, date_reclamation, etat, reponse, urgence " +
              "FROM reclamation WHERE iduser = ? " +
              "ORDER BY date_reclamation DESC";
            stmtRec = connRec.prepareStatement(sqlReclamations);
            stmtRec.setInt(1, iduser);
            rsRec = stmtRec.executeQuery();
              
              hasReclamations = false;
              
              while(rsRec.next()) {
                hasReclamations = true;
                String etat = rsRec.getString("etat");
                String statusClass = "status-pending";
                String statusText = "En attente";
                if (etat != null) {
                    if ("Traitée".equals(etat) || "Traitee".equals(etat)) {
                        statusClass = "status-processed";
                        statusText = "Traitée";
                    }
                }
                
                String urgence = rsRec.getString("urgence");
                String urgenceClass = "urgence-normale";
                if ("Élevée".equals(urgence) || "Elevee".equals(urgence)) {
                    urgenceClass = "urgence-elevee";
                } else if ("Urgente".equals(urgence)) {
                    urgenceClass = "urgence-urgente";
                }
                
                // Formater la date
                java.sql.Timestamp dateReclamation = rsRec.getTimestamp("date_reclamation");
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
                String formattedDate = dateReclamation != null ? sdf.format(dateReclamation) : "";
          %>
          <div class="reclamation-card">
            <div class="reclamation-card-header">
              <span class="reclamation-date">
                <i class="far fa-calendar-alt"></i> <%= formattedDate %>
              </span>
              <div>
                <span class="urgence-badge <%= urgenceClass %>"><%= urgence %></span>
                <span class="reclamation-status <%= statusClass %>"><%= statusText %></span>
              </div>
            </div>
            <div class="reclamation-sujet">
              <%= rsRec.getString("sujet") %>
            </div>
            <div class="reclamation-content">
              <%= rsRec.getString("libelle") %>
            </div>
            <% if(rsRec.getString("reponse") != null && !rsRec.getString("reponse").isEmpty()) { %>
            <div class="reclamation-response">
              <strong><i class="fas fa-reply"></i> Réponse de MBA Niger :</strong><br>
              <div style="margin-top: 8px; white-space: pre-wrap;"><%= rsRec.getString("reponse") %></div>
            </div>
            <% } %>
          </div>
          <%
              }
              
              if(!hasReclamations) {
          %>
          <div class="empty-history">
            <i class="fas fa-inbox"></i>
            <p>Vous n'avez pas encore fait de réclamation.</p>
            <small class="text-muted">Vos futures réclamations apparaîtront ici.</small>
          </div>
          <%
              }
            } catch(Exception e) {
              out.println("<!-- Erreur réclamations : " + e.getMessage() + " -->");
          %>
          <div class="alert alert-warning">
            <i class="fas fa-exclamation-triangle"></i>
            Impossible de charger l'historique des réclamations pour le moment.
          </div>
          <%
            } finally {
              if(rsRec != null) try { rsRec.close(); } catch(SQLException ignore) {}
              if(stmtRec != null) try { stmtRec.close(); } catch(SQLException ignore) {}
              if(connRec != null) try { connRec.close(); } catch(SQLException ignore) {}
            }
          %>
        </div>
      </div>
    </div>
    
    <!-- Badge utilisateur flottant -->
    <div class="user-badge">
      <i class="fas fa-user"></i>
      <%= firstname %> <%= lastname %>
    </div>

  </div>
  
  <script src="../public/js/1jquery.js"></script>
  <script src="../public/js/2bootstrap.bundle.min.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      // Contrôle du formulaire
      const form = document.getElementById('reclamationForm');
      const submitBtn = document.getElementById('submitBtn');
      const textarea = document.getElementById('libelle');
      const charCount = document.getElementById('charCount');
      
      // Compteur de caractères
      textarea.addEventListener('input', function() {
        const count = this.value.length;
        charCount.textContent = count;
        
        if (count < 10) {
          charCount.style.color = '#dc3545';
        } else {
          charCount.style.color = '#28a745';
        }
        
        // Adapter la hauteur du textarea
        this.style.height = 'auto';
        this.style.height = (this.scrollHeight) + 'px';
      });
      
      // Validation et soumission du formulaire
      form.addEventListener('submit', function(e) {
        const libelle = textarea.value.trim();
        const sujet = document.getElementById('sujet').value;
        
        if(libelle.length < 10) {
          e.preventDefault();
          alert('Veuillez fournir une description détaillée de votre réclamation (minimum 10 caractères).');
          textarea.focus();
          return;
        }
        
        if(!sujet) {
          e.preventDefault();
          alert('Veuillez sélectionner un sujet pour votre réclamation.');
          document.getElementById('sujet').focus();
          return;
        }
        
        // Animation de chargement
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Envoi en cours...';
        submitBtn.classList.add('btn-loading');
      });
      
      // Initialiser le compteur de caractères
      charCount.textContent = textarea.value.length;
    });
  </script>
</body>
</html>