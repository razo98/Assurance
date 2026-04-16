<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Vérification de la session agent
    Integer adminId = (Integer) session.getAttribute("idadmin");
    String adminFirstName = (String) session.getAttribute("firstname");
    String adminLastName = (String) session.getAttribute("lastname");
    String matric = (String) session.getAttribute("matricule");
    String role = (String) session.getAttribute("role");
    String fullName = adminFirstName + " " + adminLastName;
    
    // Contrôle du rôle "lune"
    if(adminId == null || role == null || !"lune".equals(role)){
        response.sendRedirect("../login.jsp");
        return;
    }

    // Variables de statistiques
    int totalAssurancesAgent = 0;
    int assurancesActivesAgent = 0;
    int assurancesEnAttenteAgent = 0;
    double montantTotalAgent = 0;
    int assurancesExpirees = 0;
    int clientsTotal = 0;
    // Les variables pour les réclamations sont supprimées car non gérées par les agents

    // Connexion à la base de données
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    try {
        // Charger le driver
        Class.forName("org.mariadb.jdbc.Driver");
        
        // Établir la connexion
        conn = DriverManager.getConnection(
            "jdbc:mariadb://localhost:3306/assurance", 
            "root", 
            ""
        );

        // Création du statement
        stmt = conn.createStatement();

        // Requête pour le total des assurances gérées par l'agent
        rs = stmt.executeQuery("SELECT COUNT(*) AS total FROM assurance WHERE matricule = '" + matric + "'");
        if (rs.next()) {
            totalAssurancesAgent = rs.getInt("total");
        }
        rs.close();

        // Requête pour les assurances actives gérées par l'agent
        rs = stmt.executeQuery("SELECT COUNT(*) AS actives FROM assurance WHERE matricule = '" + matric + "' AND valider = 1 AND date_fin >= CURDATE()");
        if (rs.next()) {
            assurancesActivesAgent = rs.getInt("actives");
        }
        rs.close();

        // Requête pour les assurances en attente
        rs = stmt.executeQuery("SELECT COUNT(*) AS attente FROM assurance WHERE matricule = '" + matric + "' AND valider = 0");
        if (rs.next()) {
            assurancesEnAttenteAgent = rs.getInt("attente");
        }
        rs.close();

        // Requête pour le montant total des assurances validées
        rs = stmt.executeQuery("SELECT COALESCE(SUM(prix_ttc), 0) AS total FROM assurance WHERE matricule = '" + matric + "' AND valider = 1");
        if (rs.next()) {
            montantTotalAgent = rs.getDouble("total");
        }
        rs.close();
        
        // Requête pour les assurances expirées
        rs = stmt.executeQuery("SELECT COUNT(*) AS expirees FROM assurance WHERE matricule = '" + matric + "' AND date_fin < CURDATE()");
        if (rs.next()) {
            assurancesExpirees = rs.getInt("expirees");
        }
        rs.close();

        // Requête pour le nombre total de clients uniques servis par cet agent
        rs = stmt.executeQuery("SELECT COUNT(DISTINCT iduser) AS total_clients FROM assurance WHERE matricule = '" + matric + "'");
        if (rs.next()) {
            clientsTotal = rs.getInt("total_clients");
        }
        rs.close();

        // Les réclamations ne sont pas gérées par les agents, donc ces requêtes sont supprimées

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        // Fermeture des ressources
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <title>Tableau de bord Agent - Assurance Automobile</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        :root {
            --primary-color: #da812f;
            --secondary-color: #f8f1e9;
            --text-color: #333;
            --accent-color: #4CAF50;
            --warning-color: #ff9800;
            --danger-color: #f44336;
        }
        
        body {
            background-color: var(--secondary-color);
            font-family: 'Arial', sans-serif;
            padding-top: 60px; /* Pour la navbar fixe */
        }
        
        .dashboard-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .welcome-banner {
            background: linear-gradient(135deg, var(--primary-color), #e67e22);
            color: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            position: relative;
            overflow: hidden;
            animation: fadeIn 0.6s ease-out;
        }
        
        .welcome-banner::before {
            content: "";
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            transform: rotate(30deg);
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .welcome-banner h1 {
            font-size: 1.8rem;
            font-weight: 600;
            margin-bottom: 10px;
            position: relative;
        }
        
        .welcome-banner p {
            font-size: 1rem;
            margin-bottom: 8px;
            opacity: 0.9;
            position: relative;
        }
        
        .stats-heading {
            color: var(--primary-color);
            font-size: 1.4rem;
            margin: 20px 0 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--primary-color);
            display: inline-block;
        }
        
        .card-stats {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            padding: 20px;
            margin-bottom: 20px;
            transition: all 0.3s ease;
            height: 100%;
            position: relative;
            overflow: hidden;
        }
        
        .card-stats:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.12);
        }
        
        .card-stats::after {
            content: "";
            position: absolute;
            bottom: 0;
            left: 0;
            height: 4px;
            width: 100%;
            background: var(--primary-color);
            transform: scaleX(0);
            transform-origin: left;
            transition: transform 0.3s ease;
        }
        
        .card-stats:hover::after {
            transform: scaleX(1);
        }
        
        .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 15px;
            color: var(--primary-color);
            text-align: center;
        }
        
        .stat-value {
            font-size: 2rem;
            font-weight: bold;
            color: var(--text-color);
            text-align: center;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #6c757d;
            font-size: 1rem;
            text-align: center;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .stat-active .stat-icon {
            color: var(--accent-color);
        }
        
        .stat-pending .stat-icon {
            color: var(--warning-color);
        }
        
        .stat-expired .stat-icon {
            color: var(--danger-color);
        }
        
        .actions-container {
            margin-top: 30px;
            margin-bottom: 20px;
        }
        
        .quick-action {
            background-color: white;
            border-radius: 8px;
            padding: 15px;
            display: flex;
            align-items: center;
            margin-bottom: 15px;
            transition: all 0.3s ease;
            box-shadow: 0 3px 10px rgba(0,0,0,0.06);
            text-decoration: none;
            color: var(--text-color);
        }
        
        .quick-action:hover {
            transform: translateX(5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            color: var(--primary-color);
        }
        
        .action-icon {
            width: 50px;
            height: 50px;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--secondary-color);
            border-radius: 50%;
            margin-right: 15px;
            color: var(--primary-color);
            font-size: 1.5rem;
        }
        
        .action-text {
            flex: 1;
        }
        
        .action-title {
            font-weight: bold;
            font-size: 1.1rem;
            margin-bottom: 3px;
        }
        
        .action-description {
            font-size: 0.9rem;
            color: #6c757d;
        }
        
        .stat-progress {
            height: 6px;
            background-color: #e9ecef;
            border-radius: 3px;
            margin-top: 15px;
            overflow: hidden;
        }
        
        .stat-progress-bar {
            height: 100%;
            border-radius: 3px;
            background-color: var(--primary-color);
        }
        
        .stat-progress-active .stat-progress-bar {
            background-color: var(--accent-color);
        }
        
        .stat-progress-pending .stat-progress-bar {
            background-color: var(--warning-color);
        }
        
        .stat-progress-expired .stat-progress-bar {
            background-color: var(--danger-color);
        }
        
        .agent-badge {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background-color: var(--primary-color);
            color: white;
            padding: 10px 15px;
            border-radius: 30px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
            display: flex;
            align-items: center;
            z-index: 1000;
            font-size: 14px;
            transition: transform 0.3s ease;
        }
        
        .agent-badge:hover {
            transform: translateY(-5px);
        }
        
        .agent-badge i {
            margin-right: 8px;
            font-size: 18px;
        }
        
        /* Animations pour les cartes */
        .card-stats:nth-child(1) { animation: fadeIn 0.5s ease forwards; }
        .card-stats:nth-child(2) { animation: fadeIn 0.5s 0.1s ease forwards; opacity: 0; }
        .card-stats:nth-child(3) { animation: fadeIn 0.5s 0.2s ease forwards; opacity: 0; }
        .card-stats:nth-child(4) { animation: fadeIn 0.5s 0.3s ease forwards; opacity: 0; }
        .card-stats:nth-child(5) { animation: fadeIn 0.5s 0.4s ease forwards; opacity: 0; }
        .card-stats:nth-child(6) { animation: fadeIn 0.5s 0.5s ease forwards; opacity: 0; }
        
        /* Adaptations responsive */
        @media (max-width: 768px) {
            .welcome-banner h1 {
                font-size: 1.4rem;
            }
            
            .stat-value {
                font-size: 1.5rem;
            }
            
            .stat-icon {
                font-size: 2rem;
            }
            
            .action-icon {
                width: 40px;
                height: 40px;
                font-size: 1.2rem;
            }
            
            .action-title {
                font-size: 1rem;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../meag.jsp" %>

    <div class="dashboard-container">
        <div class="welcome-banner">
            <h1>Bienvenue, <%= adminFirstName %> <%= adminLastName %> !</h1>
            <p>Vous pouvez consulter ici un résumé de vos activités et statistiques d'agent.</p>
            <div style="font-size: 0.9rem; opacity: 0.8; margin-top: 5px;">
                <i class="fas fa-calendar-alt"></i> <%= new java.text.SimpleDateFormat("EEEE d MMMM yyyy", new java.util.Locale("fr", "FR")).format(new java.util.Date()) %>
                &nbsp;&nbsp;|&nbsp;&nbsp;
                <i class="fas fa-id-card"></i> Matricule: <%= matric %>
            </div>
        </div>

        <h3 class="stats-heading"><i class="fas fa-chart-line"></i> Statistiques des assurances</h3>

        <div class="row">
            <div class="col-md-4 col-sm-6 mb-4">
                <div class="card-stats">
                    <div class="stat-icon">
                        <i class="fas fa-file-contract"></i>
                    </div>
                    <div class="stat-value"><%= totalAssurancesAgent %></div>
                    <div class="stat-label">Contrats gérés</div>
                    <div class="stat-progress">
                        <div class="stat-progress-bar" style="width: 100%;"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-4 col-sm-6 mb-4">
                <div class="card-stats stat-active">
                    <div class="stat-icon">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                    <div class="stat-value"><%= assurancesActivesAgent %></div>
                    <div class="stat-label">Assurances actives</div>
                    <div class="stat-progress stat-progress-active">
                        <div class="stat-progress-bar" style="width: <%= (totalAssurancesAgent > 0) ? (assurancesActivesAgent * 100 / totalAssurancesAgent) : 0 %>%;"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-4 col-sm-6 mb-4">
                <div class="card-stats stat-pending">
                    <div class="stat-icon">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="stat-value"><%= assurancesEnAttenteAgent %></div>
                    <div class="stat-label">En attente</div>
                    <div class="stat-progress stat-progress-pending">
                        <div class="stat-progress-bar" style="width: <%= (totalAssurancesAgent > 0) ? (assurancesEnAttenteAgent * 100 / totalAssurancesAgent) : 0 %>%;"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-3 col-sm-6 mb-4">
                <div class="card-stats stat-expired">
                    <div class="stat-icon">
                        <i class="fas fa-calendar-times"></i>
                    </div>
                    <div class="stat-value"><%= assurancesExpirees %></div>
                    <div class="stat-label">Contrats expirés</div>
                    <div class="stat-progress stat-progress-expired">
                        <div class="stat-progress-bar" style="width: <%= (totalAssurancesAgent > 0) ? (assurancesExpirees * 100 / totalAssurancesAgent) : 0 %>%;"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6 mb-4">
                <div class="card-stats">
                    <div class="stat-icon">
                        <i class="fas fa-euro-sign"></i>
                    </div>
                    <div class="stat-value"><%= String.format("%,.0f", montantTotalAgent) %></div>
                    <div class="stat-label">Montant total (CFA)</div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6 mb-4">
                <div class="card-stats">
                    <div class="stat-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stat-value"><%= clientsTotal %></div>
                    <div class="stat-label">Clients servis</div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6 mb-4">
                <div class="card-stats">
                    <div class="stat-icon">
                        <i class="fas fa-percentage"></i>
                    </div>
                    <div class="stat-value"><%= (totalAssurancesAgent > 0) ? String.format("%.1f", (assurancesActivesAgent * 100.0 / totalAssurancesAgent)) : "0" %>%</div>
                    <div class="stat-label">Taux d'activation</div>
                </div>
            </div>
        </div>

        <!-- Section réclamations supprimée car non gérée par les agents -->

        <h3 class="stats-heading"><i class="fas fa-bolt"></i> Actions rapides</h3>

        <div class="actions-container">
            <div class="row">
                <div class="col-md-6">
                    <a href="agentdevis.jsp" class="quick-action">
                        <div class="action-icon">
                            <i class="fas fa-plus-circle"></i>
                        </div>
                        <div class="action-text">
                            <div class="action-title">Nouvelle assurance</div>
                            <div class="action-description">Créer un contrat d'assurance pour un client</div>
                        </div>
                    </a>
                </div>
                <div class="col-md-6">
                    <a href="agentaffichageassurance.jsp" class="quick-action">
                        <div class="action-icon">
                            <i class="fas fa-list-alt"></i>
                        </div>
                        <div class="action-text">
                            <div class="action-title">Liste des assurances</div>
                            <div class="action-description">Consulter toutes les assurances que vous gérez</div>
                        </div>
                    </a>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <a href="rechercherassurance.jsp" class="quick-action">
                        <div class="action-icon">
                            <i class="fas fa-search"></i>
                        </div>
                        <div class="action-text">
                            <div class="action-title">Autres assurances</div>
                            <div class="action-description">Consulter tous les clients que vous gérez</div>
                        </div>
                    </a>
                </div>
                <div class="col-md-6">
                    <a href="renouAgent.jsp" class="quick-action">
                        <div class="action-icon">
                            <i class="fas fa-chart-pie"></i>
                        </div>
                        <div class="action-text">
                            <div class="action-title">Renouvellement</div>
                            <div class="action-description">Consulter les statistiques détaillées</div>
                        </div>
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="agent-badge">
        <i class="fas fa-user-tie"></i> Agent: <%= fullName %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Animation des cartes statistiques au défilement
        document.addEventListener('DOMContentLoaded', function() {
            const cards = document.querySelectorAll('.card-stats');
            
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.transform = 'translateY(0)';
                        entry.target.style.opacity = '1';
                    }
                });
            }, { threshold: 0.1 });
            
            cards.forEach(card => {
                observer.observe(card);
            });
        });
    </script>
</body>
</html>