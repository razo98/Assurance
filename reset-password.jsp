<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Cette page traite la demande de réinitialisation du mot de passe
    String email = request.getParameter("email");
    
    if (email == null || email.trim().isEmpty()) {
        request.setAttribute("errorMessage", "Veuillez fournir une adresse email valide");
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
        return;
    }
    
    // Variables pour la connexion à la base de données
    String url = "jdbc:mariadb://localhost:3306/assurance";
    String dbUser = "root";
    String dbPassword = "";
    
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPassword);
        
        // Vérifier si l'email existe dans la table des utilisateurs
        String checkSql = "SELECT iduser, username FROM users WHERE email = ?";
        stmt = conn.prepareStatement(checkSql);
        stmt.setString(1, email);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            // Email trouvé, générer un token unique
            String token = UUID.randomUUID().toString();
            String username = rs.getString("username");
            int userId = rs.getInt("iduser");
            
            // Fermer le ResultSet et le PreparedStatement précédents
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            
            // Créer ou mettre à jour l'entrée dans la table de réinitialisation de mot de passe
            String insertSql = "INSERT INTO password_reset (user_id, token, expiration_date) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 24 HOUR)) " +
                               "ON DUPLICATE KEY UPDATE token = ?, expiration_date = DATE_ADD(NOW(), INTERVAL 24 HOUR)";
            
            stmt = conn.prepareStatement(insertSql);
            stmt.setInt(1, userId);
            stmt.setString(2, token);
            stmt.setString(3, token);
            stmt.executeUpdate();
            
            // Construire le lien de réinitialisation
            String resetLink = request.getScheme() + "://" + request.getServerName() + 
                              (request.getServerPort() == 80 || request.getServerPort() == 443 ? "" : ":" + request.getServerPort()) + 
                              request.getContextPath() + "/change-password.jsp?token=" + token + "&type=user";
            
            // Dans un environnement de production, nous enverrions un email avec ce lien
            // Pour la démonstration, stocker le lien pour l'afficher
            request.setAttribute("resetLink", resetLink);
            request.setAttribute("userEmail", email);
            request.setAttribute("successMessage", "Un lien de réinitialisation a été généré pour " + email + ". " + 
                                "Le lien est valide pendant 24 heures.");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
        } else {
            // Vérifier si l'email existe dans la table des administrateurs
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            
            String checkAdminSql = "SELECT idadmin, username FROM admins WHERE email = ?";
            stmt = conn.prepareStatement(checkAdminSql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                // Email trouvé dans la table admin, générer un token unique
                String token = UUID.randomUUID().toString();
                String username = rs.getString("username");
                int adminId = rs.getInt("idadmin");
                
                // Fermer le ResultSet et le PreparedStatement précédents
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                
                // Créer ou mettre à jour l'entrée dans la table de réinitialisation de mot de passe pour admin
                String insertSql = "INSERT INTO admin_password_reset (admin_id, token, expiration_date) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 24 HOUR)) " +
                                  "ON DUPLICATE KEY UPDATE token = ?, expiration_date = DATE_ADD(NOW(), INTERVAL 24 HOUR)";
                
                stmt = conn.prepareStatement(insertSql);
                stmt.setInt(1, adminId);
                stmt.setString(2, token);
                stmt.setString(3, token);
                stmt.executeUpdate();
                
                // Construire le lien de réinitialisation
                String resetLink = request.getScheme() + "://" + request.getServerName() + 
                                  (request.getServerPort() == 80 || request.getServerPort() == 443 ? "" : ":" + request.getServerPort()) + 
                                  request.getContextPath() + "/change-password.jsp?token=" + token + "&type=admin";
                
                // Dans un environnement de production, nous enverrions un email avec ce lien
                // Pour la démonstration, stocker le lien pour l'afficher
                request.setAttribute("resetLink", resetLink);
                request.setAttribute("userEmail", email);
                request.setAttribute("successMessage", "Un lien de réinitialisation a été généré pour " + email + ". " + 
                                    "Le lien est valide pendant 24 heures.");
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            } else {
                // Email non trouvé
                request.setAttribute("errorMessage", "Aucun compte n'est associé à cette adresse email");
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            }
        }
    } catch (Exception e) {
        request.setAttribute("errorMessage", "Une erreur est survenue : " + e.getMessage());
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>