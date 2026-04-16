<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
   Integer idadmin = (Integer) session.getAttribute("idadmin");
   String firstname = (String) session.getAttribute("firstname");
   String lastname = (String) session.getAttribute("lastname");
   String fullName = (String) session.getAttribute("fullname");
   String roler = (String) session.getAttribute("role");
   if(idadmin == null || roler == null || !"soleil".equals(roler)) {
      response.sendRedirect("../login.jsp");
      return;
   }
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <title>Statistiques Avancées - MBA-Niger Assurance</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
    
    <style>
        body {
            background-color: #f8f9fa;
            font-family: Arial, sans-serif;
        }
        
        .main-header {
            background: transparent;
            color: #2c3e50;
            padding: 1rem 0;
            margin-bottom: 2rem;
        }
        
        .stats-card {
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
            border: none;
            overflow: hidden;
        }
        
        .stats-card .card-header {
            background: linear-gradient(135deg, #3498db, #2980b9);
            color: white;
            font-weight: bold;
            border: none;
            padding: 1rem 1.5rem;
        }
        
        .stats-card .card-body {
            padding: 1.5rem;
        }
        
        .metric-card {
            background: linear-gradient(135deg, #9b59b6, #8e44ad);
            color: white;
            border-radius: 15px;
            padding: 1.5rem;
            text-align: center;
            margin-bottom: 1rem;
        }
        
        .metric-number {
            font-size: 2.5rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }
        
        .metric-label {
            font-size: 0.9rem;
            opacity: 0.9;
        }
        
        .chart-container {
            position: relative;
            height: 400px;
            margin: 1rem 0;
        }
        
        .btn-mba {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            border: none;
            color: white;
            border-radius: 8px;
            padding: 0.5rem 1.5rem;
        }
        
        .btn-mba:hover {
            background: linear-gradient(135deg, #c0392b, #a93226);
            border: none;
            color: white;
            transform: translateY(-1px);
        }
        
        .table-mba th {
            background: linear-gradient(135deg, #f39c12, #e67e22);
            color: white;
            border: none;
        }
        
        .table-mba td {
            border-color: #dee2e6;
        }
        
        .filter-section {
            background: white;
            border-radius: 15px;
            padding: 1.5rem;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            margin-bottom: 2rem;
        }
        
        .no-data {
            text-align: center;
            padding: 3rem;
            color: #6c757d;
        }
        
        .status-badge {
            padding: 0.25rem 0.75rem;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .status-actif {
            background-color: #d4edda;
            color: #155724;
        }
        
        .status-attente {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .status-resilie {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .print-section {
            background: white;
            border-radius: 15px;
            padding: 1.5rem;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            margin-bottom: 2rem;
        }
        
        .btn-print {
            background: linear-gradient(135deg, #27ae60, #229954);
            border: none;
            color: white;
            border-radius: 8px;
            padding: 0.5rem 1.5rem;
        }
        
        .btn-print:hover {
            background: linear-gradient(135deg, #229954, #1e8449);
            color: white;
            transform: translateY(-1px);
        }
        
        @media print {
            .no-print {
                display: none !important;
            }
            
            .print-only {
                display: block !important;
            }
            
            body {
                background: white !important;
            }
            
            .stats-card {
                box-shadow: none !important;
                border: 1px solid #ddd !important;
            }
        }
        
        .print-header {
            text-align: center;
            margin-bottom: 2rem;
            border-bottom: 2px solid #3498db;
            padding-bottom: 1rem;
        }
        
        .report-summary {
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
        }
    </style>
</head>
<body>
    <%@ include file="../mead.jsp" %>
    <br><br>
    <div class="main-header">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1 class="mb-0"><i class="fas fa-chart-line me-3"></i>Statistiques Avancées</h1>
                    <p class="mb-0 mt-2">Tableau de bord analytique des assurances automobile</p>
                </div>
                <div class="col-md-4 text-end">
                    <div class="text-muted">
                        <i class="fas fa-calendar me-2"></i>
                        <%= new SimpleDateFormat("dd MMMM yyyy", Locale.FRENCH).format(new java.util.Date()) %>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="container">
        <!-- Filtres -->
        <div class="filter-section">
            <form method="GET" id="filterForm">
                <div class="row">
                    <div class="col-md-3">
                        <label class="form-label"><i class="fas fa-calendar-alt me-2"></i>Date début</label>
                        <input type="date" class="form-control" name="dateDebut" 
                               value="<%= request.getParameter("dateDebut") != null ? request.getParameter("dateDebut") : "" %>">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label"><i class="fas fa-calendar-alt me-2"></i>Date fin</label>
                        <input type="date" class="form-control" name="dateFin" 
                               value="<%= request.getParameter("dateFin") != null ? request.getParameter("dateFin") : "" %>">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label"><i class="fas fa-filter me-2"></i>Type d'analyse</label>
                        <select class="form-select" name="typeAnalyse">
                            <option value="general" <%= "general".equals(request.getParameter("typeAnalyse")) ? "selected" : "" %>>Vue générale</option>
                            <option value="agent" <%= "agent".equals(request.getParameter("typeAnalyse")) ? "selected" : "" %>>Par agent</option>
                            <option value="categorie" <%= "categorie".equals(request.getParameter("typeAnalyse")) ? "selected" : "" %>>Par catégorie</option>
                            <option value="mois" <%= "mois".equals(request.getParameter("typeAnalyse")) ? "selected" : "" %>>Par mois</option>
                            <option value="marque" <%= "marque".equals(request.getParameter("typeAnalyse")) ? "selected" : "" %>>Par marque</option>
                        </select>
                    </div>
                    <div class="col-md-3 d-flex align-items-end">
                        <button type="submit" class="btn btn-mba w-100">
                            <i class="fas fa-search me-2"></i>Analyser
                        </button>
                    </div>
                </div>
            </form>
        </div>
        
        <!-- Section d'impression -->
        <div class="print-section no-print">
            <div class="row">
                <div class="col-md-6">
                    <h5><i class="fas fa-print me-2"></i>Impression du Rapport</h5>
                    <p class="text-muted">Générer un rapport PDF avec les statistiques et données détaillées</p>
                </div>
                <div class="col-md-6 text-end">
                    <button type="button" class="btn btn-print" onclick="generatePDFReport()">
                        <i class="fas fa-file-pdf me-2"></i>Télécharger Rapport PDF
                    </button>
                </div>
            </div>
        </div>

        <%
            // Traitement des données
            String dateDebut = request.getParameter("dateDebut");
            String dateFin = request.getParameter("dateFin");
            String typeAnalyse = request.getParameter("typeAnalyse");
            if (typeAnalyse == null) typeAnalyse = "general";
            
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            
            // Statistiques générales
            int totalAssurances = 0;
            double montantTotal = 0;
            double primeMoyenne = 0;
            int assurancesActives = 0;
            int assurancesAttente = 0;
            int assurancesResilies = 0;
            
            // Listes pour les données graphiques
            List<String> labels = new ArrayList<String>();
            List<Integer> data = new ArrayList<Integer>();
            List<Double> montants = new ArrayList<Double>();
            
            try {
                Class.forName("org.mariadb.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
                
                // Requête pour les statistiques générales avec prise en compte des remboursements
                StringBuilder queryStats = new StringBuilder();
                queryStats.append("SELECT COUNT(*) as total, ");
                queryStats.append("COALESCE(SUM(CASE WHEN resiliation = 1 AND prixremb IS NOT NULL THEN prixremb ELSE prix_ttc END), 0) as montant, ");
                queryStats.append("COALESCE(AVG(CASE WHEN resiliation = 1 AND prixremb IS NOT NULL THEN prixremb ELSE prix_ttc END), 0) as moyenne, ");
                queryStats.append("SUM(CASE WHEN status = 'Actif' THEN 1 ELSE 0 END) as actives, ");
                queryStats.append("SUM(CASE WHEN status = 'En attente' THEN 1 ELSE 0 END) as attente, ");
                queryStats.append("SUM(CASE WHEN status = 'Resilié' OR resiliation = 1 THEN 1 ELSE 0 END) as resilies ");
                queryStats.append("FROM assurance WHERE 1=1 ");
                
                List<String> params = new ArrayList<String>();
                if (dateDebut != null && !dateDebut.isEmpty()) {
                    queryStats.append("AND date_debut >= ? ");
                    params.add(dateDebut);
                }
                if (dateFin != null && !dateFin.isEmpty()) {
                    queryStats.append("AND date_debut <= ? ");
                    params.add(dateFin);
                }
                
                stmt = conn.prepareStatement(queryStats.toString());
                for (int i = 0; i < params.size(); i++) {
                    stmt.setString(i + 1, params.get(i));
                }
                
                rs = stmt.executeQuery();
                if (rs.next()) {
                    totalAssurances = rs.getInt("total");
                    montantTotal = rs.getDouble("montant");
                    primeMoyenne = rs.getDouble("moyenne");
                    assurancesActives = rs.getInt("actives");
                    assurancesAttente = rs.getInt("attente");
                    assurancesResilies = rs.getInt("resilies");
                }
                rs.close();
                stmt.close();
        %>
        
        <!-- Métriques principales -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="metric-card">
                    <div class="metric-number"><%= totalAssurances %></div>
                    <div class="metric-label"><i class="fas fa-file-contract me-2"></i>Total Assurances</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-card">
                    <div class="metric-number"><%= String.format("%,.0f", montantTotal) %></div>
                    <div class="metric-label"><i class="fas fa-money-bill-wave me-2"></i>Montant Total (FCFA)</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-card">
                    <div class="metric-number"><%= String.format("%,.0f", primeMoyenne) %></div>
                    <div class="metric-label"><i class="fas fa-calculator me-2"></i>Prime Moyenne (FCFA)</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="metric-card">
                    <div class="metric-number"><%= assurancesActives %></div>
                    <div class="metric-label"><i class="fas fa-check-circle me-2"></i>Assurances Actives</div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Graphique -->
            <div class="col-lg-8">
                <div class="stats-card">
                    <div class="card-header">
                        <i class="fas fa-chart-bar me-2"></i>
                        <%
                            if ("agent".equals(typeAnalyse)) {
                                out.print("Statistiques par Agent");
                            } else if ("categorie".equals(typeAnalyse)) {
                                out.print("Statistiques par Catégorie");
                            } else if ("mois".equals(typeAnalyse)) {
                                out.print("Évolution Mensuelle");
                            } else if ("marque".equals(typeAnalyse)) {
                                out.print("Statistiques par Marque de Véhicule");
                            } else {
                                out.print("Répartition par Statut");
                            }
                        %>
                    </div>
                    <div class="card-body">
                        <div class="chart-container">
                            <canvas id="mainChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Tableau de données -->
            <div class="col-lg-4">
                <div class="stats-card">
                    <div class="card-header">
                        <i class="fas fa-table me-2"></i>Détails
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-sm table-mba">
                                <thead>
                                    <%
                                        if ("agent".equals(typeAnalyse)) {
                                            out.print("<tr><th>Agent</th><th>Nb</th><th>Montant</th></tr>");
                                        } else if ("categorie".equals(typeAnalyse)) {
                                            out.print("<tr><th>Catégorie</th><th>Nb</th><th>%</th></tr>");
                                        } else if ("mois".equals(typeAnalyse)) {
                                            out.print("<tr><th>Mois</th><th>Nb</th><th>Montant</th></tr>");
                                        } else if ("marque".equals(typeAnalyse)) {
                                            out.print("<tr><th>Marque</th><th>Nb</th><th>%</th></tr>");
                                        } else {
                                            out.print("<tr><th>Statut</th><th>Nombre</th><th>%</th></tr>");
                                        }
                                    %>
                                </thead>
                                <tbody id="tableData">
                                    <!-- Données générées par JavaScript -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                
                <!-- Statistiques supplémentaires -->
                <div class="stats-card">
                    <div class="card-header">
                        <i class="fas fa-info-circle me-2"></i>Informations Complémentaires
                    </div>
                    <div class="card-body">
                        <div class="row text-center">
                            <div class="col-12 mb-2">
                                <span class="status-badge status-actif">Actives: <%= assurancesActives %></span>
                            </div>
                            <div class="col-12 mb-2">
                                <span class="status-badge status-attente">En attente: <%= assurancesAttente %></span>
                            </div>
                            <div class="col-12 mb-2">
                                <span class="status-badge status-resilie">Résiliées: <%= assurancesResilies %></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <%
            // Récupération des données pour le graphique
            String queryData = "";
            
            if ("agent".equals(typeAnalyse)) {
                queryData = "SELECT CONCAT(a.firstname, ' ', a.lastname) as label, COUNT(*) as count, " +
                           "SUM(CASE WHEN ass.resiliation = 1 AND ass.prixremb IS NOT NULL THEN ass.prixremb ELSE ass.prix_ttc END) as montant " +
                           "FROM assurance ass " +
                           "LEFT JOIN admins a ON ass.matricule = a.matricule " +
                           "WHERE 1=1 ";
                if (dateDebut != null && !dateDebut.isEmpty()) queryData += "AND ass.date_debut >= ? ";
                if (dateFin != null && !dateFin.isEmpty()) queryData += "AND ass.date_debut <= ? ";
                queryData += "GROUP BY a.idadmin, a.firstname, a.lastname " +
                            "HAVING COUNT(*) > 0 " +
                            "ORDER BY count DESC LIMIT 10";
            } else if ("categorie".equals(typeAnalyse)) {
                queryData = "SELECT c.genre as label, COUNT(*) as count, " +
                           "SUM(CASE WHEN ass.resiliation = 1 AND ass.prixremb IS NOT NULL THEN ass.prixremb ELSE ass.prix_ttc END) as montant " +
                           "FROM assurance ass " +
                           "LEFT JOIN categorie c ON ass.id_categorie = c.id_categorie " +
                           "WHERE 1=1 ";
                if (dateDebut != null && !dateDebut.isEmpty()) queryData += "AND ass.date_debut >= ? ";
                if (dateFin != null && !dateFin.isEmpty()) queryData += "AND ass.date_debut <= ? ";
                queryData += "GROUP BY c.id_categorie, c.genre ORDER BY count DESC";
            } else if ("marque".equals(typeAnalyse)) {
                queryData = "SELECT v.marque as label, COUNT(*) as count, " +
                           "SUM(CASE WHEN ass.resiliation = 1 AND ass.prixremb IS NOT NULL THEN ass.prixremb ELSE ass.prix_ttc END) as montant " +
                           "FROM assurance ass " +
                           "LEFT JOIN voiture v ON ass.id_voiture = v.id_voiture " +
                           "WHERE 1=1 ";
                if (dateDebut != null && !dateDebut.isEmpty()) queryData += "AND ass.date_debut >= ? ";
                if (dateFin != null && !dateFin.isEmpty()) queryData += "AND ass.date_debut <= ? ";
                queryData += "GROUP BY v.id_voiture, v.marque ORDER BY count DESC LIMIT 10";
            } else if ("mois".equals(typeAnalyse)) {
                queryData = "SELECT DATE_FORMAT(date_debut, '%Y-%m') as month, " +
                           "DATE_FORMAT(date_debut, '%M %Y') as label, " +
                           "COUNT(*) as count, " +
                           "SUM(CASE WHEN resiliation = 1 AND prixremb IS NOT NULL THEN prixremb ELSE prix_ttc END) as montant " +
                           "FROM assurance WHERE 1=1 ";
                if (dateDebut != null && !dateDebut.isEmpty()) queryData += "AND date_debut >= ? ";
                if (dateFin != null && !dateFin.isEmpty()) queryData += "AND date_debut <= ? ";
                queryData += "GROUP BY month ORDER BY month DESC LIMIT 12";
            } else {
                // general
                labels.add("Actives");
                labels.add("En attente");  
                labels.add("Résiliées");
                data.add(assurancesActives);
                data.add(assurancesAttente);
                data.add(assurancesResilies);
                montants.add((double)assurancesActives);
                montants.add((double)assurancesAttente);
                montants.add((double)assurancesResilies);
            }
            
            if (!"general".equals(typeAnalyse) && !queryData.isEmpty()) {
                stmt = conn.prepareStatement(queryData);
                int paramIndex = 1;
                if (dateDebut != null && !dateDebut.isEmpty()) {
                    stmt.setString(paramIndex++, dateDebut);
                }
                if (dateFin != null && !dateFin.isEmpty()) {
                    stmt.setString(paramIndex++, dateFin);
                }
                
                rs = stmt.executeQuery();
                while (rs.next()) {
                    String label = rs.getString("label");
                    if (label == null || label.trim().isEmpty()) {
                        label = "Non défini";
                    }
                    labels.add(label);
                    data.add(rs.getInt("count"));
                    montants.add(rs.getDouble("montant"));
                }
                rs.close();
                stmt.close();
            }
            
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>Erreur: " + e.getMessage() + "</div>");
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
                if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
            }
        %>
        
        <!-- Section cachée pour l'impression avec les données détaillées -->
        <div id="detailedDataSection" style="display: none;">
            <div class="print-header">
                <h2>MBA-Niger - Rapport de Statistiques Avancées</h2>
                <p>Généré le <%= new SimpleDateFormat("dd MMMM yyyy à HH:mm", Locale.FRENCH).format(new java.util.Date()) %></p>
                <p><strong>Type d'analyse:</strong> 
                    <%
                        if ("agent".equals(typeAnalyse)) {
                            out.print("Statistiques par Agent");
                        } else if ("categorie".equals(typeAnalyse)) {
                            out.print("Statistiques par Catégorie");
                        } else if ("mois".equals(typeAnalyse)) {
                            out.print("Évolution Mensuelle");
                        } else if ("marque".equals(typeAnalyse)) {
                            out.print("Statistiques par Marque de Véhicule");
                        } else {
                            out.print("Vue Générale - Répartition par Statut");
                        }
                    %>
                </p>
                <% if (dateDebut != null && !dateDebut.isEmpty() || dateFin != null && !dateFin.isEmpty()) { %>
                <p><strong>Période:</strong> 
                    <%= dateDebut != null && !dateDebut.isEmpty() ? "Du " + dateDebut : "Jusqu'au" %>
                    <%= dateFin != null && !dateFin.isEmpty() ? " au " + dateFin : "" %>
                </p>
                <% } %>
            </div>
            
            <div class="report-summary">
                <h4>Résumé Exécutif</h4>
                <div class="row">
                    <div class="col-md-3">
                        <strong>Total Assurances:</strong> <%= totalAssurances %>
                    </div>
                    <div class="col-md-3">
                        <strong>Montant Total:</strong> <%= String.format("%,.0f", montantTotal) %> FCFA
                    </div>
                    <div class="col-md-3">
                        <strong>Prime Moyenne:</strong> <%= String.format("%,.0f", primeMoyenne) %> FCFA
                    </div>
                    <div class="col-md-3">
                        <strong>Assurances Actives:</strong> <%= assurancesActives %>
                    </div>
                </div>
            </div>
            
            <div id="detailedAssurancesList">
                <!-- Sera rempli par JavaScript avec les données détaillées -->
            </div>
        </div>
    </div>
    
    <%
        // Récupération des données détaillées des assurances pour l'impression
        List<Map<String, Object>> detailedAssurances = new ArrayList<Map<String, Object>>();
        
        try {
            StringBuilder detailQuery = new StringBuilder();
            detailQuery.append("SELECT a.id_assurance, a.clients, a.telephone, a.immatriculation, ");
            detailQuery.append("v.marque, c.genre, a.date_debut, a.date_fin, a.status, ");
            detailQuery.append("CASE WHEN a.resiliation = 1 AND a.prixremb IS NOT NULL THEN a.prixremb ELSE a.prix_ttc END as montant_final, ");
            detailQuery.append("ad.firstname, ad.lastname ");
            detailQuery.append("FROM assurance a ");
            detailQuery.append("LEFT JOIN voiture v ON a.id_voiture = v.id_voiture ");
            detailQuery.append("LEFT JOIN categorie c ON a.id_categorie = c.id_categorie ");
            detailQuery.append("LEFT JOIN admins ad ON a.matricule = ad.matricule ");
            detailQuery.append("WHERE 1=1 ");
            
            List<String> detailParams = new ArrayList<String>();
            if (dateDebut != null && !dateDebut.isEmpty()) {
                detailQuery.append("AND a.date_debut >= ? ");
                detailParams.add(dateDebut);
            }
            if (dateFin != null && !dateFin.isEmpty()) {
                detailQuery.append("AND a.date_debut <= ? ");
                detailParams.add(dateFin);
            }
            
            detailQuery.append("ORDER BY a.date_debut DESC LIMIT 100");
            
            stmt = conn.prepareStatement(detailQuery.toString());
            for (int i = 0; i < detailParams.size(); i++) {
                stmt.setString(i + 1, detailParams.get(i));
            }
            
            rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> assurance = new HashMap<String, Object>();
                assurance.put("id", rs.getInt("id_assurance"));
                assurance.put("client", rs.getString("clients"));
                assurance.put("telephone", rs.getString("telephone"));
                assurance.put("immatriculation", rs.getString("immatriculation"));
                assurance.put("marque", rs.getString("marque"));
                assurance.put("categorie", rs.getString("genre"));
                assurance.put("dateDebut", rs.getDate("date_debut"));
                assurance.put("dateFin", rs.getDate("date_fin"));
                assurance.put("status", rs.getString("status"));
                assurance.put("montant", rs.getDouble("montant_final"));
                assurance.put("agent", rs.getString("firstname") + " " + rs.getString("lastname"));
                detailedAssurances.add(assurance);
            }
            rs.close();
            stmt.close();
            
        } catch (Exception e) {
            // Gestion des erreurs
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    %>
    
    <script>
        // Données pour le graphique
        const labels = [
            <%
                for (int i = 0; i < labels.size(); i++) {
                    out.print("\"" + labels.get(i).replace("\"", "\\\"") + "\"");
                    if (i < labels.size() - 1) out.print(",");
                }
            %>
        ];
        
        const chartData = [
            <%
                for (int i = 0; i < data.size(); i++) {
                    out.print(data.get(i));
                    if (i < data.size() - 1) out.print(",");
                }
            %>
        ];
        
        const montantData = [
            <%
                for (int i = 0; i < montants.size(); i++) {
                    out.print(montants.get(i));
                    if (i < montants.size() - 1) out.print(",");
                }
            %>
        ];
        
        const typeAnalyse = '<%= typeAnalyse %>';
        
        // Données détaillées des assurances pour l'impression
        const detailedAssurances = [
            <%
                for (int i = 0; i < detailedAssurances.size(); i++) {
                    Map<String, Object> assurance = detailedAssurances.get(i);
                    out.print("{");
                    out.print("id: " + assurance.get("id") + ",");
                    out.print("client: \"" + (assurance.get("client") != null ? assurance.get("client").toString().replace("\"", "\\\"") : "") + "\",");
                    out.print("telephone: \"" + (assurance.get("telephone") != null ? assurance.get("telephone").toString() : "") + "\",");
                    out.print("immatriculation: \"" + (assurance.get("immatriculation") != null ? assurance.get("immatriculation").toString() : "") + "\",");
                    out.print("marque: \"" + (assurance.get("marque") != null ? assurance.get("marque").toString() : "") + "\",");
                    out.print("categorie: \"" + (assurance.get("categorie") != null ? assurance.get("categorie").toString() : "") + "\",");
                    out.print("dateDebut: \"" + (assurance.get("dateDebut") != null ? assurance.get("dateDebut").toString() : "") + "\",");
                    out.print("dateFin: \"" + (assurance.get("dateFin") != null ? assurance.get("dateFin").toString() : "") + "\",");
                    out.print("status: \"" + (assurance.get("status") != null ? assurance.get("status").toString() : "") + "\",");
                    out.print("montant: " + (assurance.get("montant") != null ? assurance.get("montant") : 0) + ",");
                    out.print("agent: \"" + (assurance.get("agent") != null ? assurance.get("agent").toString().replace("\"", "\\\"") : "") + "\"");
                    out.print("}");
                    if (i < detailedAssurances.size() - 1) out.print(",");
                }
            %>
        ];
        
        // Configuration du graphique
        const ctx = document.getElementById('mainChart').getContext('2d');
        const chartConfig = {
            type: typeAnalyse === 'general' ? 'doughnut' : 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Nombre d\'assurances',
                    data: chartData,
                    backgroundColor: [
                        '#3498db', '#e74c3c', '#f39c12', '#9b59b6', 
                        '#1abc9c', '#34495e', '#e67e22', '#2ecc71',
                        '#95a5a6', '#16a085', '#8e44ad', '#d35400'
                    ],
                    borderColor: '#ffffff',
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: typeAnalyse === 'general' ? 'bottom' : 'top'
                    },
                    tooltip: {
                        callbacks: {
                            afterLabel: function(context) {
                                if (montantData[context.dataIndex] && typeAnalyse !== 'general') {
                                    return 'Montant: ' + Math.round(montantData[context.dataIndex]).toLocaleString() + ' FCFA';
                                }
                                return '';
                            }
                        }
                    }
                },
                scales: typeAnalyse !== 'general' ? {
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Nombre d\'assurances'
                        }
                    }
                } : {}
            }
        };
        
        const chart = new Chart(ctx, chartConfig);
        
        // Remplir le tableau
        const tableData = document.getElementById('tableData');
        let tableHtml = '';
        
        if (labels.length === 0) {
            tableHtml = '<tr><td colspan="3" class="text-center text-muted">Aucune donnée disponible</td></tr>';
        } else {
            for (let i = 0; i < labels.length; i++) {
                tableHtml += '<tr>';
                tableHtml += '<td>' + (labels[i].length > 15 ? labels[i].substring(0, 15) + '...' : labels[i]) + '</td>';
                tableHtml += '<td><strong>' + chartData[i] + '</strong></td>';
                
                if (typeAnalyse === 'categorie' || typeAnalyse === 'general' || typeAnalyse === 'marque') {
                    const total = chartData.reduce((a, b) => a + b, 0);
                    const percentage = total > 0 ? ((chartData[i] / total) * 100).toFixed(1) : 0;
                    tableHtml += '<td>' + percentage + '%</td>';
                } else {
                    tableHtml += '<td>' + Math.round(montantData[i]).toLocaleString() + '</td>';
                }
                
                tableHtml += '</tr>';
            }
        }
        
        tableData.innerHTML = tableHtml;
        
        // Remplir la section des données détaillées pour l'impression
        populateDetailedDataSection();
        
        // Fonction pour générer le rapport PDF
        function generatePDFReport() {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF('p', 'mm', 'a4');
            
            // Configuration de base
            const pageWidth = doc.internal.pageSize.width;
            const pageHeight = doc.internal.pageSize.height;
            const margin = 20;
            let yPosition = margin;
            
            // En-tête du rapport
            doc.setFontSize(18);
            doc.setFont('helvetica', 'bold');
            doc.text('MBA-Niger - Rapport de Statistiques', pageWidth/2, yPosition, { align: 'center' });
            yPosition += 10;
            
            doc.setFontSize(12);
            doc.setFont('helvetica', 'normal');
            const currentDate = new Date().toLocaleDateString('fr-FR', { 
                year: 'numeric', month: 'long', day: 'numeric', 
                hour: '2-digit', minute: '2-digit' 
            });
            doc.text('Généré le ' + currentDate, pageWidth/2, yPosition, { align: 'center' });
            yPosition += 15;
            
            // Type d'analyse
            doc.setFont('helvetica', 'bold');
            const analysisType = getAnalysisTypeTitle(typeAnalyse);
            doc.text('Type d\'analyse: ' + analysisType, margin, yPosition);
            yPosition += 10;
            
            // Résumé exécutif
            doc.setFontSize(14);
            doc.text('Résumé Exécutif', margin, yPosition);
            yPosition += 8;
            
            doc.setFontSize(10);
            doc.setFont('helvetica', 'normal');
            doc.text('Total Assurances: ' + <%= totalAssurances %>, margin, yPosition);
            doc.text('Montant Total: <%= String.format("%,.0f", montantTotal) %> FCFA', pageWidth/2, yPosition);
            yPosition += 6;
            doc.text('Prime Moyenne: <%= String.format("%,.0f", primeMoyenne) %> FCFA', margin, yPosition);
            doc.text('Assurances Actives: ' + <%= assurancesActives %>, pageWidth/2, yPosition);
            yPosition += 15;
            
            // Tableau des statistiques
            doc.setFontSize(12);
            doc.setFont('helvetica', 'bold');
            doc.text('Détail des Statistiques', margin, yPosition);
            yPosition += 8;
            
            // En-têtes du tableau
            doc.setFontSize(9);
            const colWidths = getColumnWidths(typeAnalyse);
            const headers = getTableHeaders(typeAnalyse);
            
            let xPosition = margin;
            doc.setFont('helvetica', 'bold');
            for (let i = 0; i < headers.length; i++) {
                doc.text(headers[i], xPosition, yPosition);
                xPosition += colWidths[i];
            }
            yPosition += 6;
            
            // Ligne de séparation
            doc.line(margin, yPosition, pageWidth - margin, yPosition);
            yPosition += 4;
            
            // Données du tableau
            doc.setFont('helvetica', 'normal');
            for (let i = 0; i < labels.length && i < 20; i++) {
                if (yPosition > pageHeight - 30) {
                    doc.addPage();
                    yPosition = margin;
                }
                
                xPosition = margin;
                const rowData = getTableRowData(i, typeAnalyse);
                for (let j = 0; j < rowData.length; j++) {
                    doc.text(String(rowData[j]), xPosition, yPosition);
                    xPosition += colWidths[j];
                }
                yPosition += 5;
            }
            
            // Nouvelle page pour les données détaillées des assurances
            if (detailedAssurances.length > 0) {
                doc.addPage();
                yPosition = margin;
                
                doc.setFontSize(14);
                doc.setFont('helvetica', 'bold');
                doc.text('Données Détaillées des Assurances', margin, yPosition);
                yPosition += 10;
                
                // En-têtes pour les assurances
                doc.setFontSize(8);
                const assuranceHeaders = ['ID', 'Client', 'Immat.', 'Marque', 'Catég.', 'Début', 'Statut', 'Montant'];
                const assuranceColWidths = [15, 35, 25, 25, 20, 25, 20, 25];
                
                xPosition = margin;
                doc.setFont('helvetica', 'bold');
                for (let i = 0; i < assuranceHeaders.length; i++) {
                    doc.text(assuranceHeaders[i], xPosition, yPosition);
                    xPosition += assuranceColWidths[i];
                }
                yPosition += 6;
                
                doc.line(margin, yPosition, pageWidth - margin, yPosition);
                yPosition += 4;
                
                // Données des assurances
                doc.setFont('helvetica', 'normal');
                for (let i = 0; i < detailedAssurances.length && i < 50; i++) {
                    if (yPosition > pageHeight - 20) {
                        doc.addPage();
                        yPosition = margin;
                    }
                    
                    const assurance = detailedAssurances[i];
                    xPosition = margin;
                    
                    const assuranceData = [
                        assurance.id,
                        assurance.client.length > 15 ? assurance.client.substring(0, 15) + '...' : assurance.client,
                        assurance.immatriculation,
                        assurance.marque || 'N/A',
                        assurance.categorie || 'N/A',
                        assurance.dateDebut.substring(0, 10),
                        assurance.status || 'N/A',
                        Math.round(assurance.montant).toLocaleString() + ' F'
                    ];
                    
                    for (let j = 0; j < assuranceData.length; j++) {
                        doc.text(String(assuranceData[j]), xPosition, yPosition);
                        xPosition += assuranceColWidths[j];
                    }
                    yPosition += 4;
                }
            }
            
            // Sauvegarde du PDF
            const fileName = 'MBA_Niger_Statistiques_' + typeAnalyse + '_' + 
                           new Date().toISOString().substring(0, 10) + '.pdf';
            doc.save(fileName);
        }
        
        function getAnalysisTypeTitle(type) {
            switch(type) {
                case 'agent': return 'Statistiques par Agent';
                case 'categorie': return 'Statistiques par Catégorie';
                case 'mois': return 'Évolution Mensuelle';
                case 'marque': return 'Statistiques par Marque de Véhicule';
                default: return 'Vue Générale - Répartition par Statut';
            }
        }
        
        function getTableHeaders(type) {
            switch(type) {
                case 'agent': return ['Agent', 'Nombre', 'Montant (FCFA)'];
                case 'categorie': return ['Catégorie', 'Nombre', 'Pourcentage'];
                case 'mois': return ['Mois', 'Nombre', 'Montant (FCFA)'];
                case 'marque': return ['Marque', 'Nombre', 'Pourcentage'];
                default: return ['Statut', 'Nombre', 'Pourcentage'];
            }
        }
        
        function getColumnWidths(type) {
            switch(type) {
                case 'agent': return [60, 30, 40];
                case 'mois': return [50, 30, 40];
                default: return [50, 30, 30];
            }
        }
        
        function getTableRowData(index, type) {
            const label = labels[index].length > 25 ? labels[index].substring(0, 25) + '...' : labels[index];
            const count = chartData[index];
            
            if (type === 'categorie' || type === 'general' || type === 'marque') {
                const total = chartData.reduce((a, b) => a + b, 0);
                const percentage = total > 0 ? ((count / total) * 100).toFixed(1) + '%' : '0%';
                return [label, count, percentage];
            } else {
                const montant = Math.round(montantData[index]).toLocaleString();
                return [label, count, montant];
            }
        }
        
        function populateDetailedDataSection() {
            const detailedSection = document.getElementById('detailedAssurancesList');
            
            if (detailedAssurances.length === 0) {
                detailedSection.innerHTML = '<p>Aucune donnée détaillée disponible.</p>';
                return;
            }
            
            let html = '<h4>Données Détaillées des Assurances (Top 100)</h4>';
            html += '<div class="table-responsive">';
            html += '<table class="table table-striped table-sm">';
            html += '<thead><tr>';
            html += '<th>ID</th><th>Client</th><th>Téléphone</th><th>Immatriculation</th>';
            html += '<th>Marque</th><th>Catégorie</th><th>Date Début</th><th>Statut</th>';
            html += '<th>Montant Final</th><th>Agent</th>';
            html += '</tr></thead><tbody>';
            
            for (let i = 0; i < detailedAssurances.length && i < 100; i++) {
                const assurance = detailedAssurances[i];
                html += '<tr>';
                html += '<td>' + assurance.id + '</td>';
                html += '<td>' + assurance.client + '</td>';
                html += '<td>' + assurance.telephone + '</td>';
                html += '<td>' + assurance.immatriculation + '</td>';
                html += '<td>' + (assurance.marque || 'N/A') + '</td>';
                html += '<td>' + (assurance.categorie || 'N/A') + '</td>';
                html += '<td>' + assurance.dateDebut + '</td>';
                html += '<td><span class="badge bg-' + getStatusColor(assurance.status) + '">' + 
                        (assurance.status || 'N/A') + '</span></td>';
                html += '<td>' + Math.round(assurance.montant).toLocaleString() + ' FCFA</td>';
                html += '<td>' + assurance.agent + '</td>';
                html += '</tr>';
            }
            
            html += '</tbody></table></div>';
            detailedSection.innerHTML = html;
        }
        
        function getStatusColor(status) {
            switch(status) {
                case 'Actif': return 'success';
                case 'En attente': return 'warning';
                case 'Resilié': return 'danger';
                default: return 'secondary';
            }
        }
    </script>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>