<%@page import="com.example.projekat.Database"%>
<%@ page import="jakarta.persistence.EntityManager" %>
<%@ page import="entities.UserEntity" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
  //players
  String playerStr = "<h1>Registered Players</h1>" +
          "<table class='table'>" +
          "<thead class='thead-dark'>" +
          "<tr>" +
          "<th scope='col'>Username</th>" +
          "<th scope='col'>Stats</th>" +
          "<th scope='col'>Rank</th>" +
          "<th scope='col'>Promotion</th>" +
          "<th scope='col'>Deletion</th>" +
          "</tr></thead>" +
          "<tbody>";

  //admins
  String adminStr = "<h1>Administrators</h1>" +
          "<table class='table'>" +
          "<thead class='thead-dark'>" +
          "<tr>" +
          "<th scope='col'>Username</th>" +
          "<th scope='col'>Demotion</th>" +
          "<th scope='col'>Deletion</th>" +
          "</tr></thead>" +
          "<tbody>";

  String playerPagination = "";
  String adminPagination = "";

  int itemsPerPage = 2;
  int pageNumber = 1;
  int offset = 0;

  if (session.getAttribute("id") == null || (int)session.getAttribute("role") == 1)
  {
    String redirect = "";
    if (session.getAttribute("id") == null) redirect = "index.jsp";
    else if ((int)session.getAttribute("role") == 1) redirect = "user.jsp";
    if (redirect != "") response.sendRedirect(redirect);
  }
  else
  {
    EntityManager entityManager = Database.getConnection();

    if (request.getParameter("delete") != null){

      UserEntity user = entityManager.find(UserEntity.class, Integer.parseInt(request.getParameter("delete")));
      entityManager.getTransaction().begin();
      entityManager.remove(user);
      entityManager.getTransaction().commit();
    }

    if (request.getParameter("promote") != null){
      UserEntity user = entityManager.find(UserEntity.class, Integer.parseInt(request.getParameter("promote")) );
      entityManager.getTransaction().begin();
      user.setRoleId(2);
      entityManager.getTransaction().commit();
    }

    if (request.getParameter("demote") != null){

      UserEntity user = entityManager.find(UserEntity.class, Integer.parseInt(request.getParameter("demote")));
      entityManager.getTransaction().begin();
      user.setRoleId(1);
      entityManager.getTransaction().commit();
    }

    //pagination preparation (player and admin count)
    String sql = "select count(id) from users where roleId = 1";
    int totalPlayers = ((Number)(entityManager.createNativeQuery(sql).getSingleResult())).intValue();
    sql = "select count(id) from users where roleId = 2";
    int totalAdmins = ((Number)(entityManager.createNativeQuery(sql).getSingleResult())).intValue();

    if (request.getParameter("page") == null || request.getParameter("adminPage") == null) response.sendRedirect("admin.jsp?page=1&adminPage=1");
    else{
      pageNumber = Integer.parseInt(request.getParameter("page"));
      offset = (pageNumber - 1) * itemsPerPage;
    }

    //fetch players by page number
    sql = "select * from users where roleId = 1 limit " + itemsPerPage + " offset " + offset;

    @SuppressWarnings("unchecked")
    List<UserEntity> players = entityManager.createNativeQuery(sql, UserEntity.class).getResultList();

    int adminPageNumber = 1;
    int adminOffset = 0;
    if (request.getParameter("adminPage") != null)
    {
      adminPageNumber = Integer.parseInt(request.getParameter("adminPage"));
      adminOffset = (adminPageNumber - 1) * itemsPerPage;
    }

    //fetch admins by page number
    sql = "select * from users where roleId = 2 limit " + itemsPerPage + " offset " + adminOffset;
    @SuppressWarnings("unchecked")
    List<UserEntity> admins = entityManager.createNativeQuery(sql, UserEntity.class).getResultList();


    for (int i = 1; i <= Math.ceil((double) totalPlayers / itemsPerPage); i++) {
      if (i != pageNumber) playerPagination += "<a href='admin.jsp?page=" + i + "&adminPage="+ adminPageNumber +"'>" + i +"</a>";
      else playerPagination += "<a href='admin.jsp?page=" + i + "&adminPage="+ adminPageNumber +"' style='background-color:#32C6C2;color:white'>" + i +"</a>";
    }
    for (int i = 1; i <= Math.ceil((double) totalAdmins / itemsPerPage); i++) {
      if (i != adminPageNumber) adminPagination += "<a href='admin.jsp?adminPage=" + i + "&page="+ pageNumber +"'>" + i +"</a>";
      else adminPagination += "<a href='admin.jsp?adminPage=" + i + "&page="+ pageNumber +"' style='background-color:#32C6C2;color:white'>" + i +"</a>";
    }

    //players
    for (UserEntity p: players){
      String rank = "-";
      if (p.getRank() != null && !p.getRank().equals("-")) rank = p.getRank();
      playerStr += "<tr>" +
              "<td>"+ p.getUsername() + "</td>" +
              "<td>"+ p.getGamesWon()+ " / " + p.getGamesPlayed() + "</td>" +
              "<td>" + rank + "</td>" +
              "<td><div class='text-center'><button type='button' class='btn btn-primary' data-bs-toggle='modal' data-bs-target='#promoteModal-"+p.getId()+"'>Promote to admin</button></div></td>" +
              "<div class='modal fade' id='promoteModal-" + p.getId() + "' tabindex='-1' role='dialog' aria-labelledby='promoteModalLabel' aria-hidden='true'>"
              + "<div class='modal-dialog'>"
              + "<div class='modal-content'>"
              + "<div class='modal-header'>"
              + "<h5 class='modal-title' fs-5 id='promoteModalLabel'>Promote to admin?</h5>"
              + "<button type='button' class='btn-close' data-bs-dismiss='modal' aria-label='Cancel'></button>"
              + "</div>"
              + "<div class='modal-body'>"
              + "<p>Are you sure you want to promote this player to admin?</p>"
              + "</div>"
              + "<div class='modal-footer'>"
              + "<button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Cancel</button>"
              + "<form><button type='submit' class='btn btn-primary' name='promote' value='" + p.getId() + "'>Promote</button></form>"
              + "</div>"
              + "</div>"
              + "</div>"
              + "</div>"+
              "<td><button type='button' class='btn btn-primary' data-bs-toggle='modal' data-bs-target='#deleteModal-"+p.getId()+"'>Delete</button></td>" +
              "<div class='modal fade' id='deleteModal-" + p.getId() + "' tabindex='-1' role='dialog' aria-labelledby='deleteModalLabel' aria-hidden='true'>"
              + "<div class='modal-dialog'>"
              + "<div class='modal-content'>"
              + "<div class='modal-header'>"
              + "<h5 class='modal-title' fs-5 id='promoteModalLabel'>Delete player?</h5>"
              + "<button type='button' class='btn-close' data-bs-dismiss='modal' aria-label='Cancel'></button>"
              + "</div>"
              + "<div class='modal-body'>"
              + "<p>Are you sure you want to delete this player?</p>"
              + "</div>"
              + "<div class='modal-footer'>"
              + "<button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Cancel</button>"
              + "<form><button type='submit' class='btn btn-primary' name='delete' value='" + p.getId() + "'>Delete</button></form>"
              + "</div>"
              + "</div>"
              + "</div>"
              + "</div>"+
              "</tr>";
    }

    playerStr += "</tbody></table>";

    for (UserEntity a: admins){
      adminStr += "<tr>" +
              "<td>"+ a.getUsername() + "</td>" +
              "<td><div class='text-center'><button type='button' class='btn btn-primary' data-bs-toggle='modal' data-bs-target='#demoteModal-"+a.getId()+"'>Demote to player</button></div></td>" +
              "<div class='modal fade' id='demoteModal-" + a.getId() + "' tabindex='-1' role='dialog' aria-labelledby='demoteModalLabel' aria-hidden='true'>"
              + "<div class='modal-dialog'>"
              + "<div class='modal-content'>"
              + "<div class='modal-header'>"
              + "<h5 class='modal-title' fs-5 id='demoteModalLabel'>Demote to player?</h5>"
              + "<button type='button' class='btn-close' data-bs-dismiss='modal' aria-label='Cancel'></button>"
              + "</div>"
              + "<div class='modal-body'>"
              + "<p>Are you sure you want to demote this admin to player?</p>"
              + "</div>"
              + "<div class='modal-footer'>"
              + "<button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Cancel</button>"
              + "<form><button type='submit' class='btn btn-primary' name='demote' value='" + a.getId() + "'>Demote</button></form>"
              + "</div>"
              + "</div>"
              + "</div>"
              + "</div>"+
              "<td><button type='button' class='btn btn-primary' data-bs-toggle='modal' data-bs-target='#deleteModal-"+a.getId()+"'>Delete</button></td>" +
              "<div class='modal fade' id='deleteModal-" + a.getId() + "' tabindex='-1' role='dialog' aria-labelledby='deleteModalLabel' aria-hidden='true'>"
              + "<div class='modal-dialog'>"
              + "<div class='modal-content'>"
              + "<div class='modal-header'>"
              + "<h5 class='modal-title' fs-5 id='promoteModalLabel'>Delete admin?</h5>"
              + "<button type='button' class='btn-close' data-bs-dismiss='modal' aria-label='Cancel'></button>"
              + "</div>"
              + "<div class='modal-body'>"
              + "<p>Are you sure you want to delete this admin?</p>"
              + "</div>"
              + "<div class='modal-footer'>"
              + "<button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Cancel</button>"
              + "<form><button type='submit' class='btn btn-primary' name='delete' value='" + a.getId() + "'>Delete</button></form>"
              + "</div>"
              + "</div>"
              + "</div>"
              + "</div>"+
              "</tr>";
    }

    adminStr += "</table></div>";
  }
