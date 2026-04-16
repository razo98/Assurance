<%@ page import="java.sql.*, java.time.*, java.time.temporal.ChronoUnit" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
int id = Integer.parseInt(request.getParameter("id"));
String client = "", marque = "", immatriculation = "", agents = "";
int puissance = 0;
double prixTTC = 0.0, prixRemb = 0.0, prixJournalier = 0.0;
long joursRestants = 0;

Connection conn = null;
PreparedStatement ps = null, psSelect = null;
ResultSet rs = null;

try {
    Class.forName("org.mariadb.jdbc.Driver");
    conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/assurance", "root", "");

    String select = "SELECT * FROM assurance a JOIN voiture v ON a.id_voiture = v.id_voiture WHERE id_assurance = ?";
    psSelect = conn.prepareStatement(select);
    psSelect.setInt(1, id);
    rs = psSelect.executeQuery();

    if(rs.next()) {
        LocalDate today = LocalDate.now();
        LocalDate dateDebut = rs.getDate("date_debut").toLocalDate();
        LocalDate dateFin = rs.getDate("date_fin").toLocalDate();
        prixTTC = rs.getDouble("prix_ttc");
        client = rs.getString("clients");
        marque = rs.getString("marque");
        immatriculation = rs.getString("immatriculation");
        puissance = rs.getInt("puissance");
        agents = rs.getString("agents");

        long totalJours = ChronoUnit.DAYS.between(dateDebut, dateFin);
        joursRestants = ChronoUnit.DAYS.between(today, dateFin);
        if (joursRestants < 0) joursRestants = 0;

        prixJournalier = prixTTC / totalJours;
        prixRemb = prixJournalier * joursRestants;

        String update = "UPDATE assurance SET resiliation = 1, prixremb = ?, status = ? WHERE id_assurance = ?";
        ps = conn.prepareStatement(update);
        ps.setDouble(1, prixRemb);
        ps.setString(2, "Resilié");
        ps.setInt(3, id);
        ps.executeUpdate();
    }
} catch(Exception e) {
    out.println("Erreur : " + e.getMessage());
} finally {
    if(rs != null) rs.close();
    if(psSelect != null) psSelect.close();
    if(ps != null) ps.close();
    if(conn != null) conn.close();
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Génération PDF de Résiliation</title>
</head>
<body>

<!-- Génération PDF avec tableau -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.23/jspdf.plugin.autotable.min.js"></script>
<script>
window.onload = function() {
  try {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();

    const img = new Image();
    img.src = "../images/entete.JPG";
    
    img.onload = function() {
      try {
        doc.addImage(img, 'JPEG', 10, 10, 190, 30);
        let startY = 45;

        doc.setFontSize(14);
        doc.text("Attestation de Résiliation", 70, startY);
        startY += 10;

        const columns = ["Champ", "Valeur"];
        const data = [
          ["Nom du client", "<%= client != null ? client.replace("\"", "\\\"") : "" %>"],
          ["Marque", "<%= marque != null ? marque.replace("\"", "\\\"") : "" %>"],
          ["Immatriculation", "<%= immatriculation != null ? immatriculation.replace("\"", "\\\"") : "" %>"],
          ["Puissance", "<%= puissance %>"],
          ["Prime journalière", "<%= String.format("%.2f", prixJournalier) %> DT"],
          ["Jours restants", "<%= joursRestants %>"],
          ["Montant remboursé", "<%= String.format("%.2f", prixRemb) %> DT"]
        ];

        doc.autoTable({
          startY: startY + 5,
          head: [columns],
          body: data,
          theme: 'grid',
          headStyles: { fillColor: [46, 125, 50] },
          styles: { fontSize: 10 }
        });

        const pageHeight = doc.internal.pageSize.getHeight();
        const pageWidth = doc.internal.pageSize.getWidth();

        const today = new Date();
        const dateText = `Niamey le : ${today.toLocaleDateString()} à ${today.toLocaleTimeString()}`;
        doc.setFontSize(10);
        doc.text(dateText, 10, pageHeight - 10);
        doc.text("Agent : <%= agents != null ? agents.replace("\"", "\\\"") : "" %>", pageWidth - 60, pageHeight - 10);

        doc.save("resiliation_<%= id %>.pdf");
        
        // Redirection après un petit délai
        setTimeout(function() {
          window.location.href = "agentaffichageassurance.jsp?msg=Résiliée avec succès";
        }, 1000);
        
      } catch(pdfError) {
        console.error("Erreur lors de la génération du PDF:", pdfError);
        alert("Erreur lors de la génération du PDF: " + pdfError.message);
        window.location.href = "agentaffichageassurance.jsp?msg=Erreur génération PDF";
      }
    };

    img.onerror = function() {
      console.warn("Image non trouvée, génération du PDF sans image");
      try {
        let startY = 20;

        doc.setFontSize(14);
        doc.text("Attestation de Résiliation", 70, startY);
        startY += 10;

        const columns = ["Champ", "Valeur"];
        const data = [
          ["Nom du client", "<%= client != null ? client.replace("\"", "\\\"") : "" %>"],
          ["Marque", "<%= marque != null ? marque.replace("\"", "\\\"") : "" %>"],
          ["Immatriculation", "<%= immatriculation != null ? immatriculation.replace("\"", "\\\"") : "" %>"],
          ["Puissance", "<%= puissance %>"],
          ["Prime journalière", "<%= String.format("%.2f", prixJournalier) %> DT"],
          ["Jours restants", "<%= joursRestants %>"],
          ["Montant remboursé", "<%= String.format("%.2f", prixRemb) %> DT"]
        ];

        doc.autoTable({
          startY: startY + 5,
          head: [columns],
          body: data,
          theme: 'grid',
          headStyles: { fillColor: [46, 125, 50] },
          styles: { fontSize: 10 }
        });

        const pageHeight = doc.internal.pageSize.getHeight();
        const pageWidth = doc.internal.pageSize.getWidth();

        const today = new Date();
        const dateText = `Niamey le : ${today.toLocaleDateString()} à ${today.toLocaleTimeString()}`;
        doc.setFontSize(10);
        doc.text(dateText, 10, pageHeight - 10);
        doc.text("Agent : <%= agents != null ? agents.replace("\"", "\\\"") : "" %>", pageWidth - 60, pageHeight - 10);

        doc.save("resiliation_<%= id %>.pdf");
        
        setTimeout(function() {
          window.location.href = "agentaffichageassurance.jsp?msg=Résiliée avec succès (sans image)";
        }, 1000);
        
      } catch(pdfError) {
        console.error("Erreur lors de la génération du PDF:", pdfError);
        alert("Erreur lors de la génération du PDF: " + pdfError.message);
        window.location.href = "agentaffichageassurance.jsp?msg=Erreur génération PDF";
      }
    };
    
  } catch(globalError) {
    console.error("Erreur globale:", globalError);
    alert("Erreur lors de l'initialisation: " + globalError.message);
    window.location.href = "agentaffichageassurance.jsp?msg=Erreur initialisation PDF";
  }
};
</script>

<div style="text-align: center; margin-top: 50px;">
    <h3>Génération du PDF en cours...</h3>
    <p>Le téléchargement va commencer automatiquement.</p>
</div>

</body>
</html>