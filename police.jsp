<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="fr">
<head>
    <title>Vérification d'Assurance - Police du Niger</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    
    <style>
        body {
            background: linear-gradient(135deg, #1e3c72, #2a5298);
            min-height: 100vh;
            font-family: Arial, sans-serif;
        }
        
        .police-header {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-bottom: 2px solid rgba(255, 255, 255, 0.2);
            padding: 1rem 0;
            margin-bottom: 2rem;
        }
        
        .police-badge {
            width: 60px;
            height: 60px;
            background: #FFD700;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: #1e3c72;
            font-weight: bold;
        }
        
        .search-container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 2rem;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            margin-bottom: 2rem;
        }
        
        .search-input {
            border: 3px solid #1e3c72;
            border-radius: 15px;
            padding: 1rem 1.5rem;
            font-size: 1.2rem;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 2px;
        }
        
        .search-input:focus {
            border-color: #FFD700;
            box-shadow: 0 0 20px rgba(255, 215, 0, 0.3);
        }
        
        .btn-search {
            background: linear-gradient(135deg, #1e3c72, #2a5298);
            border: none;
            border-radius: 15px;
            padding: 1rem 2rem;
            font-size: 1.1rem;
            font-weight: bold;
            color: white;
            transition: all 0.3s ease;
        }
        
        .btn-search:hover {
            background: linear-gradient(135deg, #2a5298, #1e3c72);
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
            color: white;
        }
        
        .result-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.3);
            overflow: hidden;
            margin-bottom: 2rem;
        }
        
        .result-header {
            background: linear-gradient(135deg, #27ae60, #2ecc71);
            color: white;
            padding: 1.5rem;
            text-align: center;
        }
        
        .result-header.expired {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
        }
        
        .result-header.pending {
            background: linear-gradient(135deg, #f39c12, #e67e22);
        }
        
        .result-header.invalid {
            background: linear-gradient(135deg, #95a5a6, #7f8c8d);
        }
        
        .status-badge {
            font-size: 1.5rem;
            padding: 0.5rem 1.5rem;
            border-radius: 25px;
            font-weight: bold;
            display: inline-block;
            margin-top: 0.5rem;
        }
        
        .status-valid {
            background: #27ae60;
            color: white;
        }
        
        .status-expired {
            background: #e74c3c;
            color: white;
        }
        
        .status-pending {
            background: #f39c12;
            color: white;
        }
        
        .status-invalid {
            background: #95a5a6;
            color: white;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            padding: 2rem;
        }
        
        .info-item {
            background: #f8f9fa;
            border-radius: 15px;
            padding: 1.5rem;
            border-left: 5px solid #1e3c72;
        }
        
        .info-label {
            font-weight: bold;
            color: #1e3c72;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 0.5rem;
        }
        
        .info-value {
            font-size: 1.2rem;
            color: #2c3e50;
            font-weight: 600;
        }
        
        .no-result {
            text-align: center;
            padding: 3rem;
            color: white;
        }
        
        .no-result i {
            font-size: 4rem;
            margin-bottom: 1rem;
            color: rgba(255, 255, 255, 0.7);
        }
        
        .emergency-info {
            background: rgba(231, 76, 60, 0.1);
            border: 2px solid #e74c3c;
            border-radius: 15px;
            padding: 1.5rem;
            margin-top: 1rem;
        }
        
        .valid-info {
            background: rgba(39, 174, 96, 0.1);
            border: 2px solid #27ae60;
            border-radius: 15px;
            padding: 1.5rem;
            margin-top: 1rem;
        }
        
        .print-btn {
            background: linear-gradient(135deg, #8e44ad, #9b59b6);
            border: none;
            border-radius: 12px;
            padding: 0.75rem 1.5rem;
            color: white;
            font-weight: bold;
        }
        
        .print-btn:hover {
            background: linear-gradient(135deg, #9b59b6, #8e44ad);
            color: white;
            transform: translateY(-1px);
        }
        
        @media print {
            body {
                background: white !important;
            }
            
            .no-print {
                display: none !important;
            }
            
            .result-card {
                box-shadow: none !important;
                border: 2px solid #000 !important;
            }
        }
    </style>
</head>
<body>
    <!-- En-tête Police -->
    <div class="police-header">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-2">
                    <div class="police-badge">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                </div>
                <div class="col-md-8">
                    <h2 class="text-white mb-0">
                        <i class="fas fa-car me-3"></i>SYSTÈME DE VÉRIFICATION D'ASSURANCE
                    </h2>
                    <p class="text-white-50 mb-0">Police Nationale du Niger - Contrôle Routier</p>
                </div>
                <div class="col-md-2 text-end">
                    <div class="text-white-50">
                        <%= new SimpleDateFormat("dd/MM/yyyy HH:mm", Locale.FRENCH).format(new java.util.Date()) %>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="container">
        <!-- Formulaire de recherche -->
        <div class="search-container">
            <form method="POST" class="row align-items-end">
                <div class="col-md-8">
                    <label class="form-label fw-bold text-primary">
                        <i class="fas fa-id-card me-2"></i>NUMÉRO D'IMMATRICULATION
                    </label>
                    <input type="text" 
                           name="immatriculation" 
                           class="form-control search-input" 
                           placeholder="Ex: BA-1234, BP-5678"
                           value="<%= request.getParameter("immatriculation") != null ? request.getParameter("immatriculation") : "" %>"
                           required>
                    <small class="text-muted">Entrez le numéro complet d'immatriculation du véhicule</small>
                </div>
                <div class="col-md-4">
                    <button type="submit" class="btn btn-search w-100">
                        <i class="fas fa-search me-2"></i>VÉRIFIER
                    </button>
                </div>
            </form>
        </div>
        
        <%
            String immatriculation = request.getParameter("immatriculation");
            if (immatriculation != null && !immatriculation.trim().isEmpty()) {
                Connection conn = null;
                PreparedStatement stmt = null;
                ResultSet rs = null;
                
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
                    
                    // Requête pour récupérer toutes les informations de l'assurance
                    String query = "SELECT a.*, v.marque, c.genre, u.firstname as client_firstname, u.lastname as client_lastname, " +
                                  "ad.firstname as agent_firstname, ad.lastname as agent_lastname " +
                                  "FROM assurance a " +
                                  "LEFT JOIN voiture v ON a.id_voiture = v.id_voiture " +
                                  "LEFT JOIN categorie c ON a.id_categorie = c.id_categorie " +
                                  "LEFT JOIN users u ON a.iduser = u.iduser " +
                                  "LEFT JOIN admins ad ON a.matricule = ad.matricule " +
                                  "WHERE a.immatriculation = ? " +
                                  "ORDER BY a.date_debut DESC LIMIT 1";
                    
                    stmt = conn.prepareStatement(query);
                    stmt.setString(1, immatriculation.trim().toUpperCase());
                    rs = stmt.executeQuery();
                    
                    if (rs.next()) {
                        // Récupération des informations de statut
                        java.sql.Date dateFin = rs.getDate("date_fin");
                        java.sql.Date dateAujourdhui = new java.sql.Date(System.currentTimeMillis());
                        String status = rs.getString("status");
                        boolean valider = rs.getBoolean("valider");
                        boolean suspension = rs.getBoolean("suspension");
                        boolean resiliation = rs.getBoolean("resiliation");
                        
                        // Vérification complète du statut
                        boolean isExpired = dateFin.before(dateAujourdhui);
                        boolean isResilie = resiliation || "Resilié".equals(status);
                        boolean isSuspended = suspension;
                        boolean isNotValidated = !valider;
                        boolean isPending = "En attente".equals(status);
                        
                        // Une assurance est VALIDE seulement si :
                        // - Elle est validée (valider = 1)
                        // - Elle n'est pas suspendue (suspension = 0)  
                        // - Elle n'est pas résiliée (resiliation = 0)
                        // - Elle n'est pas expirée (date_fin > aujourd'hui)
                        boolean isValid = valider && !suspension && !resiliation && !isExpired && !"En attente".equals(status);
                        
                        // Déterminer le statut principal pour l'affichage
                        String headerClass, statusClass, statusText;
                        
                        if (isValid) {
                            headerClass = "";
                            statusClass = "status-valid";
                            statusText = "ASSURANCE VALIDE";
                        } else if (isResilie) {
                            headerClass = "expired";
                            statusClass = "status-expired";
                            statusText = "ASSURANCE RÉSILIÉE";
                        } else if (isSuspended) {
                            headerClass = "expired";
                            statusClass = "status-expired";
                            statusText = "ASSURANCE SUSPENDUE";
                        } else if (isExpired) {
                            headerClass = "expired";
                            statusClass = "status-expired";
                            statusText = "ASSURANCE EXPIRÉE";
                        } else if (isNotValidated || isPending) {
                            headerClass = "pending";
                            statusClass = "status-pending";
                            statusText = "ASSURANCE EN ATTENTE";
                        } else {
                            headerClass = "invalid";
                            statusClass = "status-invalid";
                            statusText = "STATUT INVALIDE";
                        }
        %>
        
        <!-- Résultat de la recherche -->
        <div class="result-card" id="resultCard">
            <div class="result-header <%= headerClass %>">
                <h3><i class="fas fa-car me-3"></i><%= immatriculation.toUpperCase() %></h3>
                <div class="status-badge <%= statusClass %>">
                    <i class="fas fa-<%= isValid ? "check-circle" : (isExpired || isResilie ? "times-circle" : "clock") %> me-2"></i>
                    <%= statusText %>
                </div>
            </div>
            
            <div class="info-grid">
                <!-- Informations du véhicule -->
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-car me-2"></i>Véhicule</div>
                    <div class="info-value"><%= rs.getString("marque") != null ? rs.getString("marque") : "Non spécifié" %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-tag me-2"></i>Catégorie</div>
                    <div class="info-value"><%= rs.getString("genre") != null ? rs.getString("genre").toUpperCase() : "Non spécifié" %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-tachometer-alt me-2"></i>Puissance</div>
                    <div class="info-value"><%= rs.getInt("puissance") %> CV</div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-users me-2"></i>Places</div>
                    <div class="info-value"><%= rs.getInt("nombre_place") %> places</div>
                </div>
                
                <!-- Informations du propriétaire -->
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-user me-2"></i>Propriétaire</div>
                    <div class="info-value">
                        <%= rs.getString("clients") != null ? rs.getString("clients") : 
                            (rs.getString("client_firstname") + " " + rs.getString("client_lastname")) %>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-phone me-2"></i>Téléphone</div>
                    <div class="info-value">
                        <%= rs.getString("telephone") != null && !rs.getString("telephone").equals("null") ? 
                            rs.getString("telephone") : "Non renseigné" %>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-map-marker-alt me-2"></i>Quartier</div>
                    <div class="info-value"><%= rs.getString("quartier") != null ? rs.getString("quartier") : "Non spécifié" %></div>
                </div>
                
                <!-- Informations de l'assurance -->
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-calendar-alt me-2"></i>Date de début</div>
                    <div class="info-value">
                        <%= new SimpleDateFormat("dd/MM/yyyy", Locale.FRENCH).format(rs.getDate("date_debut")) %>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-calendar-times me-2"></i>Date d'expiration</div>
                    <div class="info-value">
                        <%= new SimpleDateFormat("dd/MM/yyyy", Locale.FRENCH).format(rs.getDate("date_fin")) %>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-money-bill-wave me-2"></i>Prime TTC</div>
                    <div class="info-value">
                        <%= String.format("%,.0f", rs.getDouble("prix_ttc")) %> FCFA
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-clock me-2"></i>Durée</div>
                    <div class="info-value"><%= rs.getInt("nombre_mois") %> mois</div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-check-circle me-2"></i>Validation</div>
                    <div class="info-value">
                        <span class="badge bg-<%= valider ? "success" : "danger" %>">
                            <i class="fas fa-<%= valider ? "check" : "times" %> me-1"></i>
                            <%= valider ? "VALIDÉE" : "NON VALIDÉE" %>
                        </span>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-pause-circle me-2"></i>Suspension</div>
                    <div class="info-value">
                        <span class="badge bg-<%= suspension ? "warning" : "success" %>">
                            <i class="fas fa-<%= suspension ? "pause" : "play" %> me-1"></i>
                            <%= suspension ? "SUSPENDUE" : "ACTIVE" %>
                        </span>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-ban me-2"></i>Résiliation</div>
                    <div class="info-value">
                        <span class="badge bg-<%= resiliation ? "danger" : "success" %>">
                            <i class="fas fa-<%= resiliation ? "times-circle" : "check-circle" %> me-1"></i>
                            <%= resiliation ? "RÉSILIÉE" : "EN COURS" %>
                        </span>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-label"><i class="fas fa-calendar-check me-2"></i>Validité</div>
                    <div class="info-value">
                        <span class="badge bg-<%= isExpired ? "danger" : "success" %>">
                            <i class="fas fa-<%= isExpired ? "times" : "check" %> me-1"></i>
                            <%= isExpired ? "EXPIRÉE" : "VALIDE" %>
                        </span>
                    </div>
                </div>
            </div>
            
            <!-- Informations supplémentaires selon le statut -->
            <% if (isValid) { %>
            <div class="valid-info">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h5 class="text-success mb-2">
                            <i class="fas fa-check-circle me-2"></i>ASSURANCE COMPLÈTEMENT VALIDE
                        </h5>
                        <p class="mb-1">✅ <strong>Validée</strong> par MBA Niger</p>
                        <p class="mb-1">✅ <strong>Non suspendue</strong></p>
                        <p class="mb-1">✅ <strong>Non résiliée</strong></p>
                        <p class="mb-2">✅ <strong>Dans les délais</strong> (expire le <%= new SimpleDateFormat("dd/MM/yyyy", Locale.FRENCH).format(dateFin) %>)</p>
                        <p class="mb-0 fw-bold text-success">Le véhicule est légalement assuré et peut circuler.</p>
                    </div>
                    <div class="col-md-4 text-end">
                        <button class="btn print-btn no-print" onclick="window.print()">
                            <i class="fas fa-print me-2"></i>Imprimer
                        </button>
                    </div>
                </div>
            </div>
            <% } else { %>
            <div class="emergency-info">
                <h5 class="text-danger mb-2">
                    <i class="fas fa-exclamation-triangle me-2"></i>ATTENTION - ASSURANCE NON VALIDE
                </h5>
                <div class="mb-2">
                    <% if (!valider) { %>
                        <p class="mb-1">❌ <strong>Non validée</strong> par MBA Niger</p>
                    <% } %>
                    <% if (suspension) { %>
                        <p class="mb-1">❌ <strong>Suspendue</strong> - Couverture temporairement interrompue</p>
                    <% } %>
                    <% if (resiliation) { %>
                        <p class="mb-1">❌ <strong>Résiliée</strong> - Contrat annulé</p>
                    <% } %>
                    <% if (isExpired) { %>
                        <p class="mb-1">❌ <strong>Expirée</strong> le <%= new SimpleDateFormat("dd/MM/yyyy", Locale.FRENCH).format(dateFin) %></p>
                    <% } %>
                    <% if (isPending) { %>
                        <p class="mb-1">⏳ <strong>En attente</strong> de validation</p>
                    <% } %>
                </div>
                <p class="mb-0 fw-bold text-danger">
                    ⚠️ PROCÉDURE D'INFRACTION RECOMMANDÉE - Défaut d'assurance obligatoire
                </p>
            </div>
            <% } %>
        </div>
        
        <%
                    } else {
        %>
        <!-- Aucun résultat trouvé -->
        <div class="no-result">
            <i class="fas fa-search-minus"></i>
            <h3>AUCUNE ASSURANCE TROUVÉE</h3>
            <p>Aucune assurance n'a été trouvée pour l'immatriculation <strong><%= immatriculation.toUpperCase() %></strong></p>
            <div class="emergency-info mt-4">
                <h5 class="text-danger mb-2">
                    <i class="fas fa-ban me-2"></i>VÉHICULE NON ASSURÉ
                </h5>
                <p class="mb-0 fw-bold text-danger">
                    ⚠️ INFRACTION GRAVE - Défaut d'assurance obligatoire<br>
                    Procédure d'immobilisation recommandée
                </p>
            </div>
        </div>
        <%
                    }
                } catch (Exception e) {
                    out.println("<div class='alert alert-danger'>Erreur de connexion à la base de données: " + e.getMessage() + "</div>");
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                    if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
                    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
                }
            }
        %>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto-focus sur le champ de recherche
        document.addEventListener('DOMContentLoaded', function() {
            const searchInput = document.querySelector('.search-input');
            if (searchInput) {
                searchInput.focus();
            }
        });
        
        // Formatage automatique de l'immatriculation
        document.querySelector('.search-input').addEventListener('input', function(e) {
            let value = e.target.value.toUpperCase().replace(/[^A-Z0-9-]/g, '');
            e.target.value = value;
        });
        
        // Raccourci clavier Enter
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && e.target.classList.contains('search-input')) {
                e.target.form.submit();
            }
        });
    </script>
</body>
</html>