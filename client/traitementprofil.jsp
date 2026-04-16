<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Vérification de la session
    Integer iduser = (Integer) session.getAttribute("iduser");
    if(iduser == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Récupération des paramètres du formulaire
    String firstname = request.getParameter("firstname");
    String lastname = request.getParameter("lastname");
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String number = request.getParameter("number");
    String email = request.getParameter("email");
    
    // Variables pour la connexion à la base de données
    Connection conn = null;
    PreparedStatement checkStmt = null;
    PreparedStatement updateStmt = null;
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
        
        // Vérifier si le nom d'utilisateur existe déjà (sauf pour l'utilisateur actuel)
        String checkSql = "SELECT iduser FROM users WHERE username = ? AND iduser != ?";
        checkStmt = conn.prepareStatement(checkSql);
        checkStmt.setString(1, username);
        checkStmt.setInt(2, iduser);
        rs = checkStmt.executeQuery();
        
        if (rs.next()) {
            // Le nom d'utilisateur existe déjà pour un autre utilisateur
            session.setAttribute("profileUpdateError", "Ce nom d'utilisateur est déjà utilisé par un autre compte.");
            response.sendRedirect("profil.jsp");
            return;
        }
        
        // Préparation de la requête SQL pour mettre à jour le profil
        StringBuilder sqlBuilder = new StringBuilder("UPDATE users SET firstname = ?, lastname = ?, username = ?, number = ?");
        
        // Ajouter email s'il est fourni
        if (email != null && !email.trim().isEmpty()) {
            sqlBuilder.append(", email = ?");
        }
        
        // Ajouter password s'il est fourni
        if (password != null && !password.trim().isEmpty()) {
            sqlBuilder.append(", password = ?");
        }
        
        sqlBuilder.append(" WHERE iduser = ?");
        
        updateStmt = conn.prepareStatement(sqlBuilder.toString());
        
        // Définir les paramètres communs
        updateStmt.setString(1, firstname);
        updateStmt.setString(2, lastname);
        updateStmt.setString(3, username);
        updateStmt.setString(4, number);
        
        int paramIndex = 5;
        
        // Ajouter email s'il est fourni
        if (email != null && !email.trim().isEmpty()) {
            updateStmt.setString(paramIndex++, email);
        }
        
        // Ajouter password s'il est fourni
        if (password != null && !password.trim().isEmpty()) {
            updateStmt.setString(paramIndex++, password);
        }
        
        // Ajouter l'ID de l'utilisateur
        updateStmt.setInt(paramIndex, iduser);
        
        // Exécuter la mise à jour
        int rowsUpdated = updateStmt.executeUpdate();
        
        if (rowsUpdated > 0) {
            // Mise à jour réussie
            
            // Mettre à jour les attributs de session
            session.setAttribute("firstname", firstname);
            session.setAttribute("lastname", lastname);
            session.setAttribute("username", username);
            session.setAttribute("number", number);
            
            // Message de succès
            session.setAttribute("profileUpdateSuccess", "Votre profil a été mis à jour avec succès.");
        } else {
            // Aucune ligne mise à jour (ce qui est étrange mais possible)
            session.setAttribute("profileUpdateError", "Aucune modification n'a été apportée à votre profil.");
        }
        
    } catch (Exception e) {
        // En cas d'erreur, stocker le message d'erreur pour l'afficher
        session.setAttribute("profileUpdateError", "Erreur lors de la mise à jour du profil : " + e.getMessage());
        e.printStackTrace();
    } finally {
        // Fermeture des ressources
        try {
            if (rs != null) rs.close();
            if (checkStmt != null) checkStmt.close();
            if (updateStmt != null) updateStmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // Redirection vers la page de profil
    response.sendRedirect("profil.jsp");
%>