<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    // Vérification de la session admin
    Integer idadmin = (Integer) session.getAttribute("idadmin");
    String role = (String) session.getAttribute("role");
    if(idadmin == null || role == null || !"soleil".equals(role)) {
        session.setAttribute("errorMessage", "Session expirée. Veuillez vous reconnecter.");
        response.sendRedirect("../login.jsp");
        return;
    }

    // Récupérer les paramètres de la requête
    String idReclamationStr = request.getParameter("id_reclamation");
    String reponse = request.getParameter("reponse");

    // Debug - Afficher les paramètres reçus
    System.out.println("DEBUG - ID Réclamation: " + idReclamationStr);
    System.out.println("DEBUG - Réponse: " + reponse);
    System.out.println("DEBUG - ID Admin: " + idadmin);

    // Validation des paramètres
    if (idReclamationStr == null || idReclamationStr.trim().isEmpty()) {
        session.setAttribute("errorMessage", "Identifiant de réclamation manquant.");
        response.sendRedirect("gererreclamation.jsp");
        return;
    }
    
    if (reponse == null || reponse.trim().length() < 10) {
        session.setAttribute("errorMessage", "La réponse doit contenir au moins 10 caractères.");
        response.sendRedirect("gererreclamation.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement stmtCheck = null;
    PreparedStatement stmt = null;
    PreparedStatement stmtGetUser = null;
    PreparedStatement stmtNotification = null;
    ResultSet rsCheck = null;
    ResultSet rsUser = null;

    try {
        // Charger le pilote JDBC
        Class.forName("org.mariadb.jdbc.Driver");
        System.out.println("DEBUG - Driver chargé avec succès");
        
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
        System.out.println("DEBUG - Connexion établie avec succès");
        
        // Vérifier d'abord si la réclamation existe et n'est pas déjà traitée
        String sqlCheck = "SELECT id_reclamation, etat, iduser FROM reclamation WHERE id_reclamation = ?";
        stmtCheck = conn.prepareStatement(sqlCheck);
        stmtCheck.setInt(1, Integer.parseInt(idReclamationStr));
        rsCheck = stmtCheck.executeQuery();
        
        if (!rsCheck.next()) {
            session.setAttribute("errorMessage", "Réclamation introuvable avec l'ID: " + idReclamationStr);
            response.sendRedirect("gererreclamation.jsp");
            return;
        }
        
        String etatActuel = rsCheck.getString("etat");
        int iduser = rsCheck.getInt("iduser");
        
        if ("Traitée".equals(etatActuel) || "Traitee".equals(etatActuel)) {
            session.setAttribute("errorMessage", "Cette réclamation a déjà été traitée.");
            response.sendRedirect("gererreclamation.jsp");
            return;
        }
        
        System.out.println("DEBUG - Réclamation trouvée, état: " + etatActuel + ", iduser: " + iduser);
        
        // Début de la transaction
        conn.setAutoCommit(false);
        System.out.println("DEBUG - Transaction démarrée");
        
        // Préparer la requête de mise à jour de la réclamation
        String sqlReclamation = "UPDATE reclamation " +
                                "SET reponse = ?, " +
                                "    etat = 'Traitée', " +
                                "    date_traitement = CURDATE(), " +
                                "    idadmin = ? " +
                                "WHERE id_reclamation = ?";
        stmt = conn.prepareStatement(sqlReclamation);
        
        // Paramètres de mise à jour
        stmt.setString(1, reponse.trim());
        stmt.setInt(2, idadmin);
        stmt.setInt(3, Integer.parseInt(idReclamationStr));
        
        System.out.println("DEBUG - Requête UPDATE préparée");
        
        // Exécuter la mise à jour de la réclamation
        int rowsAffected = stmt.executeUpdate();
        System.out.println("DEBUG - Lignes affectées: " + rowsAffected);
        
        // Vérifier si la mise à jour a réussi
        if (rowsAffected > 0) {
            // Insérer une notification pour l'utilisateur (si vous avez une table notifications)
            // Si vous n'avez pas cette table, commentez cette section
            /*
            String sqlNotification = "INSERT INTO notifications " +
                                     "(iduser, titre, message, date_notification, type, lue) " +
                                     "VALUES (?, 'Réclamation traitée', ?, NOW(), 'reclamation', 0)";
            stmtNotification = conn.prepareStatement(sqlNotification);
            stmtNotification.setInt(1, iduser);
            
            // Tronquer le message de notification si trop long
            String notificationMessage = "Votre réclamation a été traitée. Réponse: " + 
                (reponse.length() > 100 ? reponse.substring(0, 100) + "..." : reponse);
            stmtNotification.setString(2, notificationMessage);
            
            int notificationResult = stmtNotification.executeUpdate();
            System.out.println("DEBUG - Notification insérée: " + notificationResult);
            */
            
            // Valider la transaction
            conn.commit();
            System.out.println("DEBUG - Transaction validée");
            
            session.setAttribute("successMessage", "Réclamation traitée avec succès !");
        } else {
            // Annuler la transaction en cas d'échec
            conn.rollback();
            System.out.println("DEBUG - Transaction annulée - aucune ligne affectée");
            session.setAttribute("errorMessage", "Erreur lors du traitement de la réclamation.");
        }
        
    } catch (SQLException e) {
        System.out.println("DEBUG - Erreur SQL: " + e.getMessage());
        e.printStackTrace();
        
        // En cas d'erreur, annuler la transaction
        if (conn != null) {
            try {
                conn.rollback();
                System.out.println("DEBUG - Rollback effectué");
            } catch (SQLException ex) {
                System.out.println("DEBUG - Erreur lors du rollback: " + ex.getMessage());
            }
        }
        
        // Gérer les erreurs de base de données
        session.setAttribute("errorMessage", "Erreur de base de données : " + e.getMessage());
    } catch (NumberFormatException e) {
        System.out.println("DEBUG - Erreur de format de nombre: " + e.getMessage());
        // Gérer les erreurs de conversion
        session.setAttribute("errorMessage", "Identifiant de réclamation invalide: " + idReclamationStr);
    } catch (Exception e) {
        System.out.println("DEBUG - Erreur générale: " + e.getMessage());
        e.printStackTrace();
        // Gérer toute autre exception
        session.setAttribute("errorMessage", "Une erreur est survenue : " + e.getMessage());
    } finally {
        // Fermer les ressources
        if (rsCheck != null) {
            try { rsCheck.close(); } catch (SQLException ignore) {}
        }
        if (rsUser != null) {
            try { rsUser.close(); } catch (SQLException ignore) {}
        }
        if (stmtCheck != null) {
            try { stmtCheck.close(); } catch (SQLException ignore) {}
        }
        if (stmt != null) {
            try { stmt.close(); } catch (SQLException ignore) {}
        }
        if (stmtGetUser != null) {
            try { stmtGetUser.close(); } catch (SQLException ignore) {}
        }
        if (stmtNotification != null) {
            try { stmtNotification.close(); } catch (SQLException ignore) {}
        }
        if (conn != null) {
            try { 
                conn.setAutoCommit(true);
                conn.close(); 
                System.out.println("DEBUG - Connexion fermée");
            } catch (SQLException ignore) {}
        }
        
        // Rediriger vers la page de gestion des réclamations
        response.sendRedirect("gererreclamation.jsp");
    }
%>