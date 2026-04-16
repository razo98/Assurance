<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String marque = request.getParameter("marque");
    String url = "jdbc:mariadb://localhost:3306/assurance";
    String dbUser = "root";
    String dbPass = "";
    Connection conn = null;
    PreparedStatement stmt = null;
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        String sql = "INSERT INTO voiture (marque) VALUES (?)";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, marque);
        stmt.executeUpdate();
    } catch(Exception e) {
        out.println("Erreur lors de l'insertion : " + e.getMessage());
    } finally {
        if(stmt != null) try { stmt.close(); } catch(Exception ignore) {}
        if(conn != null) try { conn.close(); } catch(Exception ignore) {}
    }
    // Rediriger vers devis.jsp pour actualiser la liste des marques
    response.sendRedirect("admindevis.jsp");
%>
