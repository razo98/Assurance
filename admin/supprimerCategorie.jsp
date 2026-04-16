<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String id_categorieStr = request.getParameter("id_categorie");
    if(id_categorieStr == null) {
        out.println("Paramètre manquant.");
        return;
    }
    int id_categorie = Integer.parseInt(id_categorieStr);
    
    String url = "jdbc:mariadb://localhost:3306/assurance";
    String dbUser = "root";
    String dbPass = "";
    Connection conn = null;
    PreparedStatement stmt = null;
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPass);
        String sql = "DELETE FROM categorie WHERE id_categorie = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, id_categorie);
        int rows = stmt.executeUpdate();
        if(rows > 0){
            response.sendRedirect("gerercategories.jsp?deleteSuccess=1");
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
