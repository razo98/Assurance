<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%!
    // Fonction pour vérifier si une valeur existe dans l'une des deux tables (users ou admins)
    public boolean valueExistsInBothTables(String value, String field, Connection conn) throws SQLException {
        // Vérification dans la table users
        String sqlUsers = "SELECT COUNT(*) AS cnt FROM users WHERE " + field + " = ?";
        PreparedStatement psUsers = conn.prepareStatement(sqlUsers);
        psUsers.setString(1, value);
        ResultSet rsUsers = psUsers.executeQuery();
        boolean existsInUsers = false;
        if(rsUsers.next()){
            existsInUsers = rsUsers.getInt("cnt") > 0;
        }
        rsUsers.close();
        psUsers.close();
        
        // Si déjà trouvé dans users, pas besoin de vérifier dans admins
        if(existsInUsers) {
            return true;
        }
        
        // Vérification dans la table admins
        String sqlAdmins = "SELECT COUNT(*) AS cnt FROM admins WHERE " + field + " = ?";
        PreparedStatement psAdmins = conn.prepareStatement(sqlAdmins);
        psAdmins.setString(1, value);
        ResultSet rsAdmins = psAdmins.executeQuery();
        boolean existsInAdmins = false;
        if(rsAdmins.next()){
            existsInAdmins = rsAdmins.getInt("cnt") > 0;
        }
        rsAdmins.close();
        psAdmins.close();
        
        return existsInAdmins;
    }
%>
<%
    // Récupération des données du formulaire
    String firstname = request.getParameter("firstname");
    String lastname = request.getParameter("lastname");
    String username = request.getParameter("username");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirm_password");
    String number = request.getParameter("number");
    
    Connection conn = null;
    PreparedStatement stmt = null;
    
    try {
        // Vérification que les mots de passe correspondent
        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("registrationError", "Les mots de passe ne correspondent pas");
            request.getRequestDispatcher("gererclient.jsp").forward(request, response);
            return;
        }
        
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
        
        // Vérifier si le nom d'utilisateur existe déjà dans les deux tables
        if(valueExistsInBothTables(username, "username", conn)) {
            request.setAttribute("registrationError", "Nom d'utilisateur déjà utilisé");
            request.getRequestDispatcher("gererclient.jsp").forward(request, response);
            return;
        }
        
        // Vérifier si l'email existe déjà dans les deux tables
        if(valueExistsInBothTables(email, "email", conn)) {
            request.setAttribute("registrationError", "Email déjà utilisé");
            request.getRequestDispatcher("gererclient.jsp").forward(request, response);
            return;
        }
        
        // Vérifier si le numéro de téléphone existe déjà dans les deux tables
        if(valueExistsInBothTables(number, "number", conn)) {
            request.setAttribute("registrationError", "Numéro de téléphone déjà utilisé");
            request.getRequestDispatcher("gererclient.jsp").forward(request, response);
            return;
        }
        
        // Préparer la requête d'insertion incluant l'email
        String sql = "INSERT INTO users (firstname, lastname, username, email, password, number) VALUES (?, ?, ?, ?, ?, ?)";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, firstname);
        stmt.setString(2, lastname);
        stmt.setString(3, username);
        stmt.setString(4, email);
        stmt.setString(5, password);
        stmt.setString(6, number);
        
        int rows = stmt.executeUpdate();
        if(rows > 0) {
            request.setAttribute("registerSuccess", "Client ajouté avec succès");
            request.getRequestDispatcher("gererclient.jsp").forward(request, response);
        } else {
            request.setAttribute("registrationError", "Erreur lors de l'insertion du client");
            request.getRequestDispatcher("gererclient.jsp").forward(request, response);
        }
    } catch(Exception e) {
        request.setAttribute("registrationError", "Erreur : " + e.getMessage());
        request.getRequestDispatcher("gererclient.jsp").forward(request, response);
    } finally {
        if(stmt != null) try { stmt.close(); } catch(SQLException ignore){}
        if(conn != null) try { conn.close(); } catch(SQLException ignore){}
    }
%>