<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String matricule = request.getParameter("matricule"); // Matricule pour les admins
    boolean isAdmin = "true".equals(request.getParameter("isAdmin")); // Checkbox admin cochée ?

    // Validation des paramètres
    if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
        request.setAttribute("loginError", "Veuillez remplir tous les champs obligatoires");
        request.getRequestDispatcher("login.jsp").forward(request, response);
        return;
    }

    if (isAdmin && (matricule == null || matricule.trim().isEmpty())) {
        request.setAttribute("loginError", "Le matricule est requis pour une connexion administrateur");
        request.getRequestDispatcher("login.jsp").forward(request, response);
        return;
    }

    String url = "jdbc:mariadb://localhost:3306/assurance";
    String dbUser = "root";
    String dbPass = "";

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);

        if (isAdmin) {
            // Connexion admin ou agent avec nom d'utilisateur ou email
            String sql = "SELECT idadmin, firstname, lastname, email, number, quartier, role, matricule FROM admins WHERE (username = ? OR email = ?) AND password = ? AND matricule = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            stmt.setString(2, username); // On utilise le même champ pour vérifier si c'est un email
            stmt.setString(3, password);
            stmt.setString(4, matricule);
            rs = stmt.executeQuery();

            if (rs.next()) {
                int idadmin = rs.getInt("idadmin");
                String firstname = rs.getString("firstname");
                String lastname = rs.getString("lastname");
                String email = rs.getString("email");
                String number = rs.getString("number");
                String quartier = rs.getString("quartier");
                String roleStr = rs.getString("role");
                String matric = rs.getString("matricule"); // 'soleil' = admin, 'lune' = agent
                String fullname = firstname + ' ' + lastname;

                // Stocker les informations de l'utilisateur en session
                session.setAttribute("idadmin", idadmin);
                session.setAttribute("firstname", firstname);
                session.setAttribute("lastname", lastname);
                session.setAttribute("email", email);
                session.setAttribute("number", number);
                session.setAttribute("quartier", quartier);
                session.setAttribute("role", roleStr);
                session.setAttribute("matricule", matric);
                session.setAttribute("fullname", fullname);

                // Redirection selon le rôle
                if ("soleil".equalsIgnoreCase(roleStr)) {
                    response.sendRedirect("admin/Tableaubord.jsp");
                } else if ("lune".equalsIgnoreCase(roleStr)) {
                    response.sendRedirect("agent/dashboardagent.jsp");
                } else {
                    request.setAttribute("loginError", "Rôle non reconnu");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
                return;
            }
        } else {
            // Connexion utilisateur normal avec nom d'utilisateur ou email
            String sql = "SELECT iduser, firstname, lastname, email, number FROM users WHERE (username = ? OR email = ?) AND password = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            stmt.setString(2, username); // On utilise le même champ pour vérifier si c'est un email
            stmt.setString(3, password);
            rs = stmt.executeQuery();

            if (rs.next()) {
                int iduser = rs.getInt("iduser");
                String firstname = rs.getString("firstname");
                String lastname = rs.getString("lastname");
                String email = rs.getString("email");
                String number = rs.getString("number");

                // Stocker les informations de l'utilisateur en session
                session.setAttribute("iduser", iduser);
                session.setAttribute("firstname", firstname);
                session.setAttribute("lastname", lastname);
                session.setAttribute("email", email);
                session.setAttribute("number", number);
                session.setAttribute("fullname", firstname + ' ' + lastname);

                response.sendRedirect("client/dashboard.jsp");
                return;
            }
        }

        // Si aucun compte trouvé (admin, agent ou user)
        request.setAttribute("loginError", "Identifiants incorrects. Veuillez vérifier votre email/nom d'utilisateur et votre mot de passe.");
        request.getRequestDispatcher("login.jsp").forward(request, response);

    } catch (Exception e) {
        request.setAttribute("loginError", "Erreur technique: " + e.getMessage());
        request.getRequestDispatcher("login.jsp").forward(request, response);
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>