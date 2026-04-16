<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Réinitialisation de mot de passe - MBA Niger</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="public/css/1bootstrap.min.css" rel="stylesheet">
  <link href="public/css/2dataTables.bootstrap5.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
  <style>
    /* Réinitialisation et styles globaux */
    * { margin: 0; padding: 0; box-sizing: border-box; }
    
    body {
      font-family: 'Arial', sans-serif;
      height: 100vh;
      background-color: #f5f5f5;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 0;
      margin: 0;
    }
    
    .container {
      width: 500px;
      max-width: 90%;
      background-color: #fff;
      border-radius: 5px;
      overflow: hidden;
      box-shadow: 0 0 10px rgba(0,0,0,0.1);
      padding: 30px;
    }
    
    .form-header {
      text-align: center;
      margin-bottom: 25px;
    }
    
    .form-header .logo {
      width: 80px;
      height: auto;
      margin-bottom: 15px;
    }
    
    .form-header h1 {
      font-size: 22px;
      color: #006652;
      margin-bottom: 5px;
    }
    
    .form-header p {
      font-size: 14px;
      color: #666;
    }
    
    .form-group {
      margin-bottom: 20px;
    }
    
    .form-group label {
      display: block;
      margin-bottom: 5px;
      font-size: 14px;
      color: #333;
    }
    
    .input-with-icon {
      position: relative;
    }
    
    .input-with-icon i {
      position: absolute;
      left: 10px;
      top: 50%;
      transform: translateY(-50%);
      color: #006652;
    }
    
    .input-with-icon input {
      width: 100%;
      padding: 10px 10px 10px 35px;
      border: 1px solid #ddd;
      border-radius: 4px;
      font-size: 14px;
    }
    
    .input-with-icon input:focus {
      outline: none;
      border-color: #006652;
      box-shadow: 0 0 0 2px rgba(0, 102, 82, 0.2);
    }
    
    .btn {
      width: 100%;
      padding: 10px;
      background-color: #006652;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 14px;
      font-weight: bold;
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 8px;
      margin-bottom: 15px;
    }
    
    .btn:hover {
      background-color: #005544;
    }
    
    .back-link {
      display: block;
      text-align: center;
      color: #006652;
      text-decoration: none;
      font-size: 14px;
    }
    
    .back-link:hover {
      text-decoration: underline;
    }
    
    .error-message {
      background-color: #f8d7da;
      color: #721c24;
      padding: 8px;
      border-radius: 4px;
      margin-bottom: 15px;
      font-size: 14px;
    }
    
    .success-message {
      background-color: #d4edda;
      color: #155724;
      padding: 8px;
      border-radius: 4px;
      margin-bottom: 15px;
      font-size: 14px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="form-header">
      <img src="public/images/logo.png" alt="Logo MBA Niger" class="logo">
      <h1>Réinitialisation de mot de passe</h1>
      <p>Veuillez créer un nouveau mot de passe</p>
    </div>
    
    <% if (request.getAttribute("errorMessage") != null) { %>
      <div class="error-message">
        <i class="fas fa-exclamation-circle"></i>
        <%= request.getAttribute("errorMessage") %>
      </div>
    <% } %>
    
    <% 
      // Récupérer le token et le type d'utilisateur (user ou admin) de l'URL
      String token = request.getParameter("token");
      String userType = request.getParameter("type"); // 'user' ou 'admin'
      
      if (token == null || token.trim().isEmpty() || userType == null || userType.trim().isEmpty()) {
    %>
      <div class="error-message">
        <i class="fas fa-exclamation-circle"></i>
        Lien de réinitialisation invalide ou expiré. Veuillez faire une nouvelle demande.
      </div>
      <a href="forgot-password.jsp" class="back-link">
        <i class="fas fa-arrow-left"></i>
        Retour à la récupération de mot de passe
      </a>
    <% } else { %>
      <form action="process-password-change.jsp" method="POST">
        <input type="hidden" name="token" value="<%= token %>">
        <input type="hidden" name="userType" value="<%= userType %>">
        
        <div class="form-group">
          <label for="new-password">Nouveau mot de passe</label>
          <div class="input-with-icon">
            <i class="fas fa-lock"></i>
            <input type="password" id="new-password" name="newPassword" placeholder="Entrez votre nouveau mot de passe" required>
          </div>
        </div>
        
        <div class="form-group">
          <label for="confirm-password">Confirmer le mot de passe</label>
          <div class="input-with-icon">
            <i class="fas fa-lock"></i>
            <input type="password" id="confirm-password" name="confirmPassword" placeholder="Confirmez votre nouveau mot de passe" required>
          </div>
        </div>
        
        <button type="submit" class="btn">
          <i class="fas fa-save"></i>
          Enregistrer le nouveau mot de passe
        </button>
      </form>
    <% } %>
    
    <a href="login.jsp" class="back-link">
      <i class="fas fa-arrow-left"></i>
      Retour à la page de connexion
    </a>
  </div>
  
  <script>
    // Vérification que les mots de passe correspondent
    const form = document.querySelector('form');
    const newPassword = document.getElementById('new-password');
    const confirmPassword = document.getElementById('confirm-password');
    
    form.addEventListener('submit', function(e) {
      if (newPassword.value !== confirmPassword.value) {
        e.preventDefault();
        
        // Vérifier si l'erreur existe déjà
        let errorDiv = document.querySelector('.password-error');
        
        if (!errorDiv) {
          // Créer le message d'erreur
          errorDiv = document.createElement('div');
          errorDiv.className = 'error-message password-error';
          errorDiv.innerHTML = '<i class="fas fa-exclamation-circle"></i> Les mots de passe ne correspondent pas';
          
          // Insérer après le champ de confirmation
          confirmPassword.parentElement.parentElement.after(errorDiv);
        }
        
        // Focus sur le champ de confirmation
        confirmPassword.focus();
      }
    });
    
    // Supprimer l'erreur quand l'utilisateur modifie les champs
    [newPassword, confirmPassword].forEach(input => {
      input.addEventListener('input', function() {
        const errorDiv = document.querySelector('.password-error');
        if (errorDiv) {
          errorDiv.remove();
        }
      });
    });
  </script>
</body>
</html>