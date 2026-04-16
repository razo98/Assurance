<%@ page import="java.sql.*, java.time.*, java.time.temporal.ChronoUnit" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
int id = Integer.parseInt(request.getParameter("id"));
Connection conn = null;
PreparedStatement ps = null, psSelect = null;
ResultSet rs = null;
String status = "Actif";
try {
    Class.forName("org.mariadb.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");

    String select = "SELECT datesus, date_fin FROM assurance WHERE id_assurance = ?";
    psSelect = conn.prepareStatement(select);
    psSelect.setInt(1, id);
    rs = psSelect.executeQuery();
    if(rs.next()) {
        LocalDate datesus = rs.getDate("datesus").toLocalDate();
        LocalDate dateFin = rs.getDate("date_fin").toLocalDate();
        LocalDate datereact = LocalDate.now();
        long jours = ChronoUnit.DAYS.between(datesus, datereact);
        long bonus = Math.round(jours * 0.75);
        LocalDate newFin = dateFin.plusDays(bonus);

        String update = "UPDATE assurance SET suspension = 0, datereact = ?, date_fin = ?,status = ? WHERE id_assurance = ?";
        ps = conn.prepareStatement(update);
        ps.setDate(1, Date.valueOf(datereact));
        ps.setDate(2, Date.valueOf(newFin));
        ps.setString(3,status);
        ps.setInt(4, id);
        ps.executeUpdate();
        response.sendRedirect("agentaffichageassurance.jsp?msg=Reprise effectuée avec succès");
    }
} catch(Exception e) {
    out.println("Erreur : " + e.getMessage());
} finally {
    if(rs != null) rs.close();
    if(psSelect != null) psSelect.close();
    if(ps != null) ps.close();
    if(conn != null) conn.close();
}
%>