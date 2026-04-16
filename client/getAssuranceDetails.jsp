<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
   Integer iduser = (Integer) session.getAttribute("iduser");
   if(iduser == null) {
      response.sendRedirect("../login.jsp");
      return;
   }
   
   // Récupérer l'ID de l'assurance
   String idAssuranceStr = request.getParameter("id");
   if(idAssuranceStr == null || idAssuranceStr.isEmpty()) {
      out.println("<div class='error-message'>ID d'assurance non spécifié.</div>");
      return;
   }
   
   int idAssurance = 0;
   try {
      idAssurance = Integer.parseInt(idAssuranceStr);
   } catch(NumberFormatException e) {
      out.println("<div class='error-message'>ID d'assurance invalide.</div>");
      return;
   }
   
   Connection conn = null;
   PreparedStatement stmt = null;
   ResultSet rs = null;
   
   try {
      Class.forName("org.mariadb.jdbc.Driver");
      conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
      
      String sql = "SELECT a.*, v.marque, c.genre, u.firstname, u.lastname, u.number " +
                  "FROM assurance a " +
                  "JOIN voiture v ON a.id_voiture = v.id_voiture " +
                  "JOIN categorie c ON a.id_categorie = c.id_categorie " +
                  "JOIN users u ON a.iduser = u.iduser " +
                  "WHERE a.id_assurance = ? AND a.iduser = ?";
      stmt = conn.prepareStatement(sql);
      stmt.setInt(1, idAssurance);
      stmt.setInt(2, iduser);
      rs = stmt.executeQuery();
      
      if(rs.next()) {
         // Récupérer les données
         String marque = rs.getString("marque");
         String genre = rs.getString("genre");
         String client = rs.getString("firstname") + " " + rs.getString("lastname");
         String telephone = rs.getString("number");
         Date dateDebut = rs.getDate("date_debut");
         Date dateFin = rs.getDate("date_fin");
         String immatriculation = rs.getString("immatriculation");
         int puissance = rs.getInt("puissance");
         int nombrePlace = rs.getInt("nombre_place");
         int energie = rs.getInt("energie");
         String energieStr = (energie == 0) ? "Essence" : "Gazoil";
         int nombreMois = rs.getInt("nombre_mois");
         double prixHt = rs.getDouble("prix_ht");
         double prixTtc = rs.getDouble("prix_ttc");
         int valider = rs.getInt("valider");
         String status = rs.getString("status");
         String quartier = rs.getString("quartier");
         String heure = rs.getString("heure");
         String agents = rs.getString("agents");
         
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
         } else {
           statusClass = "status-active";
           statusText = "Active";
         }
         
         // Formater les dates
         java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
         String formattedDateDebut = sdf.format(dateDebut);
         String formattedDateFin = sdf.format(dateFin);
%>

<style>
  /* Styles pour les détails de l'assurance */
  .assurance-details {
    font-family: 'Arial', sans-serif;
  }
  
  .detail-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid #eee;
  }
  
  .detail-title h4 {
    margin: 0 0 5px 0;
    font-size: 18px;
    font-weight: 600;
  }
  
  .status-badge {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
  }
  
  .status-active {
    background-color: rgba(40, 167, 69, 0.1);
    color: #28a745;
  }
  
  .status-pending {
    background-color: rgba(255, 193, 7, 0.1);
    color: #ffc107;
  }
  
  .status-expired {
    background-color: rgba(220, 53, 69, 0.1);
    color: #dc3545;
  }
  
  .detail-price {
    text-align: right;
  }
  
  .price-label {
    font-size: 12px;
    color: #666;
  }
  
  .price-value {
    font-size: 20px;
    font-weight: 700;
    color: #006652;
  }
  
  .detail-body {
    padding: 0;
  }
  
  .detail-columns {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
    margin-bottom: 20px;
  }
  
  .detail-column {
    flex: 1;
    min-width: 250px;
  }
  
  .section-title {
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 15px;
    color: #006652;
    display: flex;
    align-items: center;
  }
  
  .section-title i {
    margin-right: 8px;
  }
  
  .detail-table {
    width: 100%;
    border-collapse: collapse;
  }
  
  .detail-table tr {
    border-bottom: 1px solid #f0f0f0;
  }
  
  .detail-table tr:last-child {
    border-bottom: none;
  }
  
  .detail-label {
    padding: 8px 0;
    color: #666;
    font-size: 14px;
    width: 40%;
  }
  
  .detail-value {
    padding: 8px 0;
    font-weight: 600;
    font-size: 14px;
  }
  
  .detail-note {
    background-color: #f8f9fa;
    padding: 15px;
    border-radius: 8px;
    margin-bottom: 20px;
    display: flex;
    align-items: flex-start;
  }
  
  .detail-note i {
    margin-right: 10px;
    color: #006652;
    font-size: 18px;
    margin-top: 2px;
  }
  
  .detail-note p {
    margin: 0;
    font-size: 14px;
    color: #666;
    line-height: 1.5;
  }
  
  .detail-actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
  }
  
  .detail-btn {
    display: inline-flex;
    align-items: center;
    padding: 8px 15px;
    background-color: #006652;
    color: white;
    text-decoration: none;
    border-radius: 5px;
    font-size: 14px;
    transition: background-color 0.3s;
  }
  
  .detail-btn:hover {
    background-color: #00574b;
  }
  
  .detail-btn i {
    margin-right: 5px;
  }
  
  .error-message {
    background-color: #f8d7da;
    color: #721c24;
    padding: 15px;
    border-radius: 5px;
    margin-bottom: 15px;
    display: flex;
    align-items: center;
  }
  
  .error-message i {
    margin-right: 10px;
    font-size: 20px;
  }
  
  /* Adaptations responsives */
  @media (max-width: 768px) {
    .detail-header {
      flex-direction: column;
      align-items: flex-start;
    }
    
    .detail-price {
      text-align: left;
      margin-top: 10px;
    }
    
    .detail-columns {
      flex-direction: column;
    }
    
    .detail-actions {
      flex-direction: column;
    }
    
    .detail-btn {
      width: 100%;
      justify-content: center;
    }
  }
