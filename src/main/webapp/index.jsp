<%-- Root welcome file: forward to HomeServlet --%>
<%@ page contentType="text/html;charset=UTF-8" %>
<% response.sendRedirect(request.getContextPath() + "/home"); %>
