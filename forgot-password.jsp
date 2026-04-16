<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Récupération de mot de passe - MBA Niger</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="public/css/1bootstrap.min.css" rel="stylesheet">
  <link href="public/css/2dataTables.bootstrap5.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
  <style>
    /* Réinitialisation et styles globaux */
    * { margin: 0; padding: 0; box-sizing: border-box; }
    
    body {
      font-family: 'Arial', sans-serif;
      min-height: 100vh;
      background-color: #f5f5f5;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px 0;
      margin: 0;
    }
    
    .container {
      width: 500px;
      max-width: 95%;
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
      padding: 12px;
      border-radius: 4px;
      margin-bottom: 15px;
      font-size: 14px;
    }
    
    .success-message {
      background-color: #d4edda;
      color: #155724;
      padding: 12px;
      border-radius: 4px;
      margin-bottom: 15px;
      font-size: 14px;
    }
    
    /* Styles pour le bloc de démonstration */
    .demo-reset-link {
      background-color: #f8f9fa;
      border: 1px solid #ddd;
      border-radius: 4px;
      padding: 15px;
      margin: 20px 0;
    }
    
    .demo-reset-link h3 {
      font-size: 16px;
      color: #333;
      margin-bottom: 10px;
    }
    
    .demo-reset-link p {
      font-size: 13px;
      color: #666;
      margin-bottom: 10px;
    }
    
    .demo-reset-link .reset-url {
      display: block;
      background-color: #e9ecef;
      padding: 8px;
      border-radius: 4px;
      word-break: break-all;
      font-family: monospace;
      font-size: 12px;
      margin-bottom: 10px;
      color: #333;
    }
    
    .demo-reset-link .copy-btn {
      display: inline-block;
      background-color: #006652;
      color: white;
      padding: 5px 10px;
      border-radius: 4px;
      font-size: 12px;
      cursor: pointer;
      border: none;
    }
    
    .demo-reset-link .copy-btn:hover {
      background-color: #005544;
    }

    @media (max-width: 576px) {
      .container {
        padding: 20px 15px;
      }
      
      .form-header h1 {
        font-size: 20px;
      }
      
      .demo-reset-link {
        padding: 10px;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="form-header">
      <img src="public/images/logo.png" alt="Logo MBA Niger" class="logo">
      <h1>Récupération de mot de passe</h1>
      <p>Veuillez saisir votre email pour recevoir un lien de réinitialisation</p>
    </div>
    
    <% if (request.getAttribute("errorMessage") != null) { %>
      <div class="error-message">
        <i class="fas fa-exclamation-circle"></i>
        <%= request.getAttribute("errorMessage") %>
      </div>
    <% } %>
    
    <% if (request.getAttribute("successMessage") != null) { %>
      <div class="success-message">
        <i class="fas fa-check-circle"></i>
        <%= request.getAttribute("successMessage") %>
      </div>
      
      <% if (request.getAttribute("resetLink") != null && request.getAttribute("userEmail") != null) { %>
        <!-- Section de démonstration pour le développement - À retirer en production -->
        <div class="demo-reset-link">
          <h3>Démo : Lien de réinitialisation</h3>
          <p>En environnement de production, ce lien serait envoyé par email à <strong><%= request.getAttribute("userEmail") %></strong>. Pour les besoins de démonstration, vous pouvez utiliser directement le lien ci-dessous :</p>
          <div class="reset-url" id="resetUrl"><%= request.getAttribute("resetLink") %></div>
          <button class="copy-btn" id="copyBtn">
            <i class="fas fa-copy"></i> Copier le lien
          </button>
          <p><small>Note: Cette fonctionnalité est uniquement pour la démonstration et devrait être supprimée en production.</small></p>
        </div>
      <% } %>
    <% } else { %>
      <!-- Formulaire uniquement affiché si pas de message de succès -->
      <form action="reset-password.jsp" method="POST">
        <div class="form-group">
          <label for="email">Adresse email</label>
          <div class="input-with-icon">
            <i class="fas fa-envelope"></i>
            <input type="email" id="email" name="email" placeholder="Entrez votre adresse email" required>
          </div>
        </div>
        
        <button type="submit" class="btn">
          <i class="fas fa-paper-plane"></i>
          Envoyer le lien
        </button>
      </form>
    <% } %>
    
    <a href="login.jsp" class="back-link">
      <i class="fas fa-arrow-left"></i>
      Retour à la page de connexion
    </a>
  </div>

  <!-- Script pour la fonctionnalité de copie -->
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      const copyBtn = document.getElementById('copyBtn');
      if (copyBtn) {
        copyBtn.addEventListener('click', function() {
          const resetUrl = document.getElementById('resetUrl');
          const range = document.createRange();
          range.selectNode(resetUrl);
          window.getSelection().removeAllRanges();
          window.getSelection().addRange(range);
          
          try {
            const successful = document.execCommand('copy');
            const msg = successful ? 'Lien copié avec succès!' : 'Erreur lors de la copie';
            
            // Changer temporairement le texte du bouton
            const originalText = copyBtn.innerHTML;
            copyBtn.innerHTML = `<i class="fas fa-check"></i> ${msg}`;
            
            setTimeout(function() {
              copyBtn.innerHTML = originalText;
            }, 2000);
          } catch (err) {
            console.error('Impossible de copier le texte: ', err);
          }
          
          window.getSelection().removeAllRanges();
        });
      }
    });
  </script>
</body>
</html>