</style>

<div class="assurance-details">
  <!-- En-tête avec informations principales -->
  <div class="detail-header">
    <div class="detail-title">
      <h4><%= marque %> - <%= immatriculation %></h4>
      <span class="status-badge <%= statusClass %>"><%= statusText %></span>
    </div>
    <div class="detail-price">
      <div class="price-label">Montant total</div>
      <div class="price-value"><%= String.format("%,.2f", prixTtc) %> CFA</div>
    </div>
  </div>
  
  <!-- Corps des détails en deux colonnes -->
  <div class="detail-body">
    <div class="detail-columns">
      <!-- Colonne gauche: Informations du véhicule -->
      <div class="detail-column">
        <h5 class="section-title"><i class="fas fa-car"></i> Informations du véhicule</h5>
        <table class="detail-table">
          <tr>
            <td class="detail-label">Marque</td>
            <td class="detail-value assurance-marque"><%= marque %></td>
          </tr>
          <tr>
            <td class="detail-label">Catégorie</td>
            <td class="detail-value"><%= genre %></td>
          </tr>
          <tr>
            <td class="detail-label">Immatriculation</td>
            <td class="detail-value assurance-immatriculation"><%= immatriculation %></td>
          </tr>
          <tr>
            <td class="detail-label">Puissance</td>
            <td class="detail-value assurance-puissance"><%= puissance %></td>
          </tr>
          <tr>
            <td class="detail-label">Nombre de places</td>
            <td class="detail-value assurance-places"><%= nombrePlace %></td>
          </tr>
          <tr>
            <td class="detail-label">Énergie</td>
            <td class="detail-value assurance-energie"><%= energieStr %></td>
          </tr>
          <tr>
            <td class="detail-label">Quartier</td>
            <td class="detail-value"><%= quartier %></td>
          </tr>
        </table>
      </div>
      
      <!-- Colonne droite: Informations du contrat -->
      <div class="detail-column">
        <h5 class="section-title"><i class="fas fa-file-contract"></i> Informations du contrat</h5>
        <table class="detail-table">
          <tr>
            <td class="detail-label">ID Assurance</td>
            <td class="detail-value assurance-id"><%= idAssurance %></td>
          </tr>
          <tr>
            <td class="detail-label">Client</td>
            <td class="detail-value assurance-client"><%= client %></td>
          </tr>
          <tr>
            <td class="detail-label">Téléphone</td>
            <td class="detail-value assurance-telephone"><%= telephone %></td>
          </tr>
          <tr>
            <td class="detail-label">Date de début</td>
            <td class="detail-value assurance-date-debut"><%= formattedDateDebut %></td>
          </tr>
          <tr>
            <td class="detail-label">Date de fin</td>
            <td class="detail-value assurance-date-fin"><%= formattedDateFin %> 23:59</td>
          </tr>
          <tr>
            <td class="detail-label">Durée</td>
            <td class="detail-value assurance-mois"><%= nombreMois %></td>
          </tr>
          <tr>
            <td class="detail-label">Prix TTC</td>
            <td class="detail-value assurance-prix"><%= String.format("%,.2f", prixTtc) %></td>
          </tr>
          <tr>
            <td class="detail-label">Statut</td>
            <td class="detail-value assurance-valider"><%= valider == 1 ? "Payé" : "Non payé" %></td>
          </tr>
          <tr>
            <td class="detail-label">Agent</td>
            <td class="detail-value assurance-agent"><%= agents != null && !agents.isEmpty() ? agents : "Non assigné" %></td>
          </tr>
        </table>
      </div>
    </div>
    
    <!-- Note informative -->
    <div class="detail-note">
      <i class="fas fa-info-circle"></i>
      <p>Pour toute question concernant cette assurance, veuillez nous contacter au numéro indiqué sur votre contrat ou vous rendre dans l'une de nos agences. N'oubliez pas de renouveler votre assurance avant sa date d'expiration.</p>
    </div>
    
    <!-- Actions possibles -->
    <div class="detail-actions">
      <% if (isExpired || dateDebut.getTime() + (nombreMois * 30L * 24 * 60 * 60 * 1000) - today.getTime() < 30L * 24 * 60 * 60 * 1000) { %>
      <a href="renouvellementclient.jsp" class="detail-btn"><i class="fas fa-sync-alt"></i> Renouveler</a>
      <% } %>
      <% if (valider == 1 && !isExpired) { %>
      <a href="#" class="detail-btn" onclick="printAssurance('<%= idAssurance %>', '<%= marque %>', '<%= client %>', '<%= telephone %>', '<%= formattedDateDebut %>', '<%= formattedDateFin %>', '<%= immatriculation %>', '<%= puissance %>', '<%= nombrePlace %>', '<%= energieStr %>', '<%= nombreMois %>', '<%= prixTtc %>', 'Payé', '<%= agents %>'); return false;"><i class="fas fa-print"></i> Imprimer</a>
      <% } %>
    </div>
  </div>
</div>

<%
      } else {
%>
<div class="error-message">
  <i class="fas fa-exclamation-circle"></i>
  <div>
    <h4>Assurance introuvable</h4>
    <p>Aucune assurance trouvée avec cet identifiant ou vous n'avez pas les droits d'accès à cette assurance.</p>
  </div>
</div>
<%
      }
   } catch(Exception e) {
%>
<div class="error-message">
  <i class="fas fa-exclamation-circle"></i>
  <div>
    <h4>Erreur technique</h4>
    <p>Une erreur est survenue lors de la récupération des données: <%= e.getMessage() %></p>
  </div>
</div>
<%
   } finally {
      if(rs != null) try { rs.close(); } catch(SQLException ignore) {}
      if(stmt != null) try { stmt.close(); } catch(SQLException ignore) {}
      if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
   }
%>