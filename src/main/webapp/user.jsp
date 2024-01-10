<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session.getAttribute("id") == null) response.sendRedirect("index.jsp");
%>

<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Memory Game - Homepage</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    <link href="styles/forms.css" rel="stylesheet">
    <link href="styles/nav.css" rel="stylesheet">
</head>
<body>
<!-- Logout Modal -->
<div class="modal fade" id="logoutModal" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="loginModalLabel">Logout?</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                Are you sure you want to log out?
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" onclick="window.location = 'logout.jsp'">Logout</button>
            </div>
        </div>
    </div>
</div>
<section class="vh-100">
<nav class="navbar navbar-expand-lg navbar-light">
    <span class="navbar-text mr-4">Memory Game</span>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarText" aria-controls="navbarText" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="home">
        <a class="nav-link ml-auto"  href="user.jsp">Home page</a>
    </div>
    <div class="collapse navbar-collapse" id="stats">
        <a class="nav-link ml-auto"  href="stats.jsp">Statistics</a>
    </div>
    <div class="collapse navbar-collapse" id="logout">
        <a class="nav-link ml-auto" data-bs-toggle="modal" data-bs-target="#logoutModal" style="cursor: pointer">Logout</a>
    </div>
</nav>
<div class="card">
    <div class="card-body">
        <h5 class="card-title">Welcome to Memory Game!</h5>
        <br>
        <p class="card-text">
            Flip and match cards strategically to outsmart your opponents and emerge as victorious with the most successful guesses. Quick thinking and sharp memory are your tickets to victory.<br><br>
            To find an opponent and start a game, please join the queue.
        </p>
        <br>
        <a href="#" class="btn btn-primary" id="join">Join queue</a>
    </div>
</div>
</section>
<div id="manual">
    <jsp:include page="manual.html"/>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>
</body>
<style>
    #home a{
        font-weight: lighter;
        font-size: 130%;
        color: white;
    }
    body{
        background-image: url('images/Untitled design2.png');
        background-size: cover;
        background-position: center;
        background-attachment: fixed;
    }
    .card{
        width: 40%;
        height: 40%;
        margin-top: 10%;
        margin-left: 30%;
        border-radius: 12px;
    }
    .card-text{
        color: #484848;
    }

    .card-title{
        font-size: 130%;
        color: #21807c;
    }

    #join{
        width: 80%;
        margin-left: 10%;
        font-size: 110%;
        padding: 2%;
        border-radius: 10px;
    }

</style>
</html>
