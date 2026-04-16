<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Récupération des paramètres pour le client assuré
    String insuredFirstName = request.getParameter("insured_firstname");
    String insuredLastName = request.getParameter("insured_lastname");
    String insuredNumber = request.getParameter("insured_number");
    String matric = (String) session.getAttribute("matricule");
    
    // Récupération des paramètres de l'assurance
    int id_voiture = Integer.parseInt(request.getParameter("id_voiture"));
    int id_categorie = Integer.parseInt(request.getParameter("id_categorie"));
    String immatriculation = request.getParameter("immatriculation");
    String quartier = request.getParameter("quartier");
    int puissance = Integer.parseInt(request.getParameter("puissance"));
    int nombre_place = Integer.parseInt(request.getParameter("nombre_place"));
    int energie = Integer.parseInt(request.getParameter("energie"));  // 0 = Essence, 1 = Gazoil
    int nombre_mois = Integer.parseInt(request.getParameter("nombre_mois"));
    int valider = Integer.parseInt(request.getParameter("valider")); // 0=Non payé, 1=Payé

    // La date de début est saisie par l'admin (String)
    String newStartDateStr = request.getParameter("new_start_date");
    // On parse la chaîne en LocalDate
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    LocalDate newStartDate = LocalDate.parse(newStartDateStr, dtf);
    // Calcul de la date de fin : date début + nombre_mois - 1 jour
    LocalDate newEndDate = newStartDate.plusMonths(nombre_mois).minusDays(1);

    // Heure actuelle (pour le champ 'heure' dans la base)
    java.util.Date now = new java.util.Date();
    SimpleDateFormat sdfTime = new SimpleDateFormat("HH:mm:ss");
    String heure = sdfTime.format(now);

    // Récupération du nom complet de l'admin pour le champ "agents"
    String adminFullName = (String) session.getAttribute("fullname");
    
    double prix_ht = 0;
    double prix_ttc = 0;
    String genre = "";

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");

        // Récupérer le genre de la catégorie pour le calcul
        String sqlCat = "SELECT genre FROM categorie WHERE id_categorie = ?";
        stmt = conn.prepareStatement(sqlCat);
        stmt.setInt(1, id_categorie);
        rs = stmt.executeQuery();
        if(rs.next()){
            genre = rs.getString("genre");
        }
        rs.close();
        stmt.close();
        
        // Exemple de logique de calcul (pour "vp")
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
        // Autres conditions (taxiville_4P, etc.) si besoin

        // Insertion dans la table assurance
        // On fixe iduser=0, on remplit clients, telephone, agents
        String sqlIns = "INSERT INTO assurance " +
                        "(id_voiture, id_categorie, iduser, date_debut, date_fin, heure, immatriculation, quartier, puissance, nombre_place, energie, nombre_mois, prix_ht, prix_ttc, resiliation, suspension, valider, clients, telephone, agents,status,mode_paiement,code_transaction,matricule ) " +
                        "VALUES (?, ?, 0, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, ?, ?, ?, ?,?,?,?,?)";
        stmt = conn.prepareStatement(sqlIns);
        stmt.setInt(1, id_voiture);
        stmt.setInt(2, id_categorie);
        // date_debut et date_fin convertis en String
        stmt.setString(3, newStartDate.toString());   // "yyyy-MM-dd"
        stmt.setString(4, newEndDate.toString());     // "yyyy-MM-dd"
        stmt.setString(5, heure);
        stmt.setString(6, immatriculation);
        stmt.setString(7, quartier);
        stmt.setInt(8, puissance);
        stmt.setInt(9, nombre_place);
        stmt.setInt(10, energie);
        stmt.setInt(11, nombre_mois);
        stmt.setDouble(12, prix_ht);
        stmt.setDouble(13, prix_ttc);
        stmt.setInt(14, valider);
        // Champs client et agent
        stmt.setString(15, insuredFirstName + " " + insuredLastName);
        stmt.setString(16, insuredNumber);
        stmt.setString(17, adminFullName);
        stmt.setString(18, "active");
        stmt.setString(19, "ok");
        stmt.setString(20, "ok");
        stmt.setString(21, matric);

        int rows = stmt.executeUpdate();
        if(rows > 0){
            response.sendRedirect("adminaffichageassurance.jsp?updateSuccess=1");
        } else {
            out.println("Erreur lors de l'enregistrement.");
        }
    } catch(Exception e){
        out.println("Erreur : " + e.getMessage());
    } finally {
        if(rs != null) try { rs.close(); } catch(SQLException ignore){}
        if(stmt != null) try { stmt.close(); } catch(SQLException ignore){}
        if(conn != null) try { conn.close(); } catch(SQLException ignore){}
    }
%>
