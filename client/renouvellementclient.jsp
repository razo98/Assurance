<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Récupération de l'ID du client (session)
    Integer iduser = (Integer) session.getAttribute("iduser");
    String fullName = (String) session.getAttribute("fullname");
    if (iduser == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    // Date d'aujourd'hui pour la comparaison
    LocalDate today = LocalDate.now();
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <title>Renouvellement d'Assurance</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="../public/css/1bootstrap.min.css" rel="stylesheet">
    <link href="../public/css/2dataTables.bootstrap5.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="../css/global.css">
    <style>
      /* Variables de couleurs */
      :root {
        --primary-color: #006652;
        --primary-dark: #004d3d;
        --secondary-color: #FF8C00;
        --text-color: #333;
        --text-light: #666;
        --border-color: #ddd;
        --success-color: #28a745;
        --danger: #dc3545;
        --gray-medium: #adb5bd;
      }
    
      .renewal-container {
        background-color: rgba(255, 255, 255, 0.9);
        border-radius: 10px;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        padding: 1.5rem;
        margin-top: 2rem;
      }
      
      .page-title {
        text-align: center;
        margin-bottom: 1.5rem;
        color: var(--primary-color);
        font-weight: 600;
      }
      
      .table-responsive {
        margin-top: 1rem;
      }
      
      .renewal-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.9rem;
      }
      
      .renewal-table th {
        background-color: var(--primary-color);
        color: white;
        padding: 0.75rem;
        text-align: left;
        font-weight: 600;
        white-space: nowrap;
      }
      
      .renewal-table td {
        padding: 0.75rem;
        border-bottom: 1px solid #e0e0e0;
        vertical-align: middle;
      }
      
      .renewal-table tbody tr:hover {
        background-color: rgba(0, 115, 92, 0.05);
      }
      
      .btn-action {
        padding: 0.4rem 0.8rem;
        font-size: 0.85rem;
        margin: 0.2rem;
        border-radius: 5px;
        border: none;
        cursor: pointer;
        transition: all 0.3s ease;
        display: inline-flex;
        align-items: center;
        justify-content: center;
      }
      
      .btn-renew {
        background-color: var(--primary-color);
        color: white;
      }
      
      .btn-renew:hover {
        background-color: var(--primary-dark);
      }
      
      .btn-renew:disabled {
        background-color: var(--gray-medium);
        cursor: not-allowed;
      }
      
      .card-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        gap: 1.5rem;
        margin-bottom: 2rem;
      }
      
      .insurance-card {
        background-color: white;
        border-radius: 10px;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        overflow: hidden;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        position: relative;
      }
      
      .insurance-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.15);
      }
      
      .insurance-header {
        background-color: var(--primary-color);
        color: white;
        padding: 1rem;
        font-weight: 600;
        font-size: 1.1rem;
        display: flex;
        align-items: center;
        justify-content: space-between;
      }
      
      .insurance-body {
        padding: 1.25rem;
      }
      
      .insurance-info {
        margin-bottom: 1rem;
      }
      
      .insurance-label {
        color: var(--text-light);
        font-size: 0.85rem;
        margin-bottom: 0.25rem;
      }
      
      .insurance-value {
        font-weight: 600;
        color: var(--text-color);
        font-size: 1rem;
        margin-bottom: 0.75rem;
      }
      
      .dates-container {
        display: flex;
        justify-content: space-between;
        margin-bottom: 1.25rem;
      }
      
      .date-block {
        text-align: center;
        flex: 1;
        padding: 0.5rem;
        background-color: #f8f9fa;
        border-radius: 5px;
      }
      
      .date-block + .date-block {
        margin-left: 0.5rem;
      }
      
      .date-label {
        font-size: 0.75rem;
        color: var(--text-light);
        margin-bottom: 0.25rem;
      }
      
      .date-value {
        font-weight: 600;
        color: var(--text-color);
      }
      
      .expiry-indicator {
        position: absolute;
        top: 1rem;
        right: 1rem;
        font-size: 0.75rem;
        padding: 0.25rem 0.5rem;
        border-radius: 20px;
      }
      
      .expiry-active {
        background-color: rgba(40, 167, 69, 0.15);
        color: #155724;
      }
      
      .expiry-expiring {
        background-color: rgba(255, 193, 7, 0.15);
        color: #856404;
      }
      
      .expiry-expired {
        background-color: rgba(220, 53, 69, 0.15);
        color: #721c24;
      }
      
      .info-block {
        display: flex;
        align-items: center;
        margin-bottom: 0.75rem;
      }
      
      .info-block i {
        font-size: 1rem;
        color: var(--primary-color);
        margin-right: 0.75rem;
        width: 20px;
        text-align: center;
      }
      
      .card-footer {
        padding: 1rem;
        background-color: #f8f9fa;
        text-align: center;
      }
      
      .message-block {
        text-align: center;
        padding: 2rem;
        color: var(--text-light);
      }
      
      .message-block i {
        font-size: 3rem;
        margin-bottom: 1rem;
        color: var(--primary-color);
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
        z-index: 900;
      }
      
      .user-badge i {
        margin-right: 8px;
        font-size: 1.2rem;
      }
      
      /* Style pour le modal de renouvellement ajusté */
      .modal {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5);
        z-index: 1000;
      }
      
      .modal-content {
        background-color: white;
        margin: 7% auto;
        width: 90%;
        max-width: 550px;
        border-radius: 0;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        position: relative;
      }
      
      .modal-header {
        padding: 15px;
        background-color: #006652;
        color: white;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      .modal-title {
        margin: 0;
        font-size: 18px;
        font-weight: normal;
      }
      
      .close-modal {
        background: none;
        border: none;
        color: white;
        font-size: 24px;
        cursor: pointer;
      }
      
      .modal-body {
        padding: 20px;
      }
      
      /* Style pour la section de prix */
      .prix-container {
        background-color: #006652;
        color: white;
        padding: 15px;
        text-align: center;
      }
      
      .prix-label {
        font-size: 14px;
        display: block;
        margin-bottom: 5px;
      }
      
      .prix-montant {
        font-size: 22px;
        font-weight: bold;
      }
      
      .prix-devise {
        font-size: 16px;
      }
      
      /* Style pour les formulaires simplifiés */
      .simple-form-group {
        margin-bottom: 20px;
      }
      
      .simple-form-group label {
        display: block;
        margin-bottom: 8px;
        font-weight: normal;
        color: #333;
      }
      
      .simple-input, .simple-select {
        width: 100%;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 4px;
        background-color: #f5f5f5;
      }
      
      .simple-input:focus, .simple-select:focus {
        outline: none;
        border-color: #006652;
      }
      
      .simple-input[readonly] {
        background-color: #eee;
        cursor: not-allowed;
      }
      
      /* Bouton de calcul */
      .btn-calculate {
        background-color: #006652;
        color: white;
        padding: 10px 20px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 14px;
        margin-top: 10px;
      }
      
      .btn-calculate:hover {
        background-color: #004d3d;
      }
      
      /* Section de paiement */
      .payment-form {
        padding: 20px;
        border-top: 1px solid #eee;
      }
      
      .payment-title {
        font-size: 16px;
        color: #006652;
        margin-bottom: 20px;
        font-weight: 500;
      }
      
      /* Boutons d'action */
      .modal-actions-simple {
        display: flex;
        padding: 15px;
        border-top: 1px solid #eee;
      }
      
      .btn-edit-simple, .btn-confirm-simple {
        flex: 1;
        padding: 10px;
        border: none;
        cursor: pointer;
        font-size: 14px;
      }
      
      .btn-edit-simple {
        background-color: #f5f5f5;
        color: #333;
        margin-right: 5px;
      }
      
      .btn-confirm-simple {
        background-color: #4CAF50;
        color: white;
        margin-left: 5px;
      }
      
      /* Indicateur de chargement */
      .loading {
        display: none;
        text-align: center;
        padding: 20px;
      }
      
      .loading i {
        color: #006652;
        font-size: 24px;
        animation: spin 1s linear infinite;
      }
      
      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
      
      .text-center {
        text-align: center;
      }
      
      /* Responsive */
      @media (max-width: 768px) {
        .renewal-container {
          padding: 1rem;
        }
        
        .card-grid {
          grid-template-columns: 1fr;
        }
        
        .modal-content {
          width: 95%;
          margin: 3% auto;
        }
      }
    </style>
</head>
<body>
  <div class="container">
    <%@ include file="../me.jsp" %>
    <br>
    <div class="renewal-container">
      <h2 class="page-title">Renouvellement d'Assurance</h2>
      
      <div class="card-grid">
        <%
          try {
            Class.forName("org.mariadb.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
            
            String sql = "SELECT a.id_assurance, a.date_debut, a.date_fin, a.puissance, a.nombre_mois, a.prix_ttc, " +
                        "a.immatriculation, a.id_voiture, a.id_categorie, a.valider, a.energie, a.quartier, a.nombre_place, " +
                        "v.marque, c.genre " +
                        "FROM assurance a " +
                        "JOIN voiture v ON a.id_voiture = v.id_voiture " +
                        "JOIN categorie c ON a.id_categorie = c.id_categorie " +
                        "WHERE a.iduser = ? and resiliation=0 and suspension=0 and valider=1 " +
                        "ORDER BY a.date_fin DESC";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, iduser);
            rs = stmt.executeQuery();
            
            boolean hasData = false;
            
            while(rs.next()){
              hasData = true;
              int assuranceId = rs.getInt("id_assurance");
              String dateDebut = rs.getString("date_debut");
              String dateFin = rs.getString("date_fin");
              int puissance = rs.getInt("puissance");
              int mois = rs.getInt("nombre_mois");
              double prixTtc = rs.getDouble("prix_ttc");
              String immatriculation = rs.getString("immatriculation");
              String marque = rs.getString("marque");
              int id_voiture = rs.getInt("id_voiture");
              int id_categorie = rs.getInt("id_categorie");
              int valider = rs.getInt("valider");
              int energie = rs.getInt("energie");
              String quartier = rs.getString("quartier");
              int nombre_place = rs.getInt("nombre_place");
              String genre = rs.getString("genre");
              
              // Convertir la date de fin en LocalDate
              LocalDate finDate = LocalDate.parse(dateFin);
              
              // Calculer si l'assurance est expirée ou expire bientôt
              boolean isExpired = finDate.isBefore(today);
              boolean isExpiringSoon = finDate.isAfter(today) && finDate.isBefore(today.plusDays(300));
              
              String expiryClass = isExpired ? "expiry-expired" : (isExpiringSoon ? "expiry-expiring" : "expiry-active");
              String expiryText = isExpired ? "Expirée" : (isExpiringSoon ? "Expire bientôt" : "Active");
              
              // Vérifier si le renouvellement est possible
              boolean canRenew = valider == 1 && (isExpired || isExpiringSoon);
        %>
        <div class="insurance-card">
          <div class="insurance-header">
            <%= marque %> - <%= immatriculation %>
            <span class="expiry-indicator <%= expiryClass %>"><%= expiryText %></span>
          </div>
          <div class="insurance-body">
            <div class="dates-container">
              <div class="date-block">
                <div class="date-label">Date de début</div>
                <div class="date-value"><%= dateDebut %></div>
              </div>
              <div class="date-block">
                <div class="date-label">Date de fin</div>
                <div class="date-value"><%= dateFin %></div>
              </div>
            </div>
            
            <div class="info-block">
              <i class="fas fa-tachometer-alt"></i>
              <span>Puissance: <%= puissance %> CV</span>
            </div>
            
            <div class="info-block">
              <i class="fas fa-calendar-alt"></i>
              <span>Durée: <%= mois %> mois</span>
            </div>
            
            <div class="info-block">
              <i class="fas fa-money-bill-wave"></i>
              <span>Prix: <%= String.format("%.2f", prixTtc) %> FCFA</span>
            </div>
          </div>
          
          <div class="card-footer">
            <button class="btn-action btn-renew <%= canRenew ? "" : "disabled" %>" 
                    onclick="openRenewModal(
                        '<%= assuranceId %>', 
                        '<%= dateFin %>', 
                        '<%= marque %>', 
                        '<%= immatriculation %>', 
                        '<%= puissance %>',
                        '<%= id_voiture %>',
                        '<%= id_categorie %>',
                        '<%= iduser %>',
                        '<%= energie %>',
                        '<%= quartier %>',
                        '<%= nombre_place %>',
                        '<%= genre %>'
                    )" <%= canRenew ? "" : "disabled" %>>
              <i class="fas fa-sync-alt"></i> Renouveler
            </button>
          </div>
        </div>
        <%
            }
            
            if (!hasData) {
        %>
        <div class="message-block" style="grid-column: 1 / -1;">
          <i class="fas fa-info-circle"></i>
          <p>Vous n'avez pas encore d'assurance à renouveler. <a href="devis.jsp">Demander un devis</a> pour commencer.</p>
        </div>
        <%
            }
          } catch(Exception e) {
            out.println("Erreur : " + e.getMessage());
          } finally {
            if(rs != null) try { rs.close(); } catch(SQLException ignore) {}
            if(stmt != null) try { stmt.close(); } catch(SQLException ignore) {}
            if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
          }
        %>
      </div>
    </div>
    
    <!-- Modal de renouvellement avec design ajusté -->
    <div class="modal" id="renewModal">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title">Renouveler l'Assurance</h3>
          <button type="button" class="close-modal" id="closeRenewModal">&times;</button>
        </div>
        
        <div id="loading" class="loading">
          <i class="fas fa-spinner"></i> Calcul du prix en cours...
        </div>
        
        <!-- Section pour afficher le prix (après calcul) -->
        <div id="recapContent"></div>
        
        <div class="modal-body">
          <form id="renewForm">
            <!-- Champs cachés pour les informations -->
            <input type="hidden" name="old_assurance_id" id="old_assurance_id">
            <input type="hidden" name="id_voiture" id="id_voiture">
            <input type="hidden" name="id_categorie" id="id_categorie">
            <input type="hidden" name="iduser" id="iduser">
            <input type="hidden" name="heure" id="heure">
            <input type="hidden" name="immatriculation" id="immatriculation">
            <input type="hidden" name="puissance" id="puissance">
            <input type="hidden" name="quartier" id="quartier">
            <input type="hidden" name="nombre_place" id="nombre_place">
            <input type="hidden" name="energie" id="energie">
            <input type="hidden" name="genre_vehicule" id="genre_vehicule">
            <input type="hidden" name="resiliation" id="resiliation" value="0">
            <input type="hidden" name="suspension" id="suspension" value="0">
            <input type="hidden" name="valider" id="valider" value="0">
            <input type="hidden" name="clients" id="clients" value="<%= fullName %>">
            <input type="hidden" name="telephone" id="telephone" value="<%= session.getAttribute("telephone") %>">
            <input type="hidden" id="prix_calcule" name="prix_calcule" value="">

            <!-- Date de début -->
            <div class="simple-form-group">
              <label>Date de début (nouvelle)</label>
              <input type="date" id="new_start_date" name="new_start_date" class="simple-input" required>
            </div>
            
            <!-- Durée -->
            <div class="simple-form-group">
              <label>Durée</label>
              <select id="new_months" name="new_months" class="simple-select" required>
                <option value="" disabled selected>Sélectionner la durée</option>
                <option value="3">3 mois</option>
                <option value="6">6 mois</option>
                <option value="12">12 mois</option>
              </select>
            </div>
            
            <div class="text-center">
              <button type="button" onclick="calculatePrice()" class="btn-calculate">
                <i class="fas fa-calculator"></i> Calculer le prix
              </button>
            </div>
          </form>
        </div>
        
        <!-- Formulaire de paiement - affiché après calcul du prix -->
        <div id="paymentSection" style="display: none;">
          <div class="payment-form">
            <h4 class="payment-title">
              <i class="fas fa-money-check-alt"></i> Informations de Paiement
            </h4>
            
            <div class="simple-form-group">
              <label>Numéro de Paiement</label>
              <input type="text" id="numero_paiement" class="simple-input" value="+22799897842" readonly>
            </div>
            
            <div class="simple-form-group">
              <label>Mode de Paiement</label>
              <select id="mode_paiement" class="simple-select">
                <option value="" disabled selected>Sélectionnez un mode de paiement</option>
                <option value="MyNita">MyNita</option>
                <option value="AmanaTa">AmanaTa</option>
                <option value="ZeynaCash">ZeynaCash</option>
                <option value="AlizzaMoney">AlizzaMoney</option>
              </select>
            </div>
            
            <div class="simple-form-group">
              <label>Code de Transaction</label>
              <input type="text" id="code_transaction" class="simple-input" placeholder="Entrez votre code de transaction">
            </div>
          </div>
          
          <div class="modal-actions-simple">
            <button id="editBtn" class="btn-edit-simple">
              <i class="fas fa-edit"></i> Modifier
            </button>
            <button id="confirmBtn" class="btn-confirm-simple">
              <i class="fas fa-check"></i> Confirmer
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
  
  <script src="../public/js/1jquery.js"></script>
  <script src="../public/js/2bootstrap.bundle.min.js"></script>
  <script>
    // Fonction d'ouverture du modal de renouvellement
