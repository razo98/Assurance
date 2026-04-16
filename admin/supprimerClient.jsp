<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String idStr = request.getParameter("iduser");
  int iduser = Integer.parseInt(idStr);

  Connection conn = null;
  PreparedStatement stmt = null;
  try {
      Class.forName("org.mariadb.jdbc.Driver");
      conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
      String sql = "DELETE FROM users WHERE iduser=?";
      stmt = conn.prepareStatement(sql);
      stmt.setInt(1, iduser);
      int rows = stmt.executeUpdate();
      if(rows > 0){
          response.sendRedirect("gererclient.jsp");
      } else {
          out.println("Erreur lors de la suppression du client.");
      }
  } catch(Exception e){
      out.println("Erreur : " + e.getMessage());
  } finally {
      if(stmt != null) stmt.close();
      if(conn != null) conn.close();
  }
%>
