<%@ page import="java.sql.*" %>
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

   // Variables pour les statistiques
   int clientCount = 0;
   int agentCount = 0;
   int assuranceCount = 0;
   int assurancesActives = 0;
   int assurancesEnAttente = 0;
   int assurancesExpirees = 0;
   double totalCapital = 0.0;
   double totalPrime = 0.0;
   int reclamationsTotal = 0;
   int reclamationsEnCours = 0;

   Connection conn = null;
   PreparedStatement stmt = null;
   ResultSet rs = null;

   try {
      Class.forName("org.mariadb.jdbc.Driver");
      conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
      
      // Nombre de clients
      stmt = conn.prepareStatement("SELECT COUNT(*) AS count FROM users");
      rs = stmt.executeQuery();
      if(rs.next()) clientCount = rs.getInt("count");
      rs.close(); stmt.close();
      
      // Nombre d'agents
      stmt = conn.prepareStatement("SELECT COUNT(*) AS count FROM admins WHERE role='lune'");
      rs = stmt.executeQuery();
      if(rs.next()) agentCount = rs.getInt("count");
      rs.close(); stmt.close();
      
      // Nombre total d'assurances
      stmt = conn.prepareStatement("SELECT COUNT(*) AS count FROM assurance");
      rs = stmt.executeQuery();
      if(rs.next()) assuranceCount = rs.getInt("count");
      rs.close(); stmt.close();
      
      // Assurances actives
      stmt = conn.prepareStatement("SELECT COUNT(*) AS count FROM assurance WHERE valider = 1 AND date_fin >= CURDATE()");
      rs = stmt.executeQuery();
      if(rs.next()) assurancesActives = rs.getInt("count");
      rs.close(); stmt.close();
      
      // Assurances en attente
      stmt = conn.prepareStatement("SELECT COUNT(*) AS count FROM assurance WHERE valider = 0");
      rs = stmt.executeQuery();
      if(rs.next()) assurancesEnAttente = rs.getInt("count");
      rs.close(); stmt.close();
      
      // Assurances expirées
      stmt = conn.prepareStatement("SELECT COUNT(*) AS count FROM assurance WHERE date_fin < CURDATE()");
      rs = stmt.executeQuery();
      if(rs.next()) assurancesExpirees = rs.getInt("count");
      rs.close(); stmt.close();
      
      // Capital total (TTC)
      stmt = conn.prepareStatement("SELECT SUM(prix_ttc) AS total FROM assurance");
      rs = stmt.executeQuery();
      if(rs.next()) totalCapital = rs.getDouble("total");
      rs.close(); stmt.close();
      
      // Total des primes
      stmt = conn.prepareStatement("SELECT SUM(prix_ht * 0.1) AS total_prime FROM assurance");
      rs = stmt.executeQuery();
      if(rs.next()) totalPrime = rs.getDouble("total_prime");
      rs.close(); stmt.close();
      
      // Réclamations totales
      stmt = conn.prepareStatement("SELECT COUNT(*) AS count FROM reclamation");
      rs = stmt.executeQuery();
      if(rs.next()) reclamationsTotal = rs.getInt("count");
      rs.close(); stmt.close();
      
      // Réclamations en cours
      stmt = conn.prepareStatement("SELECT COUNT(*) AS count FROM reclamation WHERE etat = 'en_cours'");
      rs = stmt.executeQuery();
      if(rs.next()) reclamationsEnCours = rs.getInt("count");
      rs.close(); stmt.close();
      
   } catch(Exception e) {
      out.println("Erreur : " + e.getMessage());
   } finally {
      if(rs != null) try { rs.close(); } catch(SQLException ignore) {}
      if(stmt != null) try { stmt.close(); } catch(SQLException ignore) {}
      if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
   }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <title>Tableau de bord Admin - MBA-Niger Assurance</title>
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
        
        .admin-badge {
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
        
        .admin-badge:hover {
            transform: translateY(-5px);
        }
        
        .admin-badge i {
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
        }
    </style>
</head>
<body>
    <%@ include file="../mead.jsp" %>

    <div class="dashboard-container">
        <div class="welcome-banner">
            <h1>Tableau de bord administrateur, <%= firstname %> <%= lastname %></h1>
            <p>Vue d'ensemble complète de votre plateforme d'assurance</p>
            <div style="font-size: 0.9rem; opacity: 0.8; margin-top: 5px;">
                <i class="fas fa-calendar-alt"></i> <%= new java.text.SimpleDateFormat("EEEE d MMMM yyyy", new java.util.Locale("fr", "FR")).format(new java.util.Date()) %>
            </div>
        </div>

        <h3 class="stats-heading"><i class="fas fa-chart-line"></i> Vue globale</h3>
        <div class="dashboard-container">
        <div class="row">
            <div class="col-md-4 col-sm-6 mb-4">
                <div class="card-stats">
                    <div class="stat-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stat-value"><%= clientCount %></div>
                    <div class="stat-label">Clients total</div>
                    <div class="stat-progress">
                        <div class="stat-progress-bar" style="width: 100%;"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-4 col-sm-6 mb-4">
                <div class="card-stats">
                    <div class="stat-icon">
                        <i class="fas fa-user-tie"></i>
                    </div>
                    <div class="stat-value"><%= agentCount %></div>
                    <div class="stat-label">Agents actifs</div>
                    <div class="stat-progress">
                        <div class="stat-progress-bar" style="width: 100%;"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-4 col-sm-6 mb-4">
                <div class="card-stats">
                    <div class="stat-icon">
                        <i class="fas fa-file-contract"></i>
                    </div>
                    <div class="stat-value"><%= assuranceCount %></div>
                    <div class="stat-label">Total assurances</div>
                    <div class="stat-progress">
                        <div class="stat-progress-bar" style="width: 100%;"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-3 col-sm-6 mb-4">
                <div class="card-stats stat-active">
                    <div class="stat-icon">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                    <div class="stat-value"><%= assurancesActives %></div>
                    <div class="stat-label">Assurances actives</div>
                    <div class="stat-progress stat-progress-active">
                        <div class="stat-progress-bar" style="width: <%= (assuranceCount > 0) ? (assurancesActives * 100 / assuranceCount) : 0 %>%;"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6 mb-4">
                <div class="card-stats stat-pending">
                    <div class="stat-icon">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="stat-value"><%= assurancesEnAttente %></div>
                    <div class="stat-label">En attente</div>
                    <div class="stat-progress stat-progress-pending">
                        <div class="stat-progress-bar" style="width: <%= (assuranceCount > 0) ? (assurancesEnAttente * 100 / assuranceCount) : 0 %>%;"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6 mb-4">
                <div class="card-stats stat-expired">
                    <div class="stat-icon">
                        <i class="fas fa-calendar-times"></i>
                    </div>
                    <div class="stat-value"><%= assurancesExpirees %></div>
                    <div class="stat-label">Assurances expirées</div>
                    <div class="stat-progress stat-progress-expired">
                        <div class="stat-progress-bar" style="width: <%= (assuranceCount > 0) ? (assurancesExpirees * 100 / assuranceCount) : 0 %>%;"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6 mb-4">
                <div class="card-stats">
                    <div class="stat-icon">
                        <i class="fas fa-euro-sign"></i>
                    </div>
                    <div class="stat-value"><%= String.format("%,.0f", totalCapital) %></div>
                    <div class="stat-label">Capital total TTC</div>
                </div>
            </div>
        </div>

        <h3 class="stats-heading"><i class="fas fa-chart-pie"></i> Détails financiers et réclamations</h3>

        <div class="row">
            <div class="col-md-4 col-sm-6 mb-4">
                <div class="card-stats">
                    <div class="stat-icon">
                        <i class="fas fa-coins"></i>
                    </div>
                    <div class="stat-value"><%= String.format("%,.0f", totalPrime) %></div>
                    <div class="stat-label">Total des primes</div>
                </div>
            </div>
            <div class="col-md-4 col-sm-6 mb-4">
                <div class="card-stats">
                    <div class="stat-icon">
                        <i class="fas fa-comment-dots"></i>
                    </div>
                    <div class="stat-value"><%= reclamationsTotal %></div>
                    <div class="stat-label">Total réclamations</div>
                </div>
            </div>
            <div class="col-md-4 col-sm-6 mb-4">
                <div class="card-stats stat-pending">
                    <div class="stat-icon">
                        <i class="fas fa-spinner"></i>
                    </div>
                    <div class="stat-value"><%= reclamationsEnCours %></div>
                    <div class="stat-label">Réclamations en cours</div>
                    <div class="stat-progress stat-progress-pending">
                        <div class="stat-progress-bar" style="width: <%= (reclamationsTotal > 0) ? (reclamationsEnCours * 100 / reclamationsTotal) : 0 %>%;"></div>
                    </div>
                </div>
            </div>
        </div>

        <h3 class="stats-heading"><i class="fas fa-bolt"></i> Actions rapides</h3>

        <div class="actions-container">
            <div class="row">
                <div class="col-md-6">
                    <a href="admindevis.jsp" class="quick-action">
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
                    <a href="adminaffichageassurance.jsp" class="quick-action">
                        <div class="action-icon">
                            <i class="fas fa-shield-alt"></i>
                        </div>
                        <div class="action-text">
                            <div class="action-title">Les Assurances</div>
                            <div class="action-description">Superviser et gérer les assurances</div>
                        </div>
                    </a>
                </div>
            </div>
            <div class="row">
                 <div class="col-md-6">
            <a href="statistiques_avancees.jsp" class="quick-action">
                <div class="action-icon" style="background-color: rgba(218, 129, 47, 0.1); color: var(--primary-color);">
                    <i class="fas fa-chart-pie"></i>
                </div>
                <div class="action-text">
                    <div class="action-title">Statistiques avancées</div>
                    <div class="action-description">Analyse détaillée par agent, catégorie et période</div>
                </div>
            </a>
        </div>
                <div class="col-md-6">
                    <a href="gererreclamation.jsp" class="quick-action">
                        <div class="action-icon">
                            <i class="fas fa-comment-medical"></i>
                        </div>
                        <div class="action-text">
                            <div class="action-title">Réclamations</div>
                            <div class="action-description">Gérer les réclamations clients</div>
                        </div>
                    </a>
                </div>
            </div>
        </div>


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