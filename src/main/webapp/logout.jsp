<%
  session.setAttribute("id", null);
  session.setAttribute("role", null);
  session.setAttribute("username", null);
  response.sendRedirect("index.jsp");
%>
