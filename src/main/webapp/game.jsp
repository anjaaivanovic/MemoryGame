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
    <link href="styles/nav.css" rel="stylesheet">
</head>
<body onload="getBoard()">
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
        <div class="container-fluid">
            <div class="row justify-content-around" style="height: 70vh">
                <div class="col-lg-6 col-md-12 col-sm-12" style="text-align: center">
                    <div id="scores"><span id="score">0</span><span> : </span><span id="otherScore">0</span></div><br>
                    <div id="gameBoard">

                    </div>
                </div>
                <div class="col-lg-3 col-md-12 col-sm-12" style="text-align: center">
                    <div id="chatDiv">
                        <h2>Chat</h2><br>
                        <div id="chat" class="overflow-auto"></div>
                        <input type="text" placeholder="Write message..." id="chatInput"><button onclick="sendMessage()">Send</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/socket.io/4.5.4/socket.io.js"></script>
    <script src="js/client.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>
</body>
<style>
    #chat{
        height: 75%;
        text-align: left;
    }

    #chatInput{
        padding: 8px;
        width: 75%;
        border-radius: 12px 0px 0px 12px;
    }

    #chatDiv button{
        padding: 8px;
        width: 25%;
        border-radius: 0px 12px 12px 0px;

    }

    #scores{
        margin: auto;
        font-size: 300%;
        font-weight: bolder;
        color: #21807c;
    }

    h2{
        margin: auto;
        font-size: 300%;
        font-weight: lighter;
        color: #21807c;
    }
</style>
</html>
