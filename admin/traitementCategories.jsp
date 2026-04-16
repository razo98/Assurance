<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String genre = request.getParameter("genre");
  String url = "jdbc:mariadb://localhost:3306/assurance";
  String dbUser = "root";
  String dbPass = "";
  Connection conn = null;
  PreparedStatement stmt = null;
  
  try {
      Class.forName("org.mariadb.jdbc.Driver");
      conn = DriverManager.getConnection(url, dbUser, dbPass);
      String sql = "INSERT INTO categorie (genre) VALUES (?)";
      stmt = conn.prepareStatement(sql);
      stmt.setString(1, genre);
      int rows = stmt.executeUpdate();
      if(rows > 0){
          response.sendRedirect("gerercategories.jsp?success=1");
      } else {
          out.println("Erreur lors de l'insertion.");
      }
  } catch(Exception e) {
      out.println("Erreur : " + e.getMessage());
  } finally {
      if(stmt != null) stmt.close();
      if(conn != null) conn.close();
  }
%>
