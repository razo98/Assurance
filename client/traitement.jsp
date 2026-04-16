<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    int id_voiture = Integer.parseInt(request.getParameter("id_voiture"));
    int id_categorie = Integer.parseInt(request.getParameter("id_categorie"));
    int iduser = Integer.parseInt(request.getParameter("iduser"));
    String immatriculation = request.getParameter("immatriculation");
    String quartier = request.getParameter("quartier");
    int puissance = Integer.parseInt(request.getParameter("puissance"));
    int nombre_place = Integer.parseInt(request.getParameter("nombre_place"));
    int energie = Integer.parseInt(request.getParameter("energie"));  // 0 = Essence, 1 = Gazoil
    int nombre_mois = Integer.parseInt(request.getParameter("nombre_mois"));

    // Nouveaux champs récupérés depuis le formulaire
    String clients = request.getParameter("clients");      // Nom & prénom du client
    String telephone = request.getParameter("telephone");  // Téléphone du client
    String date_debut = request.getParameter("date_debut");  // Date début choisie
    String mode = request.getParameter("mode_paiement"); 
    String code = request.getParameter("code_transaction"); 

    double prix_ht = 0;
    double prix_ttc = 0;
    String status = "En attente";
    
    // Récupération de l'heure actuelle
    java.util.Date now = new java.util.Date();
    SimpleDateFormat sdfTime = new SimpleDateFormat("HH:mm:ss");
    String heure = sdfTime.format(now);
    
    // Calcul de la date de fin en ajoutant le nombre de mois à la date_debut (en convertissant date_debut)
    LocalDate startDate = LocalDate.parse(date_debut);
    LocalDate endDate = startDate.plusMonths(nombre_mois).minusDays(1);
    String date_fin = endDate.toString();

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
        String genre = "";
        if(rs.next()){
            genre = rs.getString("genre");
        }
        rs.close();
        stmt.close();
        
        // Nouvelle règle de calcul pour le devis (exemple pour genre "vp")

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
        // Vous pouvez ajouter d'autres conditions pour d'autres genres si nécessaire.
        
        // Insertion dans la base de données
        // On insère dans la table assurance les nouveaux champs "clients" et "telephone" (mis à jour par l'utilisateur)
        // et on laisse le champ "agents" à NULL (ou valeur par défaut).
        String sqlIns = "INSERT INTO assurance (id_voiture, id_categorie, iduser, date_debut, date_fin, heure, immatriculation, quartier, puissance, nombre_place, energie, nombre_mois, prix_ht, prix_ttc, resiliation, suspension, valider, clients, telephone, agents,status,mode_paiement,code_transaction) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 0, ?, ?, NULL,?,?,?)";
        stmt = conn.prepareStatement(sqlIns);
        stmt.setInt(1, id_voiture);
        stmt.setInt(2, id_categorie);
        stmt.setInt(3, iduser);
        stmt.setString(4, date_debut);
        stmt.setString(5, date_fin);
        stmt.setString(6, heure);
        stmt.setString(7, immatriculation);
        stmt.setString(8, quartier);
        stmt.setInt(9, puissance);
        stmt.setInt(10, nombre_place);
        stmt.setInt(11, energie);
        stmt.setInt(12, nombre_mois);
        stmt.setDouble(13, prix_ht);
        stmt.setDouble(14, prix_ttc);
        // Champs supplémentaires pour les informations client
        stmt.setString(15, clients);
        stmt.setString(16, telephone);
        stmt.setString(17, status);
        stmt.setString(18, mode);
        stmt.setString(19, code);
        
        int rows = stmt.executeUpdate();
        if(rows > 0){
            response.sendRedirect("affichageassurance.jsp?updateSuccess=1");
        } else {
            out.println("Erreur lors de l'enregistrement.");
        }
    } catch(Exception e){
        out.println("Erreur : " + e.getMessage());
    } finally {
        if(rs != null) try { rs.close(); } catch(SQLException ignore) {}
        if(stmt != null) try { stmt.close(); } catch(SQLException ignore) {}
        if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
    }
%>
