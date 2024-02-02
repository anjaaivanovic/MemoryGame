<%
    String error = "";
    String username = "";
    String password = "";
    String password1 = "";

    if (session.getAttribute("id") != null)
    {
        if ((int)session.getAttribute("role") == 2) response.sendRedirect("admin.jsp");
        else response.sendRedirect("user.jsp");
    }

    session.setAttribute("error", null);
    if (session.getAttribute("regError") != null) error = (String)session.getAttribute("regError");
    if (session.getAttribute("username") != null) username = (String)session.getAttribute("username");

%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Memory Game - Register</title>
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
        <h2>Register</h2>
        <form method="post" action="registerServlet">
          <!-- Username input -->
          <div class="form-outline mb-4">
            <input type="text" class="form-control form-control-lg" name="username" required pattern="^[A-Za-z0-9_]{2,16}$"
                   title="Username length must be between 2 and 16 characters and can contain letters, numbers and underscores"
                   placeholder="Username" value="<%=username%>"/>
          </div>
          <!-- Password input -->
          <div class="form-outline mb-4">
            <input type="password" class="form-control form-control-lg" name="password" required pattern="^[A-Za-z0-9]{2,16}$"
                   title="Password length must be between 2 and 16 characters and can contain letters and numbers"
                   placeholder="Password" value="<%=password%>"/>
          </div>
          <!-- Repeat Password input -->
          <div class="form-outline mb-4">
            <input type="password" class="form-control form-control-lg" name="password1" required pattern="^[A-Za-z0-9]{2,16}$"
                   title="Password length must be between 2 and 16 characters and can contain letters and numbers"
                   placeholder="Repeat password" value="<%=password1%>"/>
          </div>
            <div class="form-outline mb-4" id="error">
                <%=error%>
            </div>
          <!-- Submit button -->
          <button type="submit" class="btn btn-primary btn-lg btn-block" name="register" value="1">Register</button>
        </form><br>
        <div class="form-outline mb-4">
          Already have an account? Log in <a href="index.jsp">here</a>.
        </div>
      </div>
    </div>
  </div>
</section>
<div id="manual">
    <jsp:include page="manual.html"/>
</div>
</body>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>
</html>