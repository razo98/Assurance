<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Récupération des paramètres envoyés par le formulaire du modal de renouvellement
    int oldAssuranceId = Integer.parseInt(request.getParameter("old_assurance_id"));
    String newStartDateStr = request.getParameter("new_start_date");
    int nombre_mois = Integer.parseInt(request.getParameter("new_months"));
    String fullName = (String) session.getAttribute("fullname");
    
    // Récupération des autres informations de l'assurance via les champs cachés
    int id_voiture = Integer.parseInt(request.getParameter("id_voiture"));
    int id_categorie = Integer.parseInt(request.getParameter("id_categorie"));
    int iduser = Integer.parseInt(request.getParameter("iduser"));
    String heure = request.getParameter("heure");
    String telephone = request.getParameter("telephone");
    String immatriculation = request.getParameter("immatriculation");
    String quartier = request.getParameter("quartier");
    int puissance = Integer.parseInt(request.getParameter("puissance"));
    int nombre_place = Integer.parseInt(request.getParameter("nombre_place"));
    int energie = Integer.parseInt(request.getParameter("energie")); // 0 = Essence, 1 = Gazoil
    int resiliation = Integer.parseInt(request.getParameter("resiliation"));
    int suspension = Integer.parseInt(request.getParameter("suspension"));
    String status = "En attente";
    String mode = request.getParameter("mode_paiement"); 
    String code = request.getParameter("code_transaction"); 
    
    // Conversion de la nouvelle date de début (yyyy-MM-dd) et calcul de la nouvelle date de fin
    LocalDate newStartDate = LocalDate.parse(newStartDateStr, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    // On retranche 1 jour après avoir ajouté newMonths
    LocalDate newEndDate = newStartDate.plusMonths(nombre_mois).minusDays(1);
    
    // Recalcul du prix HT et TTC en fonction des règles (similaires à celles du devis)
    double prix_ht = 0;
    double prix_ttc = 0;
    String genre = "";
    
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
        
        // Récupérer le genre de la catégorie
        String sqlCat = "SELECT genre FROM categorie WHERE id_categorie = ?";
        stmt = conn.prepareStatement(sqlCat);
        stmt.setInt(1, id_categorie);
        rs = stmt.executeQuery();
        if(rs.next()){
            genre = rs.getString("genre");
        }
        rs.close();
        stmt.close();
        
        // Exemple de conditions de calcul pour "vp" (à adapter si besoin)
         if("vp".equalsIgnoreCase(genre)) {
            if (nombre_mois == 3) {
                
            
            if((energie == 0 && puissance >= 3 && puissance <= 6)||(energie == 1 && puissance >= 2 && puissance <= 4)) {
                prix_ht = 13080;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 7 && puissance <= 10)||(energie == 1 && puissance >= 5 && puissance <= 7)) {
                prix_ht = 14852;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 11 && puissance <= 14)||(energie == 1 && puissance >= 8 && puissance <= 10)) {
                prix_ht = 19195;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 15 && puissance <= 23)||(energie == 1 && puissance >= 11 && puissance <= 16)) {
                prix_ht = 25483;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 23 )||(energie == 1 && puissance >= 17 )) {
                prix_ht = 31066;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }

        }else if (nombre_mois == 6) {

            if((energie == 0 && puissance >= 3 && puissance <= 6)||(energie == 1 && puissance >= 2 && puissance <= 4)) {
                prix_ht = 25660;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 7 && puissance <= 10)||(energie == 1 && puissance >= 5 && puissance <= 7)) {
                prix_ht = 29204;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 11 && puissance <= 14)||(energie == 1 && puissance >= 8 && puissance <= 10)) {
                prix_ht = 37890;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 15 && puissance <= 23)||(energie == 1 && puissance >= 11 && puissance <= 16)) {
                prix_ht = 50466;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 23 )||(energie == 1 && puissance >= 17 )) {
                prix_ht = 61633;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
        }
        else if (nombre_mois == 12) {

            if((energie == 0 && puissance >= 3 && puissance <= 6)||(energie == 1 && puissance >= 2 && puissance <= 4)) {
                prix_ht = 42433;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 7 && puissance <= 10)||(energie == 1 && puissance >= 5 && puissance <= 7)) {
                prix_ht = 48340;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 11 && puissance <= 14)||(energie == 1 && puissance >= 8 && puissance <= 10)) {
                prix_ht = 62817;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 15 && puissance <= 23)||(energie == 1 && puissance >= 11 && puissance <= 16)) {
                prix_ht = 83777;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 23 )||(energie == 1 && puissance >= 17 )) {
                prix_ht = 102388;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
        }
        } else if("taxiville_4P".equalsIgnoreCase(genre)) {
            if (nombre_mois == 3) {
                
            
            if((energie == 0 && puissance >= 3 && puissance <= 6)||(energie == 1 && puissance >= 2 && puissance <= 4)) {
                prix_ht = 28834;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 7 && puissance <= 10)||(energie == 1 && puissance >= 5 && puissance <= 7)) {
                prix_ht = 34138;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 11 && puissance <= 14)||(energie == 1 && puissance >= 8 && puissance <= 10)) {
                prix_ht = 48313;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
           

        }else if (nombre_mois == 6) {

            if((energie == 0 && puissance >= 3 && puissance <= 6)||(energie == 1 && puissance >= 2 && puissance <= 4)) {
                prix_ht = 57667;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 7 && puissance <= 10)||(energie == 1 && puissance >= 5 && puissance <= 7)) {
                prix_ht = 67775;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 11 && puissance <= 14)||(energie == 1 && puissance >= 8 && puissance <= 10)) {
                prix_ht = 96125;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            
        }
        else if (nombre_mois == 12) {

            if((energie == 0 && puissance >= 3 && puissance <= 6)||(energie == 1 && puissance >= 2 && puissance <= 4)) {
                prix_ht = 71389;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 7 && puissance <= 10)||(energie == 1 && puissance >= 5 && puissance <= 7)) {
                prix_ht = 84200;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 11 && puissance <= 14)||(energie == 1 && puissance >= 8 && puissance <= 10)) {
                prix_ht = 122000;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
           
        }
        }else if("moto".equalsIgnoreCase(genre)) {
            if (nombre_mois == 3) {
                
            
            if( puissance == 0 ) {
                prix_ht = 4044;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if( puissance == 1 ) {
                prix_ht = 7588;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if( puissance >= 2 && puissance <=3 ) {
                prix_ht = 13789;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
           

        }else if (nombre_mois == 6) {

            if( puissance == 0 ) {
                prix_ht = 7587;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if( puissance == 1 ) {
                prix_ht = 14675;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if( puissance >= 2 && puissance <=3 ) {
                prix_ht = 27078;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            
        }
        else if (nombre_mois == 12) {

            if( puissance == 0 ) {
                prix_ht = 12312;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if( puissance == 1 ) {
                prix_ht = 24125;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if( puissance >= 2 && puissance <=3) {
                prix_ht = 44796;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
           
        }
        }
        else if("taxiville_19P".equalsIgnoreCase(genre)) {
            if (nombre_mois == 3) {
                
           
            if((energie == 0 && puissance >= 7 && puissance <= 10)||(energie == 1 && puissance >= 5 && puissance <= 7)) {
                prix_ht = 67834;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 11 && puissance <= 14)||(energie == 1 && puissance >= 8 && puissance <= 10)) {
                prix_ht = 82063;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
           

        }else if (nombre_mois == 6) {

            if((energie == 0 && puissance >= 7 && puissance <= 10)||(energie == 1 && puissance >= 5 && puissance <= 7)) {
                prix_ht = 135275;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 11 && puissance <= 14)||(energie == 1 && puissance >= 8 && puissance <= 10)) {
                prix_ht = 163625;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            
        }
        else if (nombre_mois == 12) {

            if((energie == 0 && puissance >= 7 && puissance <= 10)||(energie == 1 && puissance >= 5 && puissance <= 7)) {
                prix_ht = 186200;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
            else if((energie == 0 && puissance >= 11 && puissance <= 14)||(energie == 1 && puissance >= 8 && puissance <= 10)) {
                prix_ht = 218000;
                prix_ttc = prix_ht * 1.12 + 300; // TVA de 12% + 300
            }
           
        }
        }
        // Ajouter d'autres conditions (taxiville_4P, etc.) si besoin
        
        // Insertion d'une nouvelle assurance (renouvellement)
        String sqlIns = "INSERT INTO assurance " +
                        "(id_voiture, id_categorie, iduser, date_debut, date_fin, heure, immatriculation, quartier, puissance, nombre_place, energie, nombre_mois, prix_ht, prix_ttc, resiliation, suspension, valider,status,mode_paiement,code_transaction,clients,telephone) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,0,?,?,?,?,?)";
        stmt = conn.prepareStatement(sqlIns);
        stmt.setInt(1, id_voiture);
        stmt.setInt(2, id_categorie);
        stmt.setInt(3, iduser);
        stmt.setString(4, newStartDate.toString());
        stmt.setString(5, newEndDate.toString());
        stmt.setString(6, heure);
        stmt.setString(7, immatriculation);
        stmt.setString(8, quartier);
        stmt.setInt(9, puissance);
        stmt.setInt(10, nombre_place);
        stmt.setInt(11, energie);
        stmt.setInt(12, nombre_mois);
        stmt.setDouble(13, prix_ht);
        stmt.setDouble(14, prix_ttc);
        stmt.setInt(15, resiliation);
        stmt.setInt(16, suspension);
        stmt.setString(17, status);
        stmt.setString(18, mode);
        stmt.setString(19, code);
        stmt.setString(20, fullName);
        stmt.setString(21, telephone);
        
        int rowsInserted = stmt.executeUpdate();
        if(rowsInserted > 0) {
            // Rediriger vers la page d'affichage des assurances
            response.sendRedirect("affichageassurance.jsp?success=1");
        } else {
            response.sendRedirect("renouvellementclient.jsp?error=1");
        }
    } catch(Exception e) {
        out.println("Erreur : " + e.getMessage());
    } finally {
        if(rs != null) rs.close();
        if(stmt != null) stmt.close();
        if(conn != null) conn.close();
    }
%>
