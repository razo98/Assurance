<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Vérifier que l'utilisateur est connecté
    Integer iduser = (Integer) session.getAttribute("iduser");
    if (iduser == null) {
        session.setAttribute("errorMessage", "Session expirée. Veuillez vous reconnecter.");
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Récupérer tous les paramètres du formulaire
    String assuranceId = request.getParameter("assurance_id");
    String sujet = request.getParameter("sujet");
    String libelle = request.getParameter("libelle");
    String urgence = request.getParameter("urgence");
    
    // Debug - Log des paramètres reçus
    System.out.println("DEBUG Réclamation - User ID: " + iduser);
    System.out.println("DEBUG Réclamation - Assurance ID: " + assuranceId);
    System.out.println("DEBUG Réclamation - Sujet: " + sujet);
    System.out.println("DEBUG Réclamation - Urgence: " + urgence);
    System.out.println("DEBUG Réclamation - Libelle length: " + (libelle != null ? libelle.length() : 0));
    
    // Validation des champs obligatoires
    if (sujet == null || sujet.trim().isEmpty()) {
        session.setAttribute("errorMessage", "Le sujet de la réclamation est obligatoire.");
        response.sendRedirect("reclamation.jsp");
        return;
    }
    
    if (libelle == null || libelle.trim().length() < 10) {
        session.setAttribute("errorMessage", "La description doit contenir au moins 10 caractères.");
        response.sendRedirect("reclamation.jsp");
        return;
    }
    
    if (urgence == null || urgence.trim().isEmpty()) {
        session.setAttribute("errorMessage", "Le niveau d'urgence est obligatoire.");
        response.sendRedirect("reclamation.jsp");
        return;
    }
    
    // Validation des valeurs d'urgence
    if (!urgence.equals("Normale") && !urgence.equals("Élevée") && !urgence.equals("Urgente")) {
        session.setAttribute("errorMessage", "Niveau d'urgence invalide.");
        response.sendRedirect("reclamation.jsp");
        return;
    }
    
    Connection conn = null;
    PreparedStatement stmt = null;
    PreparedStatement stmtVerif = null;
    ResultSet rs = null;
    
    try {
        // Charger le driver et établir la connexion avec encodage UTF-8
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");
        
        System.out.println("DEBUG Réclamation - Connexion établie");
        
        // Vérifier si l'assurance appartient bien à l'utilisateur (si spécifiée)
        if (assuranceId != null && !assuranceId.trim().isEmpty()) {
            String sqlVerif = "SELECT COUNT(*) as count FROM assurance WHERE id_assurance = ? AND iduser = ?";
            stmtVerif = conn.prepareStatement(sqlVerif);
            stmtVerif.setInt(1, Integer.parseInt(assuranceId));
            stmtVerif.setInt(2, iduser);
            rs = stmtVerif.executeQuery();
            
            if (rs.next() && rs.getInt("count") == 0) {
                session.setAttribute("errorMessage", "L'assurance sélectionnée ne vous appartient pas.");
                response.sendRedirect("reclamation.jsp");
                return;
            }
        }
        
        // Préparer la requête SQL d'insertion
        String sql = "INSERT INTO reclamation " +
                     "(iduser, assurance_id, sujet, libelle, urgence, date_reclamation, etat) " +
                     "VALUES (?, ?, ?, ?, ?, NOW(), 'En attente')";
        
        stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        stmt.setInt(1, iduser);
        
        // Gérer l'assurance_id qui peut être null ou vide
        if (assuranceId != null && !assuranceId.trim().isEmpty()) {
            stmt.setInt(2, Integer.parseInt(assuranceId));
        } else {
            stmt.setNull(2, java.sql.Types.INTEGER);
        }
        
        stmt.setString(3, sujet.trim());
        stmt.setString(4, libelle.trim());
        stmt.setString(5, urgence);
        
        System.out.println("DEBUG Réclamation - Requête préparée");
        
        // Exécuter la requête
        int rows = stmt.executeUpdate();
        
        if (rows > 0) {
            // Récupérer l'ID de la réclamation créée
            ResultSet generatedKeys = stmt.getGeneratedKeys();
            int reclamationId = 0;
            if (generatedKeys.next()) {
                reclamationId = generatedKeys.getInt(1);
            }
            
            System.out.println("DEBUG Réclamation - Réclamation créée avec ID: " + reclamationId);
            
            // Message de succès personnalisé selon l'urgence
            String successMsg = "Votre réclamation a été envoyée avec succès.";
            if ("Urgente".equals(urgence)) {
                successMsg += " Elle sera traitée en priorité dans les plus brefs délais.";
            } else if ("Élevée".equals(urgence)) {
                successMsg += " Elle sera traitée rapidement.";
            } else {
                successMsg += " Nous la traiterons dans les meilleurs délais.";
            }
            
            session.setAttribute("successMessage", successMsg);
            response.sendRedirect("reclamation.jsp");
        } else {
            System.out.println("DEBUG Réclamation - Aucune ligne affectée");
            session.setAttribute("errorMessage", "Erreur lors de l'envoi de la réclamation. Veuillez réessayer.");
            response.sendRedirect("reclamation.jsp");
        }
        
    } catch (NumberFormatException e) {
        System.out.println("DEBUG Réclamation - Erreur format nombre: " + e.getMessage());
        session.setAttribute("errorMessage", "Identifiant d'assurance invalide.");
        response.sendRedirect("reclamation.jsp");
    } catch (SQLException e) {
        System.out.println("DEBUG Réclamation - Erreur SQL: " + e.getMessage());
        e.printStackTrace();
        
        // Messages d'erreur plus spécifiques selon le type d'erreur SQL
        String errorMsg = "Erreur de base de données";
        if (e.getMessage().contains("Duplicate entry")) {
            errorMsg = "Une réclamation similaire existe déjà.";
        } else if (e.getMessage().contains("constraint")) {
            errorMsg = "Données invalides fournies.";
        } else {
            errorMsg = "Erreur technique temporaire. Veuillez réessayer.";
        }
        
        session.setAttribute("errorMessage", errorMsg);
        response.sendRedirect("reclamation.jsp");
    } catch (Exception e) {
        System.out.println("DEBUG Réclamation - Erreur générale: " + e.getMessage());
        e.printStackTrace();
        session.setAttribute("errorMessage", "Une erreur inattendue s'est produite : " + e.getMessage());
        response.sendRedirect("reclamation.jsp");
    } finally {
        // Fermeture propre des ressources
        if (rs != null) {
            try { rs.close(); } catch(SQLException ignore) {}
        }
        if (stmtVerif != null) {
            try { stmtVerif.close(); } catch(SQLException ignore) {}
        }
        if (stmt != null) {
            try { stmt.close(); } catch(SQLException ignore) {}
        }
        if (conn != null) {
            try { conn.close(); } catch(SQLException ignore) {}
        }
        
        System.out.println("DEBUG Réclamation - Ressources fermées");
    }
%>