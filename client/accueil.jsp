<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
   Integer iduser = (Integer) session.getAttribute("iduser");
   String firstname = (String) session.getAttribute("firstname");
   String lastname = (String) session.getAttribute("lastname");
   String fullName = (String) session.getAttribute("fullname");
   if(iduser == null) {
      response.sendRedirect("../login.jsp");
      return;
   }
%>


<!DOCTYPE html>
<html lang="fr">
<head>
 <title> Accueil </title>
 <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
   <link href="../public/css/1bootstrap.min.css" rel="stylesheet">
   <link href="../public/css/2dataTables.bootstrap5.min.css" rel="stylesheet">
   <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" integrity="sha512-Fo3rlrZj/kTc56S9/9W0aG02+GhP0X7L1R9cy+ujp3IRh56slDw8p/0akfPlcFg5N97Z62ua6QrZbz9aZf8T5A==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    <script src="main.js"></script>
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.css" />
    <script type="text/javascript" src="../js/jquery.js" ></script>
    <script type="text/javascript" src="../js/bootstrap.js" ></script>
  <style>
    body {
      font-family: 'Arial', sans-serif;
      background: #f5f5f5;
      padding: 20px;
    }
        /* Positionnement en bas à droite */
    .bottom-right {
      position: fixed;
      bottom: 10px;
      right: 10px;
      background: rgba(0, 0, 0, 0.6);
      color: #fff;
      padding: 8px 12px;
      border-radius: 5px;
      font-size: 14px;
      z-index: 1000;
    }
    header {
      background: none;
      color: #fff;
      padding: 10px 20px;
      border-radius: 5px;
      margin-bottom: 20px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    footer h1 {
      margin: 0;
      font-size: 24px;
    }
    footer a {
      color: #fff;
      text-decoration: none;
      font-weight: bold;
    }
    /* Conteneur de navigation central */
    .nav-container {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      align-items: center;
      margin-top: 70px;
      padding: 0 20px;
    }
    .nav-item {
      background: #4CAF50;

      border-radius: 10px;
      box-shadow: 0 0 10px rgba(0,0,0,0.1);
      margin: 20px;
      padding: 30px 20px;
      width: 200px;
      text-align: center;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
      cursor: pointer;
    }
    .nav-item:hover {
      transform: translateY(-5px);
      box-shadow: 0 0 15px rgba(0,0,0,0.2);
    }
    .nav-item i {
      font-size: 36px;
      margin-bottom: 15px;
      color: #4CAF50;
      transition: color 0.3s ease;
    }
    .nav-item:hover i {
      color: #45a049;
    }
    .nav-item span {
      display: block;
      font-size: 18px;
      font-weight: bold;
      color: #fff;
      transition: color 0.3s ease;
    }
    .nav-item:hover span {
      color: #f78708;
    }
    .nav-item a {
      text-decoration: none;
      color: inherit;
      display: block;
    }
    .welcome-message {
      padding-top: 3%;
      text-align: center;
      margin-top: 10px;
      margin-bottom: 20px;
    }
    .welcome-message h1 {
      font-size: 24px;
      font-weight: bold;
      color: #3ff;
      margin-bottom: 10px;
    }
    .welcome-message h2 {
      font-size: 16px;
      color: #0f3;
      margin: 0;
    }
  </style>
</head>
<body>
  <%@ include file="../me.jsp" %>
    <div class="welcome-message">
    <h1>Bienvenue sur votre espace client</h1>
  </div>


  <!-- Texte en bas à droite -->
  <div class="bottom-right">
      <%= fullName %>
  </div>
    <!-- Conteneur central des liens -->
  <div class="nav-container">
    <!-- Lien : Devis instantané -->
    <div class="nav-item">
      <a href="devis.jsp">
        <span><i class="bi bi-three-dots"></i>&nbsp;Devis instantané</span>
      </a>
    </div>
    <!-- Lien : Consulter mon assurance -->
    <div class="nav-item">
      <a href="affichageassurance.jsp">
        <i class="fas fa-file-alt"></i>
        <span>Consultation assurance</span>
      </a>
    </div>
    <!-- Lien : Renouvellement -->
    <div class="nav-item">
      <a href="renouvellementclient.jsp">
        <i class="fas fa-ellipsis-h"></i>
        <span>Renouvellement</span>
      </a>
    </div>
    <!-- Lien : Suspension -->
    <div class="nav-item">
      <a href="suspension.jsp">
        <i class="fas fa-ban"></i>
        <span>Suspension</span>
      </a>
    </div>
    <!-- Lien : Résiliation -->
    <div class="nav-item">
      <a href="resiliation.jsp">
        <i class="fas fa-times-circle"></i>
        <span>Résiliation</span>
      </a>
    </div>
    <!-- Lien : Réclamation -->
    <div class="nav-item">
      <a href="reclamation.jsp">
        <i class="fas fa-comments"></i>
        <span>Réclamation</span>
      </a>
    </div>
  </div>
</body>
</html>
