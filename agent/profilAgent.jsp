<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
   Integer idadmin = (Integer) session.getAttribute("idadmin");
   String fullName = (String) session.getAttribute("fullname");
   String matric = (String) session.getAttribute("matricule");
   String roler = (String) session.getAttribute("role");
   if(idadmin == null || roler == null || !"lune".equals(roler)) {
      response.sendRedirect("../login.jsp");
      return;
   }

   // Variables pour stocker les informations de l'agent
   String firstname = "", lastname = "", username = "", number = "", quartier = "", matricule = "";
   
   Connection conn = null;
   PreparedStatement stmt = null;
   ResultSet rs = null;
   try {
       Class.forName("org.mariadb.jdbc.Driver");
       conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
       String sql = "SELECT * FROM admins WHERE idadmin = ?";
       stmt = conn.prepareStatement(sql);
       stmt.setInt(1, idadmin);
       rs = stmt.executeQuery();
       if(rs.next()){
         firstname = rs.getString("firstname");
         lastname = rs.getString("lastname");
         username = rs.getString("username");
         number = rs.getString("number");
         quartier = rs.getString("quartier");
         matricule = rs.getString("matricule");
       }
   } catch(Exception e) {
       out.println("Erreur: " + e.getMessage());
   } finally {
       if(rs != null) try { rs.close(); } catch(SQLException ignore) {}
       if(stmt != null) try { stmt.close(); } catch(SQLException ignore) {}
       if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
   }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <title>Profil Agent</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        :root {
            --primary-color: #006652;
            --secondary-color: #e6f3f0;
            --text-color: #333;
            --primary-dark: #00a86b;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateX(-20px); }
            to { opacity: 1; transform: translateX(0); }
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            position: relative;
            padding-top: 70px;
        }

        .profile-container {
            max-width: 800px;
            margin: 2rem auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow: hidden;
            animation: fadeIn 0.6s ease-out;
            transition: transform 0.3s ease;
        }

        .profile-container:hover {
            transform: translateY(-5px);
        }

        .profile-header {
            background: var(--primary-color);
            padding: 2rem;
            text-align: center;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .profile-header h2 {
            font-weight: 600;
            margin: 0;
            font-size: 2rem;
            letter-spacing: 1px;
            display: flex;
            align-items: center;
        }

        .profile-header i {
            margin-right: 15px;
        }

        .profile-content {
            padding: 2rem;
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1.5rem;
        }

        .profile-item {
            display: flex;
            align-items: center;
            padding: 1rem;
            background: var(--secondary-color);
            border-radius: 8px;
            animation: slideIn 0.5s ease-out forwards;
            opacity: 0;
            transition: all 0.3s ease;
        }

        .profile-item:hover {
            transform: translateX(10px);
            background: color-mix(in srgb, var(--secondary-color) 90%, black);
        }

        .profile-item i {
            width: 40px;
            height: 40px;
            background: var(--primary-color);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1rem;
            flex-shrink: 0;
        }

        .profile-item div {
            line-height: 1.4;
        }

        .profile-item strong {
            display: block;
            color: var(--primary-dark);
            font-size: 0.9rem;
            margin-bottom: 0.3rem;
        }

        .profile-item span {
            font-size: 1.1rem;
            color: var(--text-color);
            font-weight: 500;
        }

        @media (max-width: 768px) {
            .profile-content {
                grid-template-columns: 1fr;
            }
            
            .profile-container {
                margin: 1rem;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../meag.jsp" %>

    <div class="profile-container">
        <div class="profile-header">
            <h2>
                <i class="fas fa-user-circle"></i>
                Mon Profil Agent
            </h2>
        </div>
        
        <div class="profile-content">
            <div class="profile-item" style="animation-delay: 0.2s">
                <i class="fas fa-signature"></i>
                <div>
                    <strong>Prénom</strong>
                    <span><%= firstname %></span>
                </div>
            </div>
            
            <div class="profile-item" style="animation-delay: 0.3s">
                <i class="fas fa-user-tag"></i>
                <div>
                    <strong>Nom</strong>
                    <span><%= lastname %></span>
                </div>
            </div>
            
            <div class="profile-item" style="animation-delay: 0.4s">
                <i class="fas fa-at"></i>
                <div>
                    <strong>Nom d'utilisateur</strong>
                    <span><%= username %></span>
                </div>
            </div>
            
            <div class="profile-item" style="animation-delay: 0.5s">
                <i class="fas fa-mobile-alt"></i>
                <div>
                    <strong>Téléphone</strong>
                    <span><%= number %></span>
                </div>
            </div>
            
            <div class="profile-item" style="animation-delay: 0.6s">
                <i class="fas fa-map-marker-alt"></i>
                <div>
                    <strong>Quartier</strong>
                    <span><%= quartier %></span>
                </div>
            </div>
            
            <div class="profile-item" style="animation-delay: 0.7s">
                <i class="fas fa-id-card"></i>
                <div>
                    <strong>Matricule</strong>
                    <span><%= matricule %></span>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Animation des éléments de profil
        document.addEventListener('DOMContentLoaded', () => {
            const profileItems = document.querySelectorAll('.profile-item');
            
            profileItems.forEach((item, index) => {
                item.style.opacity = '0';
                setTimeout(() => {
                    item.style.opacity = '1';
                }, (index + 1) * 100);
            });
        });
    </script>
</body>
</html>