function openRenewModal(assuranceId, dateFin, marque, immatriculation, puissance, id_voiture, id_categorie, userID, energie, quartier, nombre_place, genre) {
  // Masquer la section de paiement
  document.getElementById("paymentSection").style.display = "none";
  
  // Réinitialiser le conteneur de récapitulatif
  document.getElementById("recapContent").innerHTML = "";
  
  // Remplir les champs cachés
  document.getElementById("old_assurance_id").value = assuranceId;
  document.getElementById("id_voiture").value = id_voiture;
  document.getElementById("id_categorie").value = id_categorie;
  document.getElementById("puissance").value = puissance;
  document.getElementById("iduser").value = userID;
  document.getElementById("immatriculation").value = immatriculation;
  document.getElementById("energie").value = energie;
  document.getElementById("quartier").value = quartier || "Non spécifié";
  document.getElementById("nombre_place").value = nombre_place || "5";
  document.getElementById("genre_vehicule").value = genre;
  document.getElementById("heure").value = new Date().toTimeString().split(' ')[0];
  
  // Pré-remplir la date de début et définir la date minimale
  const today = new Date().toISOString().split('T')[0];
  const dateFinObj = new Date(dateFin);
  const dateFinStr = dateFinObj.toISOString().split('T')[0];
  
  // Définir la date minimale comme la date de fin de l'ancienne assurance
  document.getElementById("new_start_date").min = dateFinStr;
  
  // Pré-remplir la date de début avec la date de fin de l'ancienne assurance
  document.getElementById("new_start_date").value = dateFinStr;
  
  
  // Réinitialiser le champ de sélection de mois
  document.getElementById("new_months").selectedIndex = 0;
  
  // Afficher le modal
  document.getElementById("renewModal").style.display = "block";
}
    
    // Fonction pour calculer le prix et afficher le résultat
    async function calculatePrice() {
      const energie = document.getElementById("energie").value;
      const puissance = document.getElementById("puissance").value;
      const nombre_mois = document.getElementById("new_months").value;
      const genre = document.getElementById("genre_vehicule").value;
      
      // Vérifier que la durée est sélectionnée
      if (!nombre_mois) {
        alert("Veuillez sélectionner la durée de l'assurance");
        return;
      }
      
      // Afficher l'indicateur de chargement
      document.getElementById("loading").style.display = "block";
      
      try {
        // Appeler la fonction de calcul du prix
        const result = await calculerPrix(energie, puissance, nombre_mois, genre);
        
        // Masquer l'indicateur de chargement
        document.getElementById("loading").style.display = "none";
        
        if (!result.success) {
          console.error('Erreur lors du calcul du prix:', result.message);
          alert('Impossible de calculer le prix: ' + result.message);
          return;
        }
        
        const prix = result.prix;
        
        // Mettre à jour le champ caché avec le prix calculé
        document.getElementById("prix_calcule").value = prix;
        
        // Créer et insérer le conteneur de prix
        const prixContainer = document.createElement("div");
        prixContainer.className = "prix-container";
        prixContainer.innerHTML = `
          <span class="prix-label">Prix à payer</span>
          <span class="prix-montant">${prix.toLocaleString()}</span>
          <span class="prix-devise">FCFA</span>
        `;
        
        // Insérer le conteneur de prix
        const recapContent = document.getElementById("recapContent");
        recapContent.innerHTML = "";
        recapContent.appendChild(prixContainer);
        
        // Afficher la section de paiement
        document.getElementById("paymentSection").style.display = "block";
        
      } catch (error) {
        // Masquer l'indicateur de chargement en cas d'erreur
        document.getElementById("loading").style.display = "none";
        console.error('Erreur:', error);
        alert('Une erreur est survenue lors du calcul du prix: ' + error.message);
      }
    }
    
    // Fonction pour appeler calculprix.jsp
    async function calculerPrix(energie, puissance, nombre_mois, genre) {
      return new Promise((resolve, reject) => {
        // Vérifier que tous les paramètres existent et ne sont pas vides
        if (!energie || !puissance || !nombre_mois || !genre) {
          reject(new Error("Tous les paramètres sont obligatoires"));
          return;
        }
        
        // Créer une instance XMLHttpRequest
        const xhr = new XMLHttpRequest();
        
        // Construction de l'URL avec les paramètres
        const url = "calculprix.jsp" + 
                  "?energie=" + encodeURIComponent(energie) + 
                  "&puissance=" + encodeURIComponent(puissance) + 
                  "&nombre_mois=" + encodeURIComponent(nombre_mois) + 
                  "&genre=" + encodeURIComponent(genre);
        
        // Configurer la requête
        xhr.open('GET', url, true);
        
        // Définir le type de réponse attendu
        xhr.responseType = 'json';
        
        // Gérer la réponse
        xhr.onload = function() {
          if (xhr.status === 200) {
            if (xhr.response) {
              resolve(xhr.response);
            } else {
              try {
                // Si la réponse n'est pas automatiquement parsée
                const jsonResponse = JSON.parse(xhr.responseText);
                resolve(jsonResponse);
              } catch (e) {
                reject(new Error("Erreur lors de l'analyse de la réponse JSON"));
              }
            }
          } else {
            reject(new Error(`Erreur HTTP: ${xhr.status}`));
          }
        };
        
        // Gérer les erreurs réseau
        xhr.onerror = function() {
          reject(new Error("Erreur réseau lors de la requête"));
        };
        
        // Envoyer la requête
        xhr.send();
      });
    }
    
    // Fermeture du modal
    document.getElementById("closeRenewModal").addEventListener('click', function() {
      document.getElementById("renewModal").style.display = 'none';
    });
    
    // Fermer le modal si clic en dehors
    window.addEventListener('click', function(event) {
      var modal = document.getElementById("renewModal");
      if (event.target == modal) {
        modal.style.display = 'none';
      }
    });
    
    // Bouton "Modifier" du récapitulatif
    document.getElementById("editBtn").addEventListener("click", function() {
      // Masquer la section de paiement
      document.getElementById("paymentSection").style.display = "none";
      
      // Supprimer le conteneur de prix
      const prixContainer = document.querySelector(".prix-container");
      if (prixContainer) {
        prixContainer.remove();
      }
    });
    
    // Bouton "Confirmer" du récapitulatif
    document.getElementById("confirmBtn").addEventListener("click", function() {
      // Récupérer les valeurs des champs de paiement
      const numeroPaiement = document.getElementById('numero_paiement');
      const modePaiement = document.getElementById('mode_paiement');
      const codeTransaction = document.getElementById('code_transaction');
      const prixCalcule = document.getElementById('prix_calcule');
      
      // Validation des champs de paiement
      if (modePaiement.value === "" || modePaiement.selectedIndex <= 0) {
        alert("Veuillez sélectionner un mode de paiement.");
        return;
      }
      
      if (!codeTransaction.value.trim()) {
        alert("Veuillez saisir le code de transaction.");
        return;
      }
      
      // Créer un nouveau formulaire avec toutes les données
      const finalForm = document.createElement("form");
      finalForm.method = "post";
      finalForm.action = "traitenementrenouclient.jsp";
      
      // Ajouter tous les champs du formulaire de renouvellement
      const renewFormData = new FormData(document.getElementById('renewForm'));
      for (const [key, value] of renewFormData.entries()) {
        const hiddenInput = document.createElement("input");
        hiddenInput.type = "hidden";
        hiddenInput.name = key;
        hiddenInput.value = value;
        finalForm.appendChild(hiddenInput);
      }
      
      // Ajouter les champs de paiement
      const paiementFields = [
        { name: 'numero_paiement', value: numeroPaiement.value },
        { name: 'mode_paiement', value: modePaiement.value },
        { name: 'code_transaction', value: codeTransaction.value }
      ];
      
      // Ajouter le prix calculé
      if (prixCalcule && prixCalcule.value) {
        paiementFields.push({ name: 'prix', value: prixCalcule.value });
      }
      
      paiementFields.forEach(field => {
        const hiddenInput = document.createElement("input");
        hiddenInput.type = "hidden";
        hiddenInput.name = field.name;
        hiddenInput.value = field.value;
        finalForm.appendChild(hiddenInput);
      });
      
      // Ajouter les dates
      const newStartDate = document.getElementById('new_start_date').value;
      const newMonths = document.getElementById('new_months').value;
      
      const dateDebutInput = document.createElement("input");
      dateDebutInput.type = "hidden";
      dateDebutInput.name = "date_debut";
      dateDebutInput.value = newStartDate;
      finalForm.appendChild(dateDebutInput);
      
      const nombreMoisInput = document.createElement("input");
      nombreMoisInput.type = "hidden";
      nombreMoisInput.name = "nombre_mois";
      nombreMoisInput.value = newMonths;
      finalForm.appendChild(nombreMoisInput);
      
      // Soumettre le formulaire
      document.body.appendChild(finalForm);
      finalForm.submit();
    });
  </script>
</body>
</html>