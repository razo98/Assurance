<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Récupération des paramètres
    String id_voitureStr = request.getParameter("id_voiture");
    String marque = request.getParameter("marque");
    
    if(id_voitureStr == null || marque == null) {
        out.println("Paramètres manquants.");
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
        String sql = "UPDATE voiture SET marque = ? WHERE id_voiture = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, marque);
        stmt.setInt(2, id_voiture);
        int rows = stmt.executeUpdate();
        if(rows > 0){
            response.sendRedirect("gerervoitures.jsp?updateSuccess=1");
        } else {
            out.println("Erreur lors de la modification.");
        }
    } catch(Exception e){
        out.println("Erreur : " + e.getMessage());
    } finally {
        if(stmt != null) stmt.close();
        if(conn != null) conn.close();
    }
%>
