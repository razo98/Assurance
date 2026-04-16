<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Vérifier que l'agent est connecté
    Integer idadmin = (Integer) session.getAttribute("idadmin");
    String agentFullName = (String) session.getAttribute("fullname");
    String firstname = (String) session.getAttribute("firstname");
    String lastname = (String) session.getAttribute("lastname");
    String roler = (String) session.getAttribute("role");
    String matric = (String) session.getAttribute("matricule");
    if(idadmin == null || roler == null || !"soleil".equals(roler)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Récupérer le paramètre de recherche (immatriculation ou id_assurance)
    String search = request.getParameter("search");
    
    // Date d'aujourd'hui pour la comparaison
    LocalDate today = LocalDate.now();
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Renouvellement d'Assurance - Admin</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="../public/css/2dataTables.bootstrap5.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        :root {
            --primary-color: #006652;
            --primary-dark: #004d40;
            --secondary-color: #e6f3f0;
            --text-color: #333;
            --text-light: #666;
            --gray-medium: #aaa;
            --danger: #dc3545;
        }
        
        /* Styles pour la page de renouvellement agent */
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
        
        .search-section {
            background-color: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            margin-bottom: 2rem;
        }
        
        .search-title {
            color: var(--primary-color);
            margin-bottom: 1rem;
            font-size: 1.1rem;
            font-weight: 500;
        }
        
        .search-form {
            display: flex;
            gap: 1rem;
            align-items: flex-end;
        }
        
        .search-form .form-group {
            flex: 1;
            margin-bottom: 0;
        }
        
        .search-form label {
            display: block;
            margin-bottom: 0.5rem;
            color: var(--text-color);
            font-weight: 500;
        }
        
        .search-form input {
            width: 100%;
            padding: 0.5rem;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 0.9rem;
        }
        
        .btn-search {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s ease;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .btn-search:hover {
            background-color: var(--primary-dark);
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
        
        /* Modal Styles */
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
            backdrop-filter: blur(3px);
        }
        
        .modal-content {
            background-color: white;
            margin: 10% auto;
            padding: 2rem;
            width: 90%;
            max-width: 500px;
            border-radius: 8px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
            position: relative;
        }
        
        .modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .modal-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--primary-dark);
            margin: 0;
        }
        
        .close-modal {
            background: none;
            border: none;
            font-size: 1.5rem;
            line-height: 1;
            color: var(--text-light);
            cursor: pointer;
            transition: color 0.3s;
        }
        
        .close-modal:hover {
            color: var(--danger);
        }
        
        .form-group {
            margin-bottom: 1.25rem;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 0.5rem;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        
        .readonly-field {
            background-color: #e9ecef;
            cursor: not-allowed;
        }
        
        /* Réglages responsifs */
        @media (max-width: 768px) {
            .renewal-container {
                padding: 1rem;
            }
            
            .card-grid {
                grid-template-columns: 1fr;
            }
            
            .search-form {
                flex-direction: column;
                gap: 0.5rem;
            }
            
            .search-form .form-group {
                margin-bottom: 0.5rem;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../mead.jsp" %>
    
    <div class="container">
        <div class="renewal-container">
            <h2 class="page-title">Renouvellement d'Assurance (Admin)</h2>
            
            <!-- Section de recherche -->
            <div class="search-section">
                <h3 class="search-title">Rechercher une assurance</h3>
                <form method="get" action="renouAdmin.jsp" class="search-form">
                    <div class="form-group">
                        <label for="search">Immatriculation ou ID Assurance :</label>
                        <input type="text" name="search" id="search" class="form-control" placeholder="Ex: BP-5051 ou 3" value="<%= search != null ? search : "" %>" required>
                    </div>
                    <button type="submit" class="btn-action btn-renew">
                        <i class="fas fa-search"></i> Rechercher
                    </button>
                </form>
            </div>
            
            <!-- Résultats de recherche -->
            <div class="card-grid">
                <%
                    if(search != null && !search.trim().isEmpty()){
                        Connection conn = null;
                        PreparedStatement stmt = null;
                        ResultSet rs = null;
                        boolean hasData = false;
                        
                        try {
                            Class.forName("org.mariadb.jdbc.Driver");
                            conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
                            
                            // Rechercher par immatriculation ou id_assurance et rejoindre avec la table voiture pour avoir plus d'informations
                            String sql = "SELECT a.*, v.marque FROM assurance a LEFT JOIN voiture v ON a.id_voiture = v.id_voiture WHERE a.immatriculation = ? OR a.id_assurance = ?";
                            stmt = conn.prepareStatement(sql);
                            stmt.setString(1, search);
                            int searchId = 0;
                            try { searchId = Integer.parseInt(search); } catch(NumberFormatException nfe) {}
                            stmt.setInt(2, searchId);
                            rs = stmt.executeQuery();
                            
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
                                int valider = rs.getInt("valider");
                                int resiliation= rs.getInt("resiliation");
                                int suspension= rs.getInt("suspension");
                                
                                // Convertir la date de fin en LocalDate
                                LocalDate finDate = LocalDate.parse(dateFin);
                                
                                // Calculer si l'assurance est expirée ou expire bientôt
                                boolean isExpired = finDate.isBefore(today);
                                boolean isExpiringSoon = finDate.isAfter(today) && finDate.isBefore(today.plusDays(360));
                                
                                String expiryClass = isExpired ? "expiry-expired" : (isExpiringSoon ? "expiry-expiring" : "expiry-active");
                                String expiryText = isExpired ? "Expirée" : (isExpiringSoon ? "Expire bientôt" : "Active");
                                
                                // Vérifier si le renouvellement est possible
                                boolean canRenew = valider == 1 && resiliation == 0 && suspension ==0 && (isExpired || isExpiringSoon);
                %>
                <div class="insurance-card">
                    <div class="insurance-header">
                        <%= marque != null ? marque : "Véhicule" %> - <%= immatriculation %>
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
                            <i class="fas fa-hashtag"></i>
                            <span>ID Assurance: <%= assuranceId %></span>
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
                            <span>Prix: <%= String.format("%.2f", prixTtc) %> €</span>
                        </div>
                        
                        <div class="info-block">
                            <i class="fas fa-check-circle"></i>
                            <span>Statut: <%= valider == 1 ? "Payé" : "Non payé" %></span>
                        </div>
                    </div>
                    
                    <div class="card-footer">
                        <button class="btn-action btn-renew <%= canRenew ? "" : "disabled" %>" 
                                onclick="openRenewModal(
                                    '<%= assuranceId %>', 
                                    '<%= immatriculation %>', 
                                    '<%= dateFin %>'
                                )" <%= canRenew ? "" : "disabled" %>>
                            <i class="fas fa-sync-alt"></i> Renouveler
                        </button>
                    </div>
                </div>
                <%
                            }
                            
                            if(!hasData) {
                %>
                <div class="message-block" style="grid-column: 1 / -1;">
                    <i class="fas fa-info-circle"></i>
                    <p>Aucune assurance trouvée pour "<%= search %>". Veuillez vérifier l'immatriculation ou l'ID d'assurance.</p>
                </div>
                <%
                            }
                        } catch(Exception e) {
                            out.println("<div class='message-block' style='grid-column: 1 / -1;'>");
                            out.println("<i class='fas fa-exclamation-triangle'></i>");
                            out.println("<p>Erreur : " + e.getMessage() + "</p>");
                            out.println("</div>");
                        } finally {
                            if(rs != null) try { rs.close(); } catch(SQLException ignore) {}
                            if(stmt != null) try { stmt.close(); } catch(SQLException ignore) {}
                            if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
                        }
                    } else {
                %>
                <div class="message-block" style="grid-column: 1 / -1;">
                    <i class="fas fa-search"></i>
                    <p>Entrez une immatriculation ou un ID d'assurance pour commencer la recherche.</p>
                </div>
                <%
                    }
                %>
            </div>
        </div>
    </div>
    
    <!-- Modal de renouvellement -->
    <div class="modal" id="renewModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">Renouveler l'Assurance</h3>
                <button type="button" class="close-modal" id="closeRenewModal">&times;</button>
            </div>
            <form action="traitementrenouadmin.jsp" method="post">
                <!-- Champs cachés pour les informations importantes -->
                <input type="hidden" name="id_assurance" id="modal_id_assurance">
                
                <!-- Affichage en lecture seule des informations non modifiables -->
                <div class="form-group">
                    <label for="modal_immat">Immatriculation</label>
                    <input type="text" class="form-control readonly-field" name="immatriculation" id="modal_immat" readonly>
                </div>
                
                <!-- Champs modifiables -->
                <div class="form-group">
                    <label for="modal_new_date">Nouvelle Date de Début</label>
                    <input type="date" class="form-control" name="new_date_debut" id="modal_new_date" required>
                </div>
                
                <div class="form-group">
                    <label for="modal_nb_mois">Nombre de Mois</label>
                    <select class="form-control" name="new_nombre_mois" id="modal_nb_mois" required>
                        <option value="" disabled selected>-- Sélectionner --</option>
                        <option value="3">3 mois</option>
                        <option value="6">6 mois</option>
                        <option value="12">12 mois</option>
                    </select>
                </div>
                
                <div style="text-align: right;">
                    <button type="submit" class="btn-action btn-renew" style="font-size: 1rem; padding: 0.5rem 1rem;">
                        <i class="fas fa-sync-alt"></i> Renouveler
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- JavaScript pour la gestion de la page -->
    <script>
        // Fonction d'ouverture du modal de renouvellement
        function openRenewModal(assuranceId, immatriculation, dateFin) {
            document.getElementById("modal_id_assurance").value = assuranceId;
            document.getElementById("modal_immat").value = immatriculation;
            
            // Convertir la date de fin en format YYYY-MM-DD pour le champ date
            const today = new Date().toISOString().split("T")[0];
            const dateFinDate = new Date(dateFin);
            const formattedDateFin = dateFinDate.toISOString().split("T")[0];
            
            // Date minimale est soit aujourd'hui soit la date de fin
            const minDate = formattedDateFin < today ? today : formattedDateFin;
            
            document.getElementById("modal_new_date").min = minDate;
            document.getElementById("modal_new_date").value = minDate;
            
            // Afficher le modal
            document.getElementById("renewModal").style.display = "block";
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
    </script>
</body>
</html>