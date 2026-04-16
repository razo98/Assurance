<%@ page import="java.sql.*" %>
<%@ page import="java.security.SecureRandom" %>
<%@ page import="java.util.Random" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%!
    // Fonction pour générer un matricule aléatoire de 5 caractères (lettres et chiffres)
    public String generateMatricule() {
        Random random = new Random();
        // Génère un entier entre 10000 et 99999
        int num = 10000 + random.nextInt(90000);
         return "ADM" + num;
    }
    
    // Fonction pour vérifier si un matricule existe déjà dans la table admins
    public boolean matriculeExists(String matricule, Connection conn) throws SQLException {
        String sql = "SELECT COUNT(*) AS cnt FROM admins WHERE matricule = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, matricule);
        ResultSet rs = ps.executeQuery();
        boolean exists = false;
        if(rs.next()){
            exists = rs.getInt("cnt") > 0;
        }
        rs.close();
        ps.close();
        return exists;
    }
    
    // Fonction pour vérifier si une valeur existe dans l'une des deux tables (admins ou users)
    public boolean valueExistsInBothTables(String value, String field, Connection conn) throws SQLException {
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
        
        // Si déjà trouvé dans admins, pas besoin de vérifier dans users
        if(existsInAdmins) {
            return true;
        }
        
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
        
        return existsInUsers;
    }
%>
<%
    // Récupération des données du formulaire
    String firstname = request.getParameter("firstname");
    String lastname = request.getParameter("lastname");
    String username = request.getParameter("username");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String number = request.getParameter("number");
    String quartier = request.getParameter("quartier");
    String role = request.getParameter("role");
    if (role == null || role.isEmpty()) {
        role = "lune"; // Par défaut pour un agent
    }
    Connection conn = null;
    PreparedStatement stmt = null;
    String matricule = "";
    ResultSet rs = null;
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
        
        // Générer un matricule et s'assurer qu'il est unique
        matricule = generateMatricule();
        while(matriculeExists(matricule, conn)) {
            matricule = generateMatricule();
        }
        
        // Vérifier si le nom d'utilisateur existe déjà dans les deux tables
        if(valueExistsInBothTables(username, "username", conn)) {
            request.setAttribute("registrationError", "Nom d'utilisateur déjà utilisé");
            request.getRequestDispatcher("gererAgents.jsp").forward(request, response);
            return;
        }
        
        // Vérifier si l'email existe déjà dans les deux tables
        if(valueExistsInBothTables(email, "email", conn)) {
            request.setAttribute("registrationError", "Email déjà utilisé");
            request.getRequestDispatcher("gererAgents.jsp").forward(request, response);
            return;
        }
        
        // Vérifier si le numéro de téléphone existe déjà dans les deux tables
        if(valueExistsInBothTables(number, "number", conn)) {
            request.setAttribute("registrationError", "Numéro de téléphone déjà utilisé");
            request.getRequestDispatcher("gererAgents.jsp").forward(request, response);
            return;
        }
        
        // Préparer la requête d'insertion incluant le matricule généré et l'email
        String sql = "INSERT INTO admins (firstname, lastname, username, email, password, number, quartier, role, matricule) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, firstname);
        stmt.setString(2, lastname);
        stmt.setString(3, username);
        stmt.setString(4, email);
        stmt.setString(5, password);
        stmt.setString(6, number);
        stmt.setString(7, quartier);
        stmt.setString(8, role);
        stmt.setString(9, matricule);
        
        int rows = stmt.executeUpdate();
        if(rows > 0) {
            request.setAttribute("registerSuccess", "Agent ajouté avec succès. Matricule généré : " + matricule);
            request.getRequestDispatcher("gererAgents.jsp").forward(request, response);
        } else {
            request.setAttribute("registrationError", "Erreur lors de l'insertion de l'agent.");
            request.getRequestDispatcher("gererAgents.jsp").forward(request, response);
        }
    } catch(Exception e) {
        request.setAttribute("registrationError", "Erreur : " + e.getMessage());
        request.getRequestDispatcher("gererAgents.jsp").forward(request, response);
    } finally {
        if(rs != null) try { rs.close(); } catch(SQLException ignore){}
        if(stmt != null) try { stmt.close(); } catch(SQLException ignore){}
        if(conn != null) try { conn.close(); } catch(SQLException ignore){}
    }
%>