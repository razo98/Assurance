<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Vérification de la session admin
    Integer idadmin = (Integer) session.getAttribute("idadmin");
    String role = (String) session.getAttribute("role");
    if(idadmin == null || role == null || !"soleil".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Récupération des informations administrateur depuis la session
    String firstname = (String) session.getAttribute("firstname");
    String lastname = (String) session.getAttribute("lastname");
    String username = (String) session.getAttribute("username");
    String number = (String) session.getAttribute("number");
    String matricule = (String) session.getAttribute("matricule");
    
    // Variables pour stocker les informations complètes du profil
    String adminRole = role;
    
    // Connexion à la base de données pour récupérer toutes les infos
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        // Charger le driver
        Class.forName("org.mariadb.jdbc.Driver");
        
        // Établir la connexion
        conn = DriverManager.getConnection(
            "jdbc:mariadb://localhost:3306/assurance", 
            "root", 
            ""
        );
        
        // Requête pour obtenir les informations complètes de l'administrateur
        String sql = "SELECT * FROM admins WHERE idadmin = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, idadmin);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            // Récupérer les infos (même si certaines sont déjà en session)
            firstname = rs.getString("firstname");
            lastname = rs.getString("lastname");
            username = rs.getString("username");
            number = rs.getString("number");
            adminRole = rs.getString("role");
            matricule = rs.getString("matricule");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        // Fermeture des ressources
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // Récupération d'un éventuel message de succès ou d'erreur
    String successMessage = (String) session.getAttribute("profileUpdateSuccess");
    String errorMessage = (String) session.getAttribute("profileUpdateError");
    
    // Suppression des messages de la session pour qu'ils ne s'affichent qu'une fois
    session.removeAttribute("profileUpdateSuccess");
    session.removeAttribute("profileUpdateError");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <title>Mon Profil Admin - MBA-Niger Assurance</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        :root {
            --primary-color: #da812f;
            --secondary-color: #f8f1e9;
            --accent-color: #e67e22;
            --text-color: #333;
            --border-color: #ddd;
        }
        
        body {
            background-color: var(--secondary-color);
            font-family: 'Arial', sans-serif;
            padding-top: 60px;
        }
        
        .profile-container {
            max-width: 800px;
            margin: 30px auto;
            padding: 20px;
        }
        
        .profile-header {
            background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
            color: white;
            padding: 25px;
            border-radius: 10px 10px 0 0;
            position: relative;
            overflow: hidden;
        }
        
        .profile-header::before {
            content: "";
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            transform: rotate(30deg);
        }
        
        .profile-header h1 {
            font-size: 1.8rem;
            margin-bottom: 10px;
            position: relative;
        }
        
        .profile-header p {
            margin-bottom: 0;
            opacity: 0.9;
            position: relative;
        }
        
        .profile-form-container {
            background-color: white;
            border-radius: 0 0 10px 10px;
            padding: 30px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .form-section {
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border-color);
        }
        
        .form-section:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }
        
        .section-title {
            color: var(--primary-color);
            font-size: 1.2rem;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
        }
        
        .section-title i {
            margin-right: 10px;
            background-color: var(--primary-color);
            color: white;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }
        
        .form-label {
            color: #555;
            font-weight: 500;
        }
        
        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.2rem rgba(218, 129, 47, 0.25);
        }
        
        .btn-update {
            background-color: var(--primary-color);
            border: none;
            padding: 10px 25px;
            border-radius: 5px;
            color: white;
            font-weight: 500;
            transition: all 0.3s;
        }
        
        .btn-update:hover {
            background-color: var(--accent-color);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        
        .password-toggle {
            cursor: pointer;
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            color: #777;
        }
        
        .alert {
            margin-bottom: 20px;
            border-radius: 5px;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border-color: #c3e6cb;
        }
        
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }
    </style>
