<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.simple.*" %>
<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%
    // Récupérer les paramètres
    String dateDebut = request.getParameter("dateDebut");
    String dateFin = request.getParameter("dateFin");
    String typeAnalyse = request.getParameter("typeAnalyse");
    String agentId = request.getParameter("agentId");
    String categorieId = request.getParameter("categorieId");
    
    // Initialiser la réponse JSON
    JSONObject responseJson = new JSONObject();
    JSONArray dataArray = new JSONArray();
    
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
        
        // Construction de la requête SQL en fonction du type d'analyse
        String query = "";
        
        if ("agent".equals(typeAnalyse)) {
            query = "SELECT ad.idadmin, CONCAT(ad.firstname, ' ', ad.lastname) as nom, " +
                   "COUNT(a.id_assurance) as count, SUM(a.prix_ttc) as montant " +
                   "FROM assurance a " +
                   "JOIN admins ad ON a.matricule = ad.matricule " +
                   "WHERE 1=1 ";
                   
            if (dateDebut != null && !dateDebut.isEmpty()) {
                query += "AND a.date_debut >= ? ";
            }
            
            if (dateFin != null && !dateFin.isEmpty()) {
                query += "AND a.date_debut <= ? ";
            }
            
            if (categorieId != null && !categorieId.isEmpty() && !categorieId.equals("all")) {
                query += "AND a.id_categorie = ? ";
            }
            
            query += "GROUP BY ad.idadmin, ad.firstname, ad.lastname ORDER BY count DESC";
            
        } else if ("categorie".equals(typeAnalyse)) {
            query = "SELECT c.id_categorie, c.genre as nom, " +
                   "COUNT(a.id_assurance) as count, SUM(a.prix_ttc) as montant " +
                   "FROM assurance a " +
                   "JOIN categorie c ON a.id_categorie = c.id_categorie " +
                   "WHERE 1=1 ";
                   
            if (dateDebut != null && !dateDebut.isEmpty()) {
                query += "AND a.date_debut >= ? ";
            }
            
            if (dateFin != null && !dateFin.isEmpty()) {
                query += "AND a.date_debut <= ? ";
            }
            
            if (agentId != null && !agentId.isEmpty() && !agentId.equals("all")) {
                query += "AND EXISTS (SELECT 1 FROM admins ad WHERE a.matricule = ad.matricule AND ad.idadmin = ?) ";
            }
            
            query += "GROUP BY c.id_categorie, c.genre ORDER BY count DESC";
            
        } else { // temps
            query = "SELECT DATE_FORMAT(a.date_debut, '%Y-%m') as month, " +
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
                   "COUNT(a.id_assurance) as count, SUM(a.prix_ttc) as montant " +
                   "FROM assurance a " +
                   "WHERE 1=1 ";
                   
            if (dateDebut != null && !dateDebut.isEmpty()) {
                query += "AND a.date_debut >= ? ";
            }
            
            if (dateFin != null && !dateFin.isEmpty()) {
                query += "AND a.date_debut <= ? ";
            }
            
            if (agentId != null && !agentId.isEmpty() && !agentId.equals("all")) {
                query += "AND EXISTS (SELECT 1 FROM admins ad WHERE a.matricule = ad.matricule AND ad.idadmin = ?) ";
            }
            
            if (categorieId != null && !categorieId.isEmpty() && !categorieId.equals("all")) {
                query += "AND a.id_categorie = ? ";
            }
            
            query += "GROUP BY month, date ORDER BY month ASC";
        }
        
        stmt = conn.prepareStatement(query);
        
        // Définir les paramètres
        int paramIndex = 1;
        if (dateDebut != null && !dateDebut.isEmpty()) {
            stmt.setString(paramIndex++, dateDebut);
        }
        
        if (dateFin != null && !dateFin.isEmpty()) {
            stmt.setString(paramIndex++, dateFin);
        }
        
        if ("agent".equals(typeAnalyse)) {
            if (categorieId != null && !categorieId.isEmpty() && !categorieId.equals("all")) {
                stmt.setString(paramIndex++, categorieId);
            }
        } else if ("categorie".equals(typeAnalyse)) {
            if (agentId != null && !agentId.isEmpty() && !agentId.equals("all")) {
                stmt.setString(paramIndex++, agentId);
            }
        } else { // temps
            if (agentId != null && !agentId.isEmpty() && !agentId.equals("all")) {
                stmt.setString(paramIndex++, agentId);
            }
            
            if (categorieId != null && !categorieId.isEmpty() && !categorieId.equals("all")) {
                stmt.setString(paramIndex++, categorieId);
            }
        }
        
        rs = stmt.executeQuery();
        
        while (rs.next()) {
            JSONObject item = new JSONObject();
            
            if ("agent".equals(typeAnalyse)) {
                item.put("id", rs.getInt("idadmin"));
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
            
            dataArray.add(item);
        }
        
        responseJson.put("data", dataArray);
        
    } catch (Exception e) {
        // Gestion des erreurs détaillée
        JSONObject error = new JSONObject();
        error.put("error", e.getMessage());
        error.put("stackTrace", e.getStackTrace()[0].toString());
        out.println(error.toJSONString());
        return;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
    
    // Renvoyer la réponse JSON
    out.println(responseJson.toJSONString());
%>