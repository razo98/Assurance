<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Récupérer les paramètres du formulaire
    String token = request.getParameter("token");
    String userType = request.getParameter("userType");
    String newPassword = request.getParameter("newPassword");
    String confirmPassword = request.getParameter("confirmPassword");
    
    // Vérifier que tous les champs sont remplis
    if (token == null || token.trim().isEmpty() || 
        userType == null || userType.trim().isEmpty() ||
        newPassword == null || newPassword.trim().isEmpty() ||
        confirmPassword == null || confirmPassword.trim().isEmpty()) {
        
        request.setAttribute("errorMessage", "Tous les champs sont obligatoires");
        request.getRequestDispatcher("change-password.jsp?token=" + token + "&type=" + userType).forward(request, response);
        return;
    }
    
    // Vérifier que les mots de passe correspondent
    if (!newPassword.equals(confirmPassword)) {
        request.setAttribute("errorMessage", "Les mots de passe ne correspondent pas");
        request.getRequestDispatcher("change-password.jsp?token=" + token + "&type=" + userType).forward(request, response);
        return;
    }
    
    // Vérifier que le mot de passe a une longueur minimale
    if (newPassword.length() < 6) {
        request.setAttribute("errorMessage", "Le mot de passe doit contenir au moins 6 caractères");
        request.getRequestDispatcher("change-password.jsp?token=" + token + "&type=" + userType).forward(request, response);
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
        
        int userId = -1;
        boolean isValidToken = false;
        
        // Vérifier le token selon le type d'utilisateur
        if ("user".equals(userType)) {
            String checkTokenSql = "SELECT user_id FROM password_reset WHERE token = ? AND expiration_date > NOW()";
            stmt = conn.prepareStatement(checkTokenSql);
            stmt.setString(1, token);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                userId = rs.getInt("user_id");
                isValidToken = true;
            }
            
            if (isValidToken) {
                // Fermer les ressources précédentes
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                
                // Mettre à jour le mot de passe de l'utilisateur
                String updatePasswordSql = "UPDATE users SET password = ? WHERE iduser = ?";
                stmt = conn.prepareStatement(updatePasswordSql);
                stmt.setString(1, newPassword);
                stmt.setInt(2, userId);
                int rowsUpdated = stmt.executeUpdate();
                
                if (rowsUpdated > 0) {
                    // Supprimer le token utilisé
                    if (stmt != null) stmt.close();
                    
                    String deleteTokenSql = "DELETE FROM password_reset WHERE token = ?";
                    stmt = conn.prepareStatement(deleteTokenSql);
                    stmt.setString(1, token);
                    stmt.executeUpdate();
                    
                    // Retourner à la page de connexion avec un message de succès
                    request.setAttribute("resetSuccess", "Votre mot de passe a été réinitialisé avec succès. Vous pouvez maintenant vous connecter avec votre nouveau mot de passe.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }
            }
        } else if ("admin".equals(userType)) {
            String checkTokenSql = "SELECT admin_id FROM admin_password_reset WHERE token = ? AND expiration_date > NOW()";
            stmt = conn.prepareStatement(checkTokenSql);
            stmt.setString(1, token);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                userId = rs.getInt("admin_id");
                isValidToken = true;
            }
            
            if (isValidToken) {
                // Fermer les ressources précédentes
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                
                // Mettre à jour le mot de passe de l'administrateur
                String updatePasswordSql = "UPDATE admins SET password = ? WHERE idadmin = ?";
                stmt = conn.prepareStatement(updatePasswordSql);
                stmt.setString(1, newPassword);
                stmt.setInt(2, userId);
                int rowsUpdated = stmt.executeUpdate();
                
                if (rowsUpdated > 0) {
                    // Supprimer le token utilisé
                    if (stmt != null) stmt.close();
                    
                    String deleteTokenSql = "DELETE FROM admin_password_reset WHERE token = ?";
                    stmt = conn.prepareStatement(deleteTokenSql);
                    stmt.setString(1, token);
                    stmt.executeUpdate();
                    
                    // Retourner à la page de connexion avec un message de succès
                    request.setAttribute("resetSuccess", "Votre mot de passe a été réinitialisé avec succès. Vous pouvez maintenant vous connecter avec votre nouveau mot de passe.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }
            }
        }
        
        // Si on arrive ici, le token n'est pas valide ou a expiré
        request.setAttribute("errorMessage", "Le lien de réinitialisation est invalide ou a expiré. Veuillez faire une nouvelle demande.");
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
        
    } catch (Exception e) {
        request.setAttribute("errorMessage", "Une erreur est survenue : " + e.getMessage());
        request.getRequestDispatcher("change-password.jsp?token=" + token + "&type=" + userType).forward(request, response);
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>