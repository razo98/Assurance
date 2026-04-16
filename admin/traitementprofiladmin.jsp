<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Vérification de la session
    Integer idadmin = (Integer) session.getAttribute("idadmin");
    String currentRole = (String) session.getAttribute("role");
    if(idadmin == null || currentRole == null || !"soleil".equals(currentRole)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Récupération des paramètres du formulaire
    String firstname = request.getParameter("firstname");
    String lastname = request.getParameter("lastname");
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String number = request.getParameter("number");
    // Le matricule est récupéré mais non modifiable
    String matricule = (String) session.getAttribute("matricule");
    
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
        
        // Vérifier si le nom d'utilisateur existe déjà (sauf pour l'administrateur actuel)
        String checkSql = "SELECT idadmin FROM admins WHERE username = ? AND idadmin != ?";
        checkStmt = conn.prepareStatement(checkSql);
        checkStmt.setString(1, username);
        checkStmt.setInt(2, idadmin);
        rs = checkStmt.executeQuery();
        
        if (rs.next()) {
            // Le nom d'utilisateur existe déjà pour un autre administrateur
            session.setAttribute("profileUpdateError", "Ce nom d'utilisateur est déjà utilisé par un autre compte.");
            response.sendRedirect("profiladmin.jsp");
            return;
        }
        
        // Préparation de la requête SQL pour mettre à jour le profil
        StringBuilder sqlBuilder = new StringBuilder("UPDATE admins SET firstname = ?, lastname = ?, username = ?, number = ?");
        
        // Ajouter password s'il est fourni
        if (password != null && !password.trim().isEmpty()) {
            sqlBuilder.append(", password = ?");
        }
        
        sqlBuilder.append(" WHERE idadmin = ?");
        
        updateStmt = conn.prepareStatement(sqlBuilder.toString());
        
        // Définir les paramètres communs
        updateStmt.setString(1, firstname);
        updateStmt.setString(2, lastname);
        updateStmt.setString(3, username);
        updateStmt.setString(4, number);
        
        int paramIndex = 5;
        
        // Ajouter password s'il est fourni
        if (password != null && !password.trim().isEmpty()) {
            // Hash du mot de passe (vous devriez utiliser un vrai mécanisme de hachage comme BCrypt)
            updateStmt.setString(paramIndex++, password);
        }
        
        // Ajouter l'ID de l'administrateur
        updateStmt.setInt(paramIndex, idadmin);
        
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
    response.sendRedirect("profiladmin.jsp");
%>