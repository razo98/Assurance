<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String id_voitureStr = request.getParameter("id_voiture");
    if(id_voitureStr == null) {
        out.println("Paramètre manquant.");
        return;
    }
    int id_voiture = Integer.parseInt(id_voitureStr);
    
    String url = "jdbc:mariadb://localhost:3306/assurance";
    String dbUser = "root";
    String dbPass = "";
    Connection conn = null;
    PreparedStatement stmt = null;
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        String sql = "DELETE FROM voiture WHERE id_voiture = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, id_voiture);
        int rows = stmt.executeUpdate();
        if(rows > 0){
            response.sendRedirect("gerervoitures.jsp?deleteSuccess=1");
        } else {
            out.println("Erreur lors de la suppression.");
        }
    } catch(Exception e){
        out.println("Erreur : " + e.getMessage());
    } finally {
        if(stmt != null) stmt.close();
        if(conn != null) conn.close();
    }
%>
