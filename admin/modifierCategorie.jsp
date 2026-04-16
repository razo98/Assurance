<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String id_categorieStr = request.getParameter("id_categorie");
    String genre = request.getParameter("genre");
    
    if(id_categorieStr == null || genre == null) {
        out.println("Paramètres manquants.");
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
        String sql = "UPDATE categorie SET genre = ? WHERE id_categorie = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setString(1, genre);
        stmt.setInt(2, id_categorie);
        int rows = stmt.executeUpdate();
        if(rows > 0){
            response.sendRedirect("gerercategories.jsp?updateSuccess=1");
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
