<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
%>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Gestion des Marques</title>
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
      max-width: 1200px;
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

    
    <div class="actions-container">
      <button class="btn-action" id="btnAddVoiture">
        <i class="fas fa-car-alt"></i> Ajouter une marque
      </button>
    </div>
    
    <div class="table-container">
      <div class="search-container">
        <h2 class="section-title"><i class="fas fa-car"></i> Liste des marques</h2>
        <input type="text" id="searchInput" class="search-input" placeholder="Rechercher une marque...">
      </div>
      
      <div class="table-responsive">
        <table id="dataTable" class="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Marque</th>
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
              String sql = "SELECT * FROM voiture";
              stmt = conn.prepareStatement(sql);
              rs = stmt.executeQuery();
              
              while(rs.next()){
                int id_voiture = rs.getInt("id_voiture");
                String marque = rs.getString("marque");
          %>
            <tr>
              <td><%= id_voiture %></td>
              <td><%= marque %></td>
              <td>
                <div class="row-actions">
                  <button class="btn-row btn-edit" onclick="openModifyVoiture('<%= id_voiture %>', '<%= marque %>')">
                    <i class="fas fa-edit"></i> Modifier
                  </button>
                  <button class="btn-row btn-delete" onclick="openDeleteVoiture('<%= id_voiture %>')">
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
    
    <!-- Modal: Ajouter une voiture -->
    <div class="modal" id="modalAddVoiture">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title"><i class="fas fa-car-alt"></i> Ajouter une marque</h3>
          <button type="button" class="modal-close" id="closeAddVoiture">&times;</button>
        </div>
        <div class="modal-body">
          <form id="addVoitureForm" action="traitementVoitures.jsp" method="post">
            <div class="form-group">
              <label for="add_marque" class="form-label">Nom de la marque</label>
              <input type="text" id="add_marque" name="marque" class="form-control" required>
            </div>
          </form>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-modal btn-cancel" id="cancelAddVoiture">Annuler</button>
          <button type="button" class="btn-modal btn-submit" onclick="document.getElementById('addVoitureForm').submit()">Ajouter</button>
        </div>
      </div>
    </div>
    
    <!-- Modal: Modifier une voiture -->
    <div class="modal" id="modalModifyVoiture">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title"><i class="fas fa-edit"></i> Modifier la marque</h3>
          <button type="button" class="modal-close" id="closeModifyVoiture">&times;</button>
        </div>
        <div class="modal-body">
          <form id="modifyVoitureForm" action="modifiervoiture.jsp" method="post">
            <input type="hidden" name="id_voiture" id="modify_voiture_id">
            <div class="form-group">
              <label for="modify_voiture_marque" class="form-label">Nom de la marque</label>
              <input type="text" id="modify_voiture_marque" name="marque" class="form-control" required>
            </div>
          </form>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-modal btn-cancel" id="cancelModifyVoiture">Annuler</button>
          <button type="button" class="btn-modal btn-submit" onclick="document.getElementById('modifyVoitureForm').submit()">Enregistrer</button>
        </div>
      </div>
    </div>
    
    <!-- Modal: Supprimer une voiture -->
    <div class="modal" id="modalDeleteVoiture">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title"><i class="fas fa-trash-alt"></i> Confirmer la suppression</h3>
          <button type="button" class="modal-close" id="closeDeleteVoiture">&times;</button>
        </div>
        <div class="modal-body">
          <p>Êtes-vous sûr de vouloir supprimer cette marque ? Cette action est irréversible.</p>
          <form id="deleteVoitureForm" action="supprimerVoiture.jsp" method="get">
            <input type="hidden" name="id_voiture" id="delete_voiture_id">
          </form>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-modal btn-cancel" id="cancelDeleteVoiture">Annuler</button>
          <button type="button" class="btn-modal btn-delete" onclick="document.getElementById('deleteVoitureForm').submit()">Supprimer</button>
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
    
    // Gestion des modals
    // Modal Ajouter Voiture
    const btnAddVoiture = document.getElementById('btnAddVoiture');
    const modalAddVoiture = document.getElementById('modalAddVoiture');
    const closeAddVoiture = document.getElementById('closeAddVoiture');
    const cancelAddVoiture = document.getElementById('cancelAddVoiture');
    
    btnAddVoiture.addEventListener('click', () => {
      modalAddVoiture.style.display = 'block';
    });
    
    closeAddVoiture.addEventListener('click', () => {
      modalAddVoiture.style.display = 'none';
    });
    
    cancelAddVoiture.addEventListener('click', () => {
      modalAddVoiture.style.display = 'none';
    });
    
    // Modal Modifier Voiture
    const modalModifyVoiture = document.getElementById('modalModifyVoiture');
    const closeModifyVoiture = document.getElementById('closeModifyVoiture');
    const cancelModifyVoiture = document.getElementById('cancelModifyVoiture');
    
    function openModifyVoiture(id, marque) {
      document.getElementById('modify_voiture_id').value = id;
      document.getElementById('modify_voiture_marque').value = marque;
      modalModifyVoiture.style.display = 'block';
    }
    
    closeModifyVoiture.addEventListener('click', () => {
      modalModifyVoiture.style.display = 'none';
    });
    
    cancelModifyVoiture.addEventListener('click', () => {
      modalModifyVoiture.style.display = 'none';
    });
    
    // Modal Supprimer Voiture
    const modalDeleteVoiture = document.getElementById('modalDeleteVoiture');
    const closeDeleteVoiture = document.getElementById('closeDeleteVoiture');
    const cancelDeleteVoiture = document.getElementById('cancelDeleteVoiture');
    
    function openDeleteVoiture(id) {
      document.getElementById('delete_voiture_id').value = id;
      modalDeleteVoiture.style.display = 'block';
    }
    
    closeDeleteVoiture.addEventListener('click', () => {
      modalDeleteVoiture.style.display = 'none';
    });
    
    cancelDeleteVoiture.addEventListener('click', () => {
      modalDeleteVoiture.style.display = 'none';
    });
    
    // Fermer les modals si clic en dehors
    window.addEventListener('click', function(event) {
      if (event.target == modalAddVoiture) {
        modalAddVoiture.style.display = 'none';
      }
      if (event.target == modalModifyVoiture) {
        modalModifyVoiture.style.display = 'none';
      }
      if (event.target == modalDeleteVoiture) {
        modalDeleteVoiture.style.display = 'none';
      }
    });
  </script>
</body>
</html>