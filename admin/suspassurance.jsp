<%@ page import="java.sql.*, java.time.LocalDate" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
int id = Integer.parseInt(request.getParameter("id"));
String status = "suspendu";
Connection conn = null;
PreparedStatement ps = null;
try {
    Class.forName("org.mariadb.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
    String sql = "UPDATE assurance SET suspension = 1, datesus = ? , status = ? WHERE id_assurance = ?";
    ps = conn.prepareStatement(sql);
    ps.setDate(1, Date.valueOf(LocalDate.now()));
    ps.setInt(3, id);
    ps.setString(2,status);
    ps.executeUpdate();
    response.sendRedirect("adminaffichageassurance.jsp?msg=Suspendue avec succès");
} catch(Exception e) {
    out.println("Erreur : " + e.getMessage());
} finally {
    if(ps != null) ps.close();
    if(conn != null) conn.close();
}
%>