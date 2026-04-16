<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
   Integer idadmin = (Integer) session.getAttribute("idadmin");
   String firstname = (String) session.getAttribute("firstname");
   String lastname = (String) session.getAttribute("lastname");
   String fullName = (String) session.getAttribute("fullname");
   String role = (String) session.getAttribute("role");
   if(idadmin == null || role == null || !"soleil".equals(role)) {
      response.sendRedirect("../login.jsp");
      return;
   }
   
   // Si une erreur ou un message d'inscription est renvoyé
   boolean openRegistration = false;
   if (request.getAttribute("registrationError") != null || request.getAttribute("registerSuccess") != null) {
       openRegistration = true;
   }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Gestion des Clients</title>
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
    
    /* Actions Container */
    .actions-container {
      display: flex;
      justify-content: center;
      margin-bottom: 20px;
    }
    
    .btn-action {
      background-color: var(--primary-color);
      color: var(--white);
      padding: 10px 20px;
      border: none;
      border-radius: 30px;
      font-size: 16px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.3s ease;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }
    
    .btn-action:hover {
      background-color: #00574b;
      transform: translateY(-2px);
      box-shadow: 0 6px 8px rgba(0, 0, 0, 0.15);
    }
    
    .btn-action i {
      margin-right: 8px;
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
    .data-table {
      width: 100%;
      border-collapse: collapse;
      border-spacing: 0;
    }
    
    .data-table th {
      background-color: var(--primary-color);
      color: var(--white);
      padding: 12px 15px;
      text-align: left;
      font-weight: 600;
      position: relative;
    }
    
    .data-table th:first-child {
      border-top-left-radius: 8px;
    }
    
    .data-table th:last-child {
      border-top-right-radius: 8px;
    }
    
    .data-table tbody tr {
      border-bottom: 1px solid #f0f0f0;
      transition: background-color 0.3s;
    }
    
    .data-table tbody tr:hover {
      background-color: rgba(0, 102, 82, 0.05);
    }
    
    .data-table td {
      padding: 12px 15px;
      vertical-align: middle;
    }
    
    /* Row Actions */
    .row-actions {
      display: flex;
      justify-content: center;
      gap: 5px;
    }
    
    .btn-row {
      background-color: var(--primary-color);
      color: var(--white);
      border: none;
      border-radius: 5px;
      padding: 6px 12px;
      font-size: 14px;
      cursor: pointer;
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
    }
    
    .btn-row i {
      margin-right: 5px;
    }
    
    .btn-row.btn-edit {
      background-color: var(--info-color);
    }
    
    .btn-row.btn-edit:hover {
      background-color: #138496;
    }
    
    .btn-row.btn-delete {
      background-color: var(--danger-color);
    }
    
    .btn-row.btn-delete:hover {
      background-color: #c82333;
    }
    
    /* Modal Styles */
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
      position: relative;
      background-color: var(--white);
      margin: 10% auto;
      padding: 25px;
      max-width: 500px;
      width: 95%;
      border-radius: 10px;
      box-shadow: 0 5px 20px rgba(0, 0, 0, 0.2);
      animation: slideIn 0.3s ease;
    }
    
    @keyframes slideIn {
      from { transform: translateY(-30px); opacity: 0; }
      to { transform: translateY(0); opacity: 1; }
    }
    
    .modal-header {
      margin-bottom: 20px;
      padding-bottom: 15px;
      border-bottom: 1px solid var(--border-color);
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    
    .modal-title {
      font-size: 20px;
      color: var(--primary-color);
      margin: 0;
      display: flex;
      align-items: center;
    }
    
    .modal-title i {
      margin-right: 10px;
    }
    
    .modal-close {
      font-size: 24px;
      font-weight: bold;
      color: #aaa;
      background: none;
      border: none;
      cursor: pointer;
      transition: color 0.3s;
    }
    
    .modal-close:hover {
      color: var(--text-color);
    }
    
    .modal-body {
      margin-bottom: 20px;
    }
    
    .form-group {
      margin-bottom: 15px;
    }
    
    .form-label {
      display: block;
      margin-bottom: 5px;
      font-weight: 600;
      color: var(--primary-color);
    }
    
    .form-control {
      width: 100%;
      padding: 10px 15px;
      border: 1px solid var(--border-color);
      border-radius: 5px;
      font-size: 16px;
      transition: all 0.3s ease;
    }
    
    .form-control:focus {
      border-color: var(--primary-color);
      box-shadow: 0 0 0 3px rgba(0, 102, 82, 0.1);
      outline: none;
    }
    
    .modal-footer {
      display: flex;
      justify-content: flex-end;
      gap: 10px;
      padding-top: 15px;
      border-top: 1px solid var(--border-color);
    }
    
    .btn-modal {
      padding: 10px 20px;
      border: none;
      border-radius: 5px;
      font-size: 16px;
      cursor: pointer;
      transition: all 0.3s ease;
    }
    
    .btn-modal.btn-cancel {
      background-color: #f8f9fa;
      color: var(--text-color);
    }
    
    .btn-modal.btn-cancel:hover {
      background-color: #e9ecef;
    }
    
    .btn-modal.btn-submit {
      background-color: var(--primary-color);
      color: var(--white);
    }
    
    .btn-modal.btn-submit:hover {
      background-color: #00574b;
    }
    
    .btn-modal.btn-delete {
      background-color: var(--danger-color);
      color: var(--white);
    }
    
    .btn-modal.btn-delete:hover {
      background-color: #c82333;
    }
    
    /* Alerts */
    .alert {
      padding: 15px;
      margin-bottom: 20px;
      border-radius: 5px;
      display: flex;
      align-items: center;
    }
    
    .alert i {
      margin-right: 10px;
      font-size: 18px;
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
    
    /* Animation */
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
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
      
      .row-actions {
        flex-direction: column;
      }
      
      .btn-row {
        width: 100%;
        justify-content: center;
        margin-bottom: 5px;
      }
    }
  </style>
</head>
<body>
  <%@ include file="../mead.jsp" %>
  
  <div class="container">
    <div class="page-header">
      <h1 class="page-title">Gestion des Clients</h1>
    </div>
    
    <% if (request.getAttribute("registerSuccess") != null) { %>
      <div class="alert alert-success">
        <i class="fas fa-check-circle"></i> <%= request.getAttribute("registerSuccess") %>
      </div>
    <% } %>
    
    <% if (request.getAttribute("registrationError") != null) { %>
      <div class="alert alert-danger">
        <i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("registrationError") %>
      </div>
    <% } %>
    
    <div class="actions-container">
      <button class="btn-action" id="btnAddClient">
        <i class="fas fa-user-plus"></i> Ajouter un client
      </button>
    </div>
    
    <div class="table-container">
      <div class="search-container">
        <h2 class="section-title"><i class="fas fa-users"></i> Liste des clients</h2>
        <input type="text" id="searchInput" class="search-input" placeholder="Rechercher un client...">
      </div>
      
      <div class="table-responsive">
        <table id="dataTable" class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Prénom</th>
              <th>Nom</th>
              <th>Username</th>
              <th>Email</th>
              <th>Téléphone</th>
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
              String sql = "SELECT iduser, firstname, lastname, username, email, number FROM users";
              stmt = conn.prepareStatement(sql);
              rs = stmt.executeQuery();
              
              while(rs.next()){
                int id = rs.getInt("iduser");
                String fname = rs.getString("firstname");
                String lname = rs.getString("lastname");
                String uname = rs.getString("username");
                String email = rs.getString("email") != null ? rs.getString("email") : "";
                String number = rs.getString("number");
          %>
            <tr>
              <td><%= id %></td>
              <td><%= fname %></td>
              <td><%= lname %></td>
              <td><%= uname %></td>
              <td><%= email %></td>
              <td><%= number %></td>
              <td>
                <div class="row-actions">
                  <button class="btn-row btn-edit" onclick="openModifyModal('<%= id %>', '<%= fname %>', '<%= lname %>', '<%= uname %>', '<%= email %>', '<%= number %>')">
                    <i class="fas fa-edit"></i> Modifier
                  </button>
                  <button class="btn-row btn-delete" onclick="openDeleteModal('<%= id %>')">
                    <i class="fas fa-trash-alt"></i> Supprimer
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
    
    <!-- Modal: Ajouter un client -->
    <div class="modal" id="modalAddClient">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title"><i class="fas fa-user-plus"></i> Ajouter un client</h3>
          <button type="button" class="modal-close" id="closeAddClient">&times;</button>
        </div>
        <div class="modal-body">
          <form id="addClientForm" action="ajouterClient.jsp" method="post" onsubmit="return validateForm()">
            <div class="form-group">
              <label for="add_firstname" class="form-label">Prénom</label>
              <input type="text" id="add_firstname" name="firstname" class="form-control" required>
            </div>
            <div class="form-group">
              <label for="add_lastname" class="form-label">Nom</label>
              <input type="text" id="add_lastname" name="lastname" class="form-control" required>
            </div>
            <div class="form-group">
              <label for="add_username" class="form-label">Nom d'utilisateur</label>
              <input type="text" id="add_username" name="username" class="form-control" required>
            </div>
            <div class="form-group">
              <label for="add_email" class="form-label">Email</label>
              <input type="email" id="add_email" name="email" class="form-control" required>
            </div>
            <div class="form-group">
              <label for="add_password" class="form-label">Mot de passe</label>
              <input type="password" id="add_password" name="password" class="form-control" required>
            </div>
            <div class="form-group">
              <label for="add_confirm_password" class="form-label">Confirmer le mot de passe</label>
              <input type="password" id="add_confirm_password" name="confirm_password" class="form-control" required>
            </div>
            <div class="form-group">
              <label for="add_number" class="form-label">Téléphone</label>
              <input type="text" id="add_number" name="number" class="form-control" required>
            </div>
          </form>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-modal btn-cancel" id="cancelAddClient">Annuler</button>
          <button type="button" class="btn-modal btn-submit" onclick="submitAddForm()">Enregistrer</button>
        </div>
      </div>
    </div>
    
    <!-- Modal: Modifier un client -->
<div class="modal" id="modalModifyClient">
  <div class="modal-content">
    <div class="modal-header">
      <h3 class="modal-title"><i class="fas fa-user-edit"></i> Modifier le client</h3>
      <button type="button" class="modal-close" id="closeModifyClient">&times;</button>
    </div>
    <div class="modal-body">
      <form id="modifyClientForm" action="modifierClient.jsp" method="post">
        <input type="hidden" name="iduser" id="modify_iduser">
        <div class="form-group">
          <label for="modify_firstname" class="form-label">Prénom</label>
          <input type="text" id="modify_firstname" name="firstname" class="form-control" required>
        </div>
        <div class="form-group">
          <label for="modify_lastname" class="form-label">Nom</label>
          <input type="text" id="modify_lastname" name="lastname" class="form-control" required>
        </div>
        <div class="form-group">
          <label for="modify_username" class="form-label">Nom d'utilisateur</label>
          <input type="text" id="modify_username" name="username" class="form-control" required>
        </div>
        <div class="form-group">
          <label for="modify_email" class="form-label">Email</label>
          <input type="email" id="modify_email" name="email" class="form-control" required>
        </div>
        <div class="form-group">
          <label for="modify_number" class="form-label">Téléphone</label>
          <input type="text" id="modify_number" name="number" class="form-control" required>
        </div>
        <div class="form-group">
          <label for="modify_password" class="form-label">Nouveau mot de passe (laisser vide pour conserver l'actuel)</label>
          <input type="password" id="modify_password" name="password" class="form-control">
        </div>
        <div class="form-group">
          <label for="modify_confirm_password" class="form-label">Confirmer le nouveau mot de passe</label>
          <input type="password" id="modify_confirm_password" name="confirm_password" class="form-control">
        </div>
      </form>
    </div>
    <div class="modal-footer">
      <button type="button" class="btn-modal btn-cancel" id="cancelModifyClient">Annuler</button>
      <button type="button" class="btn-modal btn-submit" onclick="submitModifyForm()">Enregistrer</button>
    </div>
  </div>
</div>
    
    <!-- Modal: Supprimer un client -->
    <div class="modal" id="modalDeleteClient">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title"><i class="fas fa-trash-alt"></i> Confirmer la suppression</h3>
          <button type="button" class="modal-close" id="closeDeleteClient">&times;</button>
        </div>
        <div class="modal-body">
          <p>Êtes-vous sûr de vouloir supprimer ce client ? Cette action est irréversible.</p>
          <form id="deleteClientForm" action="supprimerClient.jsp" method="get">
            <input type="hidden" name="iduser" id="delete_iduser">
          </form>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-modal btn-cancel" id="cancelDeleteClient">Annuler</button>
          <button type="button" class="btn-modal btn-delete" onclick="document.getElementById('deleteClientForm').submit()">Supprimer</button>
        </div>
      </div>
    </div>
    
  </div>
  
  <!-- Scripts -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
  <script>
    // Initialisation de DataTables avec configuration
    $(document).ready(function() {
      const table = $('#dataTable').DataTable({
        "paging": true,
        "ordering": true,
        "info": true,
        "searching": true,
        "language": {
          "url": "//cdn.datatables.net/plug-ins/1.10.25/i18n/French.json"
        },
        "dom": '<"top"f>rt<"bottom"lip><"clear">',
        "pageLength": 10,
        "lengthMenu": [[5, 10, 25, 50, -1], [5, 10, 25, 50, "Tous"]]
      });
      
      // Cacher la recherche par défaut et utiliser notre champ de recherche personnalisé
      $('.dataTables_filter').hide();
      
      // Lier notre champ de recherche personnalisé à DataTables
      $('#searchInput').on('keyup', function() {
        table.search($(this).val()).draw();
      });
    });
    function submitModifyForm() {
    // Vérification si un nouveau mot de passe a été saisi
    var password = document.getElementById('modify_password').value;
    var confirmPassword = document.getElementById('modify_confirm_password').value;
    
    // Si un mot de passe a été saisi, vérifier qu'il correspond à la confirmation
    if (password !== '') {
      if (password !== confirmPassword) {
        alert('Les nouveaux mots de passe ne correspondent pas.');
        return false;
      }
    } else {
      // Si aucun mot de passe n'est saisi, s'assurer que la confirmation est également vide
      if (confirmPassword !== '') {
        alert('Les champs de mot de passe doivent être tous les deux remplis ou tous les deux vides.');
        return false;
      }
    }
    
    // Soumission du formulaire si tout est valide
    document.getElementById('modifyClientForm').submit();
  }
    // Validation des mots de passe
    function validateForm() {
      var password = document.getElementById('add_password').value;
      var confirmPassword = document.getElementById('add_confirm_password').value;
      
      if (password !== confirmPassword) {
        alert('Les mots de passe ne correspondent pas.');
        return false;
      }
      return true;
    }
    
    // Soumettre le formulaire d'ajout avec validation
    function submitAddForm() {
      if (validateForm()) {
        document.getElementById('addClientForm').submit();
      }
    }
    
    // Gestion des modals
    // Modal Ajouter Client
    const btnAddClient = document.getElementById('btnAddClient');
    const modalAddClient = document.getElementById('modalAddClient');
    const closeAddClient = document.getElementById('closeAddClient');
    const cancelAddClient = document.getElementById('cancelAddClient');
    
    btnAddClient.addEventListener('click', () => {
      modalAddClient.style.display = 'block';
    });
    
    closeAddClient.addEventListener('click', () => {
      modalAddClient.style.display = 'none';
    });
    
    cancelAddClient.addEventListener('click', () => {
      modalAddClient.style.display = 'none';
    });
    
    // Modal Modifier Client
    const modalModifyClient = document.getElementById('modalModifyClient');
    const closeModifyClient = document.getElementById('closeModifyClient');
    const cancelModifyClient = document.getElementById('cancelModifyClient');
    
    function openModifyModal(id, fname, lname, uname, email, number) {
      document.getElementById('modify_iduser').value = id;
      document.getElementById('modify_firstname').value = fname;
      document.getElementById('modify_lastname').value = lname;
      document.getElementById('modify_username').value = uname;
      document.getElementById('modify_email').value = email;
      document.getElementById('modify_number').value = number;
      modalModifyClient.style.display = 'block';
    }
    
    closeModifyClient.addEventListener('click', () => {
      modalModifyClient.style.display = 'none';
    });
    
    cancelModifyClient.addEventListener('click', () => {
      modalModifyClient.style.display = 'none';
    });
    
    // Modal Supprimer Client
    const modalDeleteClient = document.getElementById('modalDeleteClient');
    const closeDeleteClient = document.getElementById('closeDeleteClient');
    const cancelDeleteClient = document.getElementById('cancelDeleteClient');
    
    function openDeleteModal(id) {
      document.getElementById('delete_iduser').value = id;
      modalDeleteClient.style.display = 'block';
    }
    
    closeDeleteClient.addEventListener('click', () => {
      modalDeleteClient.style.display = 'none';
    });
    
    cancelDeleteClient.addEventListener('click', () => {
      modalDeleteClient.style.display = 'none';
    });
    
    // Fermer les modals si clic en dehors
    window.addEventListener('click', function(event) {
      if (event.target == modalAddClient) {
        modalAddClient.style.display = 'none';
      }
      if (event.target == modalModifyClient) {
        modalModifyClient.style.display = 'none';
      }
      if (event.target == modalDeleteClient) {
        modalDeleteClient.style.display = 'none';
      }
    });
    
    // Si une erreur ou un message d'inscription a été renvoyé, ouvrir le modal d'ajout
    <% if (openRegistration) { %>
      document.addEventListener('DOMContentLoaded', function() {
        modalAddClient.style.display = 'block';
      });
    <% } %>
  </script>
</body>
</html>