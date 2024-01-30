<%@ page import="jakarta.persistence.EntityManager" %>
<%@ page import="com.example.projekat.Database" %>
<%@ page import="entities.UserEntity" %>
<%@ page import="rmi.ILeaderboardRMI" %>
<%@ page import="java.rmi.Naming" %>
<%@ page import="java.net.MalformedURLException" %>
<%@ page import="java.rmi.RemoteException" %>
<%@ page import="java.rmi.NotBoundException" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String username = "", leaderboard = "", rank = "";
    int gamesPlayed = 0, gamesWon = 0;

    if (session.getAttribute("id") == null) response.sendRedirect("index.jsp");
    else{
        EntityManager em = Database.getConnection();
        String sql = "select * from users where id=" + session.getAttribute("id");
        UserEntity user = (UserEntity)em.createNativeQuery(sql, UserEntity.class).getResultList().get(0);

        username = user.getUsername();
        if (user.getRank() != null) rank = user.getRank(); else rank = "-";
        gamesPlayed = user.getGamesPlayed();
        gamesWon = user.getGamesWon();

        ILeaderboardRMI rmi;

        try {
            rmi = (ILeaderboardRMI) Naming.lookup("rmi://localhost:1111/LeaderboardRMI");
            leaderboard = rmi.getLeaderboard();
            System.out.println(rmi);
            System.out.println(leaderboard);
        } catch (MalformedURLException | RemoteException | NotBoundException e1) {
            e1.printStackTrace();
        }
    }
%>
<html>
<head>
    <title>Memory Game - Statistics</title>
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
    <div class="container">
        <div class="row justify-content-between" style="margin-top: 5%">
            <div class="col-3" id="userInfo" style="justify-content: center; text-align: center">
                <div style="width: 80%; justify-content: center; text-align: center">
                    <img src="images/RANK.png" alt="rank" style="width: 60%; padding-right: 8%">
                    <img src="images/<%=rank%>.png" alt="Rank" style="width: 30%">
                </div>
                <h1>Username: <%=username%></h1>
                <div class="card w-50">
                    <div class="card-body">Played / Won<br><%=gamesPlayed%> / <%=gamesWon%></div>
                </div>
            </div>
            <div class="col-8" id="leaderboard">
                <%=leaderboard%>
            </div>
        </div>
    </div>
</section>
<div id="manual">
    <jsp:include page="manual.html"/>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>
</body>
<style>
    #stats a{
        font-weight: lighter;
        font-size: 130%;
        color: white;
    }
</style>
</html>
