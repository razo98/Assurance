<%@ page import="java.sql.*, java.time.LocalDate" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Vérifier que l'agent est connecté
    Integer idadmin = (Integer) session.getAttribute("idadmin");
    String agentFullName = (String) session.getAttribute("fullname");
    String agentMatricule = (String) session.getAttribute("matricule");
    if (idadmin == null) {
        response.sendRedirect("../loginadmin.jsp");
        return;
    }

    // Récupération des paramètres envoyés par le formulaire de renouvellement (modal)
    String idAssuranceStr = request.getParameter("id_assurance");
    String newDateDebutStr = request.getParameter("new_date_debut");
    String nombre_moi = request.getParameter("new_nombre_mois");

    if (idAssuranceStr == null || newDateDebutStr == null || nombre_moi == null) {
        out.println("Paramètres manquants.");
        return;
    }

    int idAssurance = Integer.parseInt(idAssuranceStr);
    int nombre_mois = Integer.parseInt(nombre_moi);
    LocalDate newDateDebut = LocalDate.parse(newDateDebutStr);
    LocalDate newDateFin = newDateDebut.plusMonths(nombre_mois).minusDays(1);

    // Variables à récupérer depuis l'ancienne assurance
    int clientId = 0;
    String clients = "";
    String telephone = "";
    String immatriculation = "";
    int id_voiture = 0;
    int id_categorie = 0;
    int puissance = 0;
    int nombre_place = 0;
    int energie = 0;
    String quartier = "";
    // Variable pour récupérer le genre depuis la table categorie
    String genre = "";

    // Variables pour les prix
    double prix_ht = 0;
    double prix_ttc = 0;

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    String status = "Actif";

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");

        // Récupérer l'ancien enregistrement de l'assurance
        String sqlSelect = "SELECT * FROM assurance WHERE id_assurance = ?";
        stmt = conn.prepareStatement(sqlSelect);
        stmt.setInt(1, idAssurance);
        rs = stmt.executeQuery();
        if (rs.next()) {
            clientId = rs.getInt("iduser"); // Conserve le client d'origine
            clients = rs.getString("clients");
            telephone = rs.getString("telephone");
            immatriculation = rs.getString("immatriculation");
            id_voiture = rs.getInt("id_voiture");
            id_categorie = rs.getInt("id_categorie");
            puissance = rs.getInt("puissance");
            nombre_place = rs.getInt("nombre_place");
            energie = rs.getInt("energie");
            quartier = rs.getString("quartier");
        } else {
            out.println("Aucune assurance trouvée.");
            return;
        }
        rs.close();
        stmt.close();

        // Récupérer le genre à partir de la table categorie via id_categorie
        String sqlCat = "SELECT genre FROM categorie WHERE id_categorie = ?";
        stmt = conn.prepareStatement(sqlCat);
        stmt.setInt(1, id_categorie);
        rs = stmt.executeQuery();
        if(rs.next()){
            genre = rs.getString("genre");
        }
        rs.close();
        stmt.close();

        // Obtenir l'heure actuelle
        java.util.Date now = new java.util.Date();
        java.text.SimpleDateFormat sdfTime = new java.text.SimpleDateFormat("HH:mm:ss");
        String heure = sdfTime.format(now);

        // Calcul des prix selon le genre
        // Exemple pour genre "vp" ; adaptez les conditions pour les autres genres
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
        
        // Insertion de la nouvelle assurance renouvelée (nouvelle ligne)
        String sqlInsert = "INSERT INTO assurance (id_voiture, id_categorie, iduser, date_debut, date_fin, heure, immatriculation, quartier, puissance, nombre_place, energie, nombre_mois, prix_ht, prix_ttc, resiliation, suspension, valider, clients, telephone, agents, matricule,status,mode_paiement,code_transaction) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 1, ?, ?, ?, ?,?,?,?)";
        stmt = conn.prepareStatement(sqlInsert);
        stmt.setInt(1, id_voiture);
        stmt.setInt(2, id_categorie);
        stmt.setInt(3, clientId); // On conserve l'iduser du client d'origine
        stmt.setString(4, newDateDebut.toString());
        stmt.setString(5, newDateFin.toString());
        stmt.setString(6, heure);
        stmt.setString(7, immatriculation);
        stmt.setString(8, quartier);
        stmt.setInt(9, puissance);
        stmt.setInt(10, nombre_place);
        stmt.setInt(11, energie);
        stmt.setInt(12, nombre_mois);
        stmt.setDouble(13, prix_ht);
        stmt.setDouble(14, prix_ttc);
        stmt.setString(15, clients);
        stmt.setString(16, telephone);
        stmt.setString(17, agentFullName);
        stmt.setString(18, agentMatricule);
        stmt.setString(19, status);
        stmt.setString(20, "ok");
        stmt.setString(21, "ok");


        int rows = stmt.executeUpdate();
        if (rows > 0) {
            response.sendRedirect("agentaffichageassurance.jsp?renewalSuccess=1");
        } else {
            out.println("Erreur lors du renouvellement.");
        }
    } catch(Exception e) {
        out.println("Erreur : " + e.getMessage());
    } finally {
        if(rs != null) try { rs.close(); } catch(SQLException ignore) {}
        if(stmt != null) try { stmt.close(); } catch(SQLException ignore) {}
        if(conn != null) try { conn.close(); } catch(SQLException ignore) {}
    }
%>