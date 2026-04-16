<%@ page import="java.sql.*" %>
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
    String firstname = request.getParameter("firstname");
    String lastname = request.getParameter("lastname");
    String username = request.getParameter("username");
    String email = request.getParameter("email"); // Nouveau champ email
    String number = request.getParameter("number");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirmPassword"); // Nouveau champ confirmation mot de passe
    String acceptTerms = request.getParameter("acceptTerms"); // Termes et conditions

    // Validation des champs
    if (firstname == null || lastname == null || username == null || email == null || 
        number == null || password == null || confirmPassword == null) {
        request.setAttribute("registrationError", "Tous les champs sont obligatoires");
        request.getRequestDispatcher("login.jsp").forward(request, response);
        return;
    }
    
    // Vérification que les mots de passe correspondent
    if (!password.equals(confirmPassword)) {
        request.setAttribute("registrationError", "Les mots de passe ne correspondent pas");
        request.getRequestDispatcher("login.jsp").forward(request, response);
        return;
    }
    
    // Vérification de l'acceptation des conditions
    if (acceptTerms == null) {
        request.setAttribute("registrationError", "Vous devez accepter les conditions d'utilisation");
        request.getRequestDispatcher("login.jsp").forward(request, response);
        return;
    }

    String url = "jdbc:mariadb://localhost:3306/assurance";
    String dbUser = "root";
    String dbPassword = "";

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPassword);

        // Vérification si le nom d'utilisateur existe déjà dans les deux tables
        if (valueExistsInBothTables(username, "username", conn)) {
            request.setAttribute("registrationError", "Ce nom d'utilisateur est déjà utilisé");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        // Vérification si l'email existe déjà dans les deux tables
        if (valueExistsInBothTables(email, "email", conn)) {
            request.setAttribute("registrationError", "Cette adresse email est déjà utilisée");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        
        // Vérification si le numéro de téléphone existe déjà dans les deux tables
        if (valueExistsInBothTables(number, "number", conn)) {
            request.setAttribute("registrationError", "Ce numéro de téléphone est déjà utilisé");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        // Insertion du nouvel utilisateur
        String insertSql = "INSERT INTO users (firstname, lastname, username, email, number, password) VALUES (?, ?, ?, ?, ?, ?)";
        stmt = conn.prepareStatement(insertSql);
        stmt.setString(1, firstname);
        stmt.setString(2, lastname);
        stmt.setString(3, username);
        stmt.setString(4, email);
        stmt.setString(5, number);
        stmt.setString(6, password);

        int rows = stmt.executeUpdate();
        if (rows > 0) {
            request.setAttribute("registerSuccess", "Inscription réussie. Veuillez vous connecter.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            request.setAttribute("registrationError", "Erreur lors de l'inscription");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    } catch(Exception e) {
        request.setAttribute("registrationError", "Erreur : " + e.getMessage());
        request.getRequestDispatcher("login.jsp").forward(request, response);
    } finally {
        if (rs != null) try { rs.close(); } catch(SQLException ignore) {}
        if (stmt != null) try { stmt.close(); } catch(SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch(SQLException ignore) {}
    }
%>