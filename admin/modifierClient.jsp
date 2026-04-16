<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%!
    // Fonction pour vérifier si une valeur existe dans l'une des deux tables (users ou admins)
    // en excluant l'utilisateur actuellement en cours de modification
    public boolean valueExistsInBothTables(String value, String field, int userId, Connection conn) throws SQLException {
        // Vérification dans la table users (en excluant l'utilisateur actuel)
        String sqlUsers = "SELECT COUNT(*) AS cnt FROM users WHERE " + field + " = ? AND iduser != ?";
        PreparedStatement psUsers = conn.prepareStatement(sqlUsers);
        psUsers.setString(1, value);
        psUsers.setInt(2, userId);
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
  String idStr = request.getParameter("iduser");
  int iduser = Integer.parseInt(idStr);
  String firstname = request.getParameter("firstname");
  String lastname = request.getParameter("lastname");
  String username = request.getParameter("username");
  String email = request.getParameter("email");
  String number = request.getParameter("number");
  String password = request.getParameter("password");
  String confirmPassword = request.getParameter("confirm_password");
  
  Connection conn = null;
  PreparedStatement stmt = null;
  ResultSet rs = null;
  
  try {
      Class.forName("org.mariadb.jdbc.Driver");
      conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
      
      // Récupérer les données actuelles de l'utilisateur pour vérification
      String checkSql = "SELECT username, email, number, password FROM users WHERE iduser = ?";
      stmt = conn.prepareStatement(checkSql);
      stmt.setInt(1, iduser);
      rs = stmt.executeQuery();
      
      if (rs.next()) {
          String currentUsername = rs.getString("username");
          String currentEmail = rs.getString("email");
          String currentNumber = rs.getString("number");
          String currentPassword = rs.getString("password");
          
          // Vérifier si le nom d'utilisateur a changé et s'il est déjà pris dans les deux tables
          if (!username.equals(currentUsername)) {
              if (valueExistsInBothTables(username, "username", iduser, conn)) {
                  request.setAttribute("registrationError", "Nom d'utilisateur déjà utilisé");
                  request.getRequestDispatcher("gererclient.jsp").forward(request, response);
                  return;
              }
          }
          
          // Vérifier si l'email a changé et s'il est déjà pris dans les deux tables
          if (!email.equals(currentEmail)) {
              if (valueExistsInBothTables(email, "email", iduser, conn)) {
                  request.setAttribute("registrationError", "Email déjà utilisé");
                  request.getRequestDispatcher("gererclient.jsp").forward(request, response);
                  return;
              }
          }
          
          // Vérifier si le numéro a changé et s'il est déjà pris dans les deux tables
          if (!number.equals(currentNumber)) {
              if (valueExistsInBothTables(number, "number", iduser, conn)) {
                  request.setAttribute("registrationError", "Numéro de téléphone déjà utilisé");
                  request.getRequestDispatcher("gererclient.jsp").forward(request, response);
                  return;
              }
          }
          
          // Vérifier si un nouveau mot de passe a été saisi
          if (password != null && !password.trim().isEmpty()) {
              // Vérifier que le nouveau mot de passe et sa confirmation correspondent
              if (!password.equals(confirmPassword)) {
                  request.setAttribute("registrationError", "Les mots de passe ne correspondent pas");
                  request.getRequestDispatcher("gererclient.jsp").forward(request, response);
                  return;
              }
          } else {
              // Si aucun nouveau mot de passe saisi, conserver l'ancien
              password = currentPassword;
          }
      }
      
      // Si toutes les vérifications sont passées, mettre à jour l'utilisateur
      if (rs != null) rs.close();
      if (stmt != null) stmt.close();
      
      String sql = "UPDATE users SET firstname=?, lastname=?, username=?, email=?, number=?, password=? WHERE iduser=?";
      stmt = conn.prepareStatement(sql);
      stmt.setString(1, firstname);
      stmt.setString(2, lastname);
      stmt.setString(3, username);
      stmt.setString(4, email);
      stmt.setString(5, number);
      stmt.setString(6, password);
      stmt.setInt(7, iduser);
      
      int rows = stmt.executeUpdate();
      if(rows > 0){
          request.setAttribute("registerSuccess", "Client modifié avec succès");
          request.getRequestDispatcher("gererclient.jsp").forward(request, response);
      } else {
          request.setAttribute("registrationError", "Erreur lors de la modification du client");
          request.getRequestDispatcher("gererclient.jsp").forward(request, response);
      }
  } catch(Exception e){
      request.setAttribute("registrationError", "Erreur : " + e.getMessage());
      request.getRequestDispatcher("gererclient.jsp").forward(request, response);
  } finally {
      if(rs != null) try { rs.close(); } catch(SQLException ignore) {}
      if(stmt != null) try { stmt.close(); } catch(SQLException ignore) {}
      if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
  }
%>