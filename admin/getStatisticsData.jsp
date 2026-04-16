<%@ page import="java.sql.*" %>
<%@ page import="org.json.*" %>
<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%
    // Récupérer les paramètres de filtre
    String dateDebut = request.getParameter("dateDebut");
    String dateFin = request.getParameter("dateFin");
    String typeAnalyse = request.getParameter("typeAnalyse");
    String agentId = request.getParameter("agentId");
    String categorieId = request.getParameter("categorieId");
    
    // Initialiser les objets JSON
    JSONObject responseJson = new JSONObject();
    JSONArray dataArray = new JSONArray();
    
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
        
        // Construction de la base de la requête SQL
        StringBuilder baseQuery = new StringBuilder();
        baseQuery.append("SELECT a.*, ad.id_admin, ad.firstname, ad.lastname, c.genre ");
        baseQuery.append("FROM assurance a ");
        baseQuery.append("JOIN admins ad ON a.matricule = ad.matricule ");
        baseQuery.append("JOIN categorie c ON a.id_categorie = c.id_categorie ");
        baseQuery.append("WHERE 1=1 ");
        
        // Ajouter les conditions de filtrage
        if (dateDebut != null && !dateDebut.isEmpty()) {
            baseQuery.append("AND a.date_debut >= ? ");
        }
        
        if (dateFin != null && !dateFin.isEmpty()) {
            baseQuery.append("AND a.date_debut <= ? ");
        }
        
        if (agentId != null && !agentId.isEmpty() && !agentId.equals("all")) {
            baseQuery.append("AND ad.id_admin = ? ");
        }
        
        if (categorieId != null && !categorieId.isEmpty() && !categorieId.equals("all")) {
            baseQuery.append("AND a.id_categorie = ? ");
        }
        
        // Déterminer la requête finale selon le type d'analyse
        String finalQuery = "";
        if ("agent".equals(typeAnalyse)) {
            finalQuery = "SELECT ad.id_admin, CONCAT(ad.firstname, ' ', ad.lastname) as nom, COUNT(*) as count, SUM(a.prix_ttc) as montant " +
                        "FROM (" + baseQuery.toString() + ") as filtered " +
                        "GROUP BY ad.id_admin, ad.firstname, ad.lastname " +
                        "ORDER BY count DESC";
        }else if ("categorie".equals(typeAnalyse)) {
            finalQuery = "SELECT c.id_categorie, c.genre as nom, COUNT(*) as count, SUM(a.prix_ttc) as montant " +
                         "FROM (" + baseQuery.toString() + ") as filtered " +
                         "GROUP BY c.id_categorie, c.genre " +
                         "ORDER BY count DESC";
        } else { // temps
            finalQuery = "SELECT DATE_FORMAT(a.date_debut, '%Y-%m') as month, " +
                         "CONCAT(CASE MONTH(a.date_debut) " +
                         "WHEN 1 THEN 'Janvier' " +
                         "WHEN 2 THEN 'Février' " +
                         "WHEN 3 THEN 'Mars' " +
                         "WHEN 4 THEN 'Avril' " +
                         "WHEN 5 THEN 'Mai' " +
                         "WHEN 6 THEN 'Juin' " +
                         "WHEN 7 THEN 'Juillet' " +
                         "WHEN 8 THEN 'Août' " +
                         "WHEN 9 THEN 'Septembre' " +
                         "WHEN 10 THEN 'Octobre' " +
                         "WHEN 11 THEN 'Novembre' " +
                         "WHEN 12 THEN 'Décembre' " +
                         "END, ' ', YEAR(a.date_debut)) as date, " +
                         "COUNT(*) as count, SUM(a.prix_ttc) as montant " +
                         "FROM (" + baseQuery.toString() + ") as filtered " +
                         "GROUP BY month " +
                         "ORDER BY month ASC";
        }
        
        stmt = conn.prepareStatement(finalQuery);
        
        int paramIndex = 1;
        if (dateDebut != null && !dateDebut.isEmpty()) {
            stmt.setString(paramIndex++, dateDebut);
        }
        
        if (dateFin != null && !dateFin.isEmpty()) {
            stmt.setString(paramIndex++, dateFin);
        }
        
        if (agentId != null && !agentId.isEmpty() && !agentId.equals("all")) {
            stmt.setString(paramIndex++, agentId);
        }
        
        if (categorieId != null && !categorieId.isEmpty() && !categorieId.equals("all")) {
            stmt.setString(paramIndex++, categorieId);
        }
        
        rs = stmt.executeQuery();
        
        while (rs.next()) {
            JSONObject item = new JSONObject();
            
            if ("agent".equals(typeAnalyse)) {
                item.put("id", rs.getInt("id_admin"));
                item.put("nom", rs.getString("nom"));
                item.put("count", rs.getInt("count"));
                item.put("montant", rs.getDouble("montant"));
            } else if ("categorie".equals(typeAnalyse)) {
                item.put("id", rs.getInt("id_categorie"));
                item.put("nom", rs.getString("nom"));
                item.put("count", rs.getInt("count"));
                item.put("montant", rs.getDouble("montant"));
            } else { // temps
                item.put("date", rs.getString("date"));
                item.put("count", rs.getInt("count"));
                item.put("montant", rs.getDouble("montant"));
            }
            
            dataArray.put(item);
        }
        
    } catch (Exception e) {
        // En cas d'erreur, renvoyer un message d'erreur
        response.setStatus(500);
        JSONObject error = new JSONObject();
        error.put("error", e.getMessage());
        out.print(error.toString());
        return;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
    
    // Ajouter les données à l'objet de réponse
    responseJson.put("data", dataArray);
    
    // Renvoyer la réponse JSON
    out.print(responseJson.toString());
%>