<%@ page import="java.util.UUID" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String gameId = request.getParameter("gameId");
%>
<html>
<head>
    <title>Memory Game #<%=gameId%></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    <link href="https://fonts.googleapis.com/css2?family=Lexend&display=swap" rel="stylesheet">
    <link href="styles/forms.css" rel="stylesheet">
</head>
<body onload="getBoard()">
<div id="countdown" hidden></div>
    <div class="container-fluid">
        <div class="row">
            <div class="col-9" id="gameBoard">

            </div>
            <div class="col-3">
                <!-- Content for the 3:9 section -->
                <h2>3:9 Section</h2>
                <p>This is the sidebar content for the 3:9 section.</p>
            </div>
        </div>
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/socket.io/4.5.4/socket.io.js"></script>
    <script src="js/client.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>
</body>
<style>
    /* Set max-width for larger screens to prevent horizontal scrolling */
    .container-fluid {
        height: 100vh;
    }
</style>
</html>
