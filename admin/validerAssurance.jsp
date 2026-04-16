<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
   Integer idadmin = (Integer) session.getAttribute("idadmin");
   String firstname = (String) session.getAttribute("firstname");
   String lastname = (String) session.getAttribute("lastname");
   String fullName = (String) session.getAttribute("fullname");
   String role = (String) session.getAttribute("role");
   String matric = (String) session.getAttribute("matricule");
   if(idadmin == null || role == null || !"soleil".equals(role)) {
      response.sendRedirect("../login.jsp");
      return;
   }
   
   // Récupérer l'ID de l'assurance à valider
   String idStr = request.getParameter("id");
   if(idStr == null || idStr.trim().isEmpty()){
      out.println("ID assurance non fourni.");
      return;
   }
   int assuranceId = Integer.parseInt(idStr);
   String status = "Actif"; 
   Connection conn = null;
   PreparedStatement stmt = null;
   try {
      Class.forName("org.mariadb.jdbc.Driver");
      conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
      // Mise à jour de l'assurance : valider à 1, et mettre à jour les champs agents et matricule
      String sql = "UPDATE assurance SET valider = 1, agents = ?, matricule = ?,status = ? WHERE id_assurance = ?";
      stmt = conn.prepareStatement(sql);
      stmt.setString(1, fullName);
      stmt.setString(2, matric);
      stmt.setString(3, status);
      stmt.setInt(4, assuranceId);
      
      int rows = stmt.executeUpdate();
      if(rows > 0){
         response.sendRedirect("adminaffichageassurance.jsp?updateSuccess=1");
      } else {
         out.println("Aucune mise à jour effectuée. Vérifiez l'ID de l'assurance.");
      }
   } catch(Exception e) {
      out.println("Erreur : " + e.getMessage());
   } finally {
      if(stmt != null) try { stmt.close(); } catch(SQLException ignore) {}
      if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
   }
%>