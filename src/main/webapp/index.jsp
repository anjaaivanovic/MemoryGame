<%@ page import="jakarta.persistence.EntityManager" %>
<%@ page import="com.example.projekat.Database" %>
<%@ page import="entities.UserEntity" %>
<%@ page import="java.util.List" %>
<%
    EntityManager entityManager = Database.getConnection();
    String error = "";
    String username = "";

    if (session.getAttribute("id") != null){
        if ((int)session.getAttribute("role") == 2) response.sendRedirect("admin.jsp");
        else response.sendRedirect("user.jsp");
    }
    if (request.getParameter("username") != null) username = request.getParameter("username");

    if (request.getParameter("login") != null){
        if (request.getParameter("password") == null  || request.getParameter("password").length() == 0|| request.getParameter("username") == null || request.getParameter("username").length() == 0){
            session.setAttribute("error", "Please check all fields!");
        }
        else
        {
            String sql = "select * from users where username = '" + request.getParameter("username") + "'";

            @SuppressWarnings("unchecked")
            List<UserEntity> u = entityManager.createNativeQuery(sql, UserEntity.class).getResultList();
            if (u.size() == 0) {
                session.setAttribute("error", "Invalid username!");
            }
            else {
                UserEntity user = u.get(0);
                if (!user.getPassword().equals(request.getParameter("password"))) {
                    session.setAttribute("error", "Invalid password!");
                }
                else
                {
                    session.setAttribute("username", user.getUsername());
                    session.setAttribute("id", user.getId());
                    session.setAttribute("role", user.getRoleId());

                    if (user.getRoleId() == 1) response.sendRedirect("user.jsp");
                    else response.sendRedirect("admin.jsp");
                }
            }
        }
    }

    if (session.getAttribute("error") != null) error = (String)session.getAttribute("error");

%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Memory Game - Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    <link href="https://fonts.googleapis.com/css2?family=Lexend&display=swap" rel="stylesheet">
    <link href="styles/forms.css" rel="stylesheet">
</head>
<body onload="sessionStorage.clear();">
<section class="vh-100">
    <div class="container py-5 h-100">
        <div class="row d-flex align-items-center justify-content-center h-100">
            <div class="col-md-8 col-lg-7 col-xl-6">
                <img src="images/header.png"
                     class="img-fluid" alt="Header">
            </div>
            <div class="col-md-6 col-lg-4 col-xl-4 offset-xl-1">
                    <h1>MEMORY GAME</h1><br>
                    <h2>Login</h2>
                <form method="post">
                    <!-- Username input -->
                    <div class="form-outline mb-4">
                        <input type="text" class="form-control form-control-lg" name="username" placeholder="Username" value="<%=username%>"/>
                    </div>
                    <!-- Password input -->
                    <div class="form-outline mb-4">
                        <input type="password" class="form-control form-control-lg" name="password" placeholder="Password"/>
                    </div>
                    <div class="form-outline mb-4" id="error">
                        <%=error%>
                    </div>
                    <!-- Submit button -->
                    <button type="submit" class="btn btn-primary btn-lg btn-block" name="login" value="1">Log in</button>
                </form><br>
                <div class="form-outline mb-4">
                No account? Register <a href="register.jsp">here</a>.<br>
                </div>
            </div>
        </div>
    </div>
</section>
<div id="manual">
    <jsp:include page="manual.html"/>
</div>
</body>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.10.2/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>
</html>