%>

<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Memory Game - Administration</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Lexend&display=swap" rel="stylesheet">
  <link href="styles/forms.css" rel="stylesheet">
  <link href="styles/nav.css" rel="stylesheet">
</head>
<body>
<!-- Logout Modal -->
<div class="modal fade" id="logoutModal" tabindex="-1" aria-labelledby="logoutModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h1 class="modal-title fs-5" id="logoutModalLabel">Logout?</h1>
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
    <div class="collapse navbar-collapse" id="navbarText">
          <a class="nav-link ml-auto" data-bs-toggle="modal" data-bs-target="#logoutModal" style="cursor: pointer">Logout</a>
    </div>
  </nav>
  <div class="container">
    <div class="row">
      <%=playerStr%><br>
      <div class="pagination"><%=playerPagination%></div>
    </div>
    <br>
    <div class="row">
      <%=adminStr%>
      <div class="pagination"><%=adminPagination%></div>
    </div>
  </div>
</section>
<div id="manual">
  <jsp:include page="manual.html"/>
</div>
</body>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>
<style>
  td {
    text-align: center;
    vertical-align: middle;
  }
  th {
    text-align: center;
    vertical-align: middle;
  }
  .container{
    margin-top: 2%;
    margin-bottom: 15%;
  }

  .pagination {
    display: flex;
    justify-content: center;
    margin-top: 10px;
  }

  .pagination a {
    padding: 8px 16px;
    text-decoration: none;
    background-color: #f1f1f1;
    color: #000;
    margin: 0 4px;
    border-radius: 8px;
    box-shadow: 2px 2px 5px #aaaaaa;
  }

  table{
    border-radius: 18px;
    box-shadow: 5px 5px 10px #aaaaaa;
  }
</style>
</html>