</head>
<body>
    <%@ include file="../mead.jsp" %>

    <div class="container profile-container">
        <div class="profile-header">
            <h1><i class="fas fa-user-shield me-2"></i>Mon Profil Administrateur</h1>
            <p>Gérez vos informations personnelles et mettez à jour votre compte</p>
        </div>
        
        <div class="profile-form-container">
            <% if (successMessage != null && !successMessage.isEmpty()) { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle me-2"></i><%= successMessage %>
                </div>
            <% } %>
            
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-circle me-2"></i><%= errorMessage %>
                </div>
            <% } %>
            
            <form action="traitementprofiladmin.jsp" method="post" id="profileForm">
                <!-- Informations personnelles -->
                <div class="form-section">
                    <h2 class="section-title"><i class="fas fa-user"></i>Informations personnelles</h2>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="firstname" class="form-label">Prénom</label>
                            <input type="text" class="form-control" id="firstname" name="firstname" value="<%= firstname != null ? firstname : "" %>" required>
                        </div>
                        <div class="col-md-6">
                            <label for="lastname" class="form-label">Nom</label>
                            <input type="text" class="form-control" id="lastname" name="lastname" value="<%= lastname != null ? lastname : "" %>" required>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-4">
                            <label for="number" class="form-label">Téléphone</label>
                            <input type="text" class="form-control" id="number" name="number" value="<%= number != null ? number : "" %>" required>
                        </div>
                        <div class="col-md-4">
                            <label for="role" class="form-label">Rôle</label>
                            <input type="text" class="form-control" id="role" name="role" value="<%= adminRole != null ? adminRole : "" %>" readonly>
                        </div>
                        <div class="col-md-4">
                            <label for="matricule" class="form-label">Matricule</label>
                            <input type="text" class="form-control" id="matricule" name="matricule" value="<%= matricule != null ? matricule : "" %>" readonly>
                        </div>
                    </div>
                </div>
                
                <!-- Informations de connexion -->
                <div class="form-section">
                    <h2 class="section-title"><i class="fas fa-lock"></i>Informations de connexion</h2>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="username" class="form-label">Nom d'utilisateur</label>
                            <input type="text" class="form-control" id="username" name="username" value="<%= username != null ? username : "" %>" required>
                        </div>
                        <div class="col-md-6 position-relative">
                            <label for="password" class="form-label">Mot de passe</label>
                            <input type="password" class="form-control" id="password" name="password" placeholder="Entrez un nouveau mot de passe">
                            <span class="password-toggle" onclick="togglePasswordVisibility()">
                                <i class="fas fa-eye" id="toggleIcon"></i>
                            </span>
                            <small class="form-text text-muted">Laissez vide pour conserver votre mot de passe actuel</small>
                        </div>
                    </div>
                </div>
                
                <div class="text-end">
                    <button type="submit" class="btn btn-update">
                        <i class="fas fa-save me-2"></i>Enregistrer les modifications
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Fonction pour afficher/masquer le mot de passe
        function togglePasswordVisibility() {
            const passwordInput = document.getElementById('password');
            const toggleIcon = document.getElementById('toggleIcon');
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                toggleIcon.classList.remove('fa-eye');
                toggleIcon.classList.add('fa-eye-slash');
            } else {
                passwordInput.type = 'password';
                toggleIcon.classList.remove('fa-eye-slash');
                toggleIcon.classList.add('fa-eye');
            }
        }
        
        // Validation du formulaire
        document.getElementById('profileForm').addEventListener('submit', function(e) {
            const firstname = document.getElementById('firstname').value.trim();
            const lastname = document.getElementById('lastname').value.trim();
            const username = document.getElementById('username').value.trim();
            const number = document.getElementById('number').value.trim();
            
            // Validation des champs obligatoires
            if (!firstname || !lastname || !username || !number) {
                e.preventDefault();
                alert('Veuillez remplir tous les champs obligatoires.');
                return;
            }
            
            // Validation du nom d'utilisateur (uniquement lettres, chiffres et underscore)
            const usernameRegex = /^[a-zA-Z0-9_]+$/;
            if (!usernameRegex.test(username)) {
                e.preventDefault();
                alert('Le nom d\'utilisateur ne doit contenir que des lettres, des chiffres et des underscores.');
                return;
            }
            
            // Validation du numéro de téléphone (exemple pour un format français)
            const phoneRegex = /^(0|\+33)[1-9]([-. ]?[0-9]{2}){4}$/;
            if (!phoneRegex.test(number)) {
                e.preventDefault();
                alert('Veuillez entrer un numéro de téléphone valide.');
                return;
            }
            
            // Validation du mot de passe (optionnel mais avec des critères si rempli)
            const password = document.getElementById('password').value;
            if (password) {
                if (password.length < 8) {
                    e.preventDefault();
                    alert('Le mot de passe doit contenir au moins 8 caractères.');
                    return;
                }
                
                // Vérification de la complexité du mot de passe
                const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
                if (!passwordRegex.test(password)) {
                    e.preventDefault();
                    alert('Le mot de passe doit contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial.');
                    return;
                }
            }
        });
    </script>
</body>
</html>