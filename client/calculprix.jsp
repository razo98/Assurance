<%@ page contentType="application/json;charset=UTF-8" language="java" %>
<%
    // Récupération des paramètres
    String energieStr = request.getParameter("energie");
    String puissanceStr = request.getParameter("puissance");
    String nombre_moisStr = request.getParameter("nombre_mois");
    String genreParam = request.getParameter("genre");

    // Réponse par défaut en cas d'erreur
    String jsonResponse = "{\"success\": false, \"message\": \"Paramètres manquants\", \"prix\": 0}";
    
    try {
        // Vérification que tous les paramètres sont présents et non vides
        if (energieStr != null && !energieStr.isEmpty() && 
            puissanceStr != null && !puissanceStr.isEmpty() && 
            nombre_moisStr != null && !nombre_moisStr.isEmpty() && 
            genreParam != null && !genreParam.isEmpty()) {
            
            // Conversion des valeurs
            int energie = Integer.parseInt(energieStr);
            int puissance = Integer.parseInt(puissanceStr);
            int nombre_mois = Integer.parseInt(nombre_moisStr);
            
            // Déterminer le genre à partir du paramètre (peut être un ID ou une chaîne)
            String genre = "";
            
            // Vérifier si genreParam est un ID numérique
            if (genreParam.matches("\\d+")) {
                int id_categorie = Integer.parseInt(genreParam);
                // Conversion de l'ID en genre
                switch (id_categorie) {
                    case 1:
                        genre = "vp";
                        break;
                    case 2:
                        genre = "taxiville_4p";
                        break;
                    case 3:
                        genre = "taxibrousse";
                        break;
                    case 5:
                        genre = "camionmarchand";
                        break;
                    case 7:
                        genre = "vehiculeutilitaire";
                        break;
                    case 8:
                        genre = "taxiville_19p";
                        break;
                    case 9:
                        genre = "moto";
                        break;
                    default:
                        genre = genreParam.toLowerCase();
                        break;
                }
            } else {
                // Si ce n'est pas un ID, utiliser la valeur directement (après nettoyage)
                genre = genreParam.toLowerCase().replace(" ", "_");
            }
            
            int prix_ht = 0;
            
            // VP (Véhicule Particulier)
            if (genre.equals("vp")) {
                if (nombre_mois == 3) {
                    if ((energie == 0 && puissance >= 3 && puissance <= 6) || (energie == 1 && puissance >= 2 && puissance <= 4)) {
                        prix_ht = 13080;
                    } else if ((energie == 0 && puissance >= 7 && puissance <= 10) || (energie == 1 && puissance >= 5 && puissance <= 7)) {
                        prix_ht = 14852;
                    } else if ((energie == 0 && puissance >= 11 && puissance <= 14) || (energie == 1 && puissance >= 8 && puissance <= 10)) {
                        prix_ht = 19195;
                    } else if ((energie == 0 && puissance >= 15 && puissance <= 23) || (energie == 1 && puissance >= 11 && puissance <= 16)) {
                        prix_ht = 25483;
                    } else if ((energie == 0 && puissance >= 23) || (energie == 1 && puissance >= 17)) {
                        prix_ht = 31066;
                    }
                } else if (nombre_mois == 6) {
                    if ((energie == 0 && puissance >= 3 && puissance <= 6) || (energie == 1 && puissance >= 2 && puissance <= 4)) {
                        prix_ht = 25660;
                    } else if ((energie == 0 && puissance >= 7 && puissance <= 10) || (energie == 1 && puissance >= 5 && puissance <= 7)) {
                        prix_ht = 29204;
                    } else if ((energie == 0 && puissance >= 11 && puissance <= 14) || (energie == 1 && puissance >= 8 && puissance <= 10)) {
                        prix_ht = 37890;
                    } else if ((energie == 0 && puissance >= 15 && puissance <= 23) || (energie == 1 && puissance >= 11 && puissance <= 16)) {
                        prix_ht = 50466;
                    } else if ((energie == 0 && puissance >= 23) || (energie == 1 && puissance >= 17)) {
                        prix_ht = 61633;
                    }
                } else if (nombre_mois == 12) {
                    if ((energie == 0 && puissance >= 3 && puissance <= 6) || (energie == 1 && puissance >= 2 && puissance <= 4)) {
                        prix_ht = 42433;
                    } else if ((energie == 0 && puissance >= 7 && puissance <= 10) || (energie == 1 && puissance >= 5 && puissance <= 7)) {
                        prix_ht = 48340;
                    } else if ((energie == 0 && puissance >= 11 && puissance <= 14) || (energie == 1 && puissance >= 8 && puissance <= 10)) {
                        prix_ht = 62817;
                    } else if ((energie == 0 && puissance >= 15 && puissance <= 23) || (energie == 1 && puissance >= 11 && puissance <= 16)) {
                        prix_ht = 83777;
                    } else if ((energie == 0 && puissance >= 23) || (energie == 1 && puissance >= 17)) {
                        prix_ht = 102388;
                    }
                }
            } 
            // Moto
            else if (genre.equals("moto")) {
                if (nombre_mois == 3) {
                    if (puissance == 0) {
                        prix_ht = 4044;
                    } else if (puissance == 1) {
                        prix_ht = 7588;
                    } else if (puissance >= 2 && puissance <= 3) {
                        prix_ht = 13789;
                    }
                } else if (nombre_mois == 6) {
                    if (puissance == 0) {
                        prix_ht = 7587;
                    } else if (puissance == 1) {
                        prix_ht = 14675;
                    } else if (puissance >= 2 && puissance <= 3) {
                        prix_ht = 27078;
                    }
                } else if (nombre_mois == 12) {
                    if (puissance == 0) {
                        prix_ht = 12312;
                    } else if (puissance == 1) {
                        prix_ht = 24125;
                    } else if (puissance >= 2 && puissance <= 3) {
                        prix_ht = 44796;
                    }
                }
            } 
            // Taxi ville 4 places
            else if (genre.equals("taxiville_4p")) {
                if (nombre_mois == 3) {
                    if ((energie == 0 && puissance >= 3 && puissance <= 6) || (energie == 1 && puissance >= 2 && puissance <= 4)) {
                        prix_ht = 28834;
                    } else if ((energie == 0 && puissance >= 7 && puissance <= 10) || (energie == 1 && puissance >= 5 && puissance <= 7)) {
                        prix_ht = 34138;
                    } else if ((energie == 0 && puissance >= 11 && puissance <= 14) || (energie == 1 && puissance >= 8 && puissance <= 10)) {
                        prix_ht = 48313;
                    }
                } else if (nombre_mois == 6) {
                    if ((energie == 0 && puissance >= 3 && puissance <= 6) || (energie == 1 && puissance >= 2 && puissance <= 4)) {
                        prix_ht = 57667;
                    } else if ((energie == 0 && puissance >= 7 && puissance <= 10) || (energie == 1 && puissance >= 5 && puissance <= 7)) {
                        prix_ht = 67775;
                    } else if ((energie == 0 && puissance >= 11 && puissance <= 14) || (energie == 1 && puissance >= 8 && puissance <= 10)) {
                        prix_ht = 96125;
                    }
                } else if (nombre_mois == 12) {
                    if ((energie == 0 && puissance >= 3 && puissance <= 6) || (energie == 1 && puissance >= 2 && puissance <= 4)) {
                        prix_ht = 71389;
                    } else if ((energie == 0 && puissance >= 7 && puissance <= 10) || (energie == 1 && puissance >= 5 && puissance <= 7)) {
                        prix_ht = 84200;
                    } else if ((energie == 0 && puissance >= 11 && puissance <= 14) || (energie == 1 && puissance >= 8 && puissance <= 10)) {
                        prix_ht = 122000;
                    }
                }
            } 
            // Taxi ville 19 places
            else if (genre.equals("taxiville_19p")) {
                if (nombre_mois == 3) {
                    if ((energie == 0 && puissance >= 7 && puissance <= 10) || (energie == 1 && puissance >= 5 && puissance <= 7)) {
                        prix_ht = 67834;
                    } else if ((energie == 0 && puissance >= 11 && puissance <= 14) || (energie == 1 && puissance >= 8 && puissance <= 10)) {
                        prix_ht = 82063;
                    }
                } else if (nombre_mois == 6) {
                    if ((energie == 0 && puissance >= 7 && puissance <= 10) || (energie == 1 && puissance >= 5 && puissance <= 7)) {
                        prix_ht = 135275;
                    } else if ((energie == 0 && puissance >= 11 && puissance <= 14) || (energie == 1 && puissance >= 8 && puissance <= 10)) {
                        prix_ht = 163625;
                    }
                } else if (nombre_mois == 12) {
                    if ((energie == 0 && puissance >= 7 && puissance <= 10) || (energie == 1 && puissance >= 5 && puissance <= 7)) {
                        prix_ht = 186200;
                    } else if ((energie == 0 && puissance >= 11 && puissance <= 14) || (energie == 1 && puissance >= 8 && puissance <= 10)) {
                        prix_ht = 218000;
                    }
                }
            }
            
            // Calcul du prix TTC (TVA 12% + 300)
            int prix_ttc = Math.round(prix_ht * 1.12f + 300);
            
            // Vérifier que le prix a bien été calculé
            if (prix_ht <= 0) {
                jsonResponse = "{\"success\": false, \"message\": \"Aucun tarif trouvé pour cette combinaison (genre: " + genre + ", puissance: " + puissance + ", énergie: " + energie + ", durée: " + nombre_mois + " mois)\", \"prix\": 0}";
            } else {
                // Construction de la réponse JSON
                jsonResponse = "{\"success\": true, \"message\": \"Prix calculé avec succès\", \"prix\": " + prix_ttc + "}";
            }
        } else {
            // Ajoutez des détails sur les paramètres manquants
            String missing = "";
            if (energieStr == null || energieStr.isEmpty()) missing += "energie, ";
            if (puissanceStr == null || puissanceStr.isEmpty()) missing += "puissance, ";
            if (nombre_moisStr == null || nombre_moisStr.isEmpty()) missing += "nombre_mois, ";
            if (genreParam == null || genreParam.isEmpty()) missing += "genre, ";
            
            if (!missing.isEmpty()) {
                missing = missing.substring(0, missing.length() - 2); // Enlever la dernière virgule
            }
            
            jsonResponse = "{\"success\": false, \"message\": \"Paramètres manquants: " + missing + "\", \"prix\": 0}";
        }
    } catch (Exception e) {
        jsonResponse = "{\"success\": false, \"message\": \"Erreur: " + e.getMessage().replace("\"", "\\\"") + "\", \"prix\": 0}";
    }
    
    // Envoi de la réponse JSON
    out.print(jsonResponse);
%>