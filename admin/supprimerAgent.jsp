<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String idStr = request.getParameter("idadmin");
  int idadmin = Integer.parseInt(idStr);

  Connection conn = null;
  PreparedStatement stmt = null;
  try {
      Class.forName("org.mariadb.jdbc.Driver");
      conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
      String sql = "DELETE FROM admins WHERE idadmin=?";
      stmt = conn.prepareStatement(sql);
      stmt.setInt(1, idadmin);
      int rows = stmt.executeUpdate();
      if(rows > 0){
          response.sendRedirect("gererAgents.jsp");
      } else {
          out.println("Erreur lors de la suppression de l'agent.");
      }
  } catch(Exception e){
      out.println("Erreur : " + e.getMessage());
  } finally {
      if(stmt != null) stmt.close();
      if(conn != null) conn.close();
  }
%>
