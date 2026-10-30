<%@ page isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="code" value="${requestScope['jakarta.servlet.error.status_code']}" />
<c:set var="pageTitle" value="${code == 404 ? 'Page not found' : 'Error'}" />
<%@ include file="common/header.jspf" %>

<div class="container py-5 text-center" style="max-width:620px">
  <div class="display-1 fw-bold text-accent display-font">${empty code ? 'Oops' : code}</div>
  <h1 class="h3 mb-3">
    <c:choose>
      <c:when test="${code == 404}">We couldn't find that page</c:when>
      <c:when test="${code == 403}">This area is for administrators only</c:when>
      <c:otherwise>Something went wrong on our side</c:otherwise>
    </c:choose>
  </h1>
  <p class="text-muted-sw mb-4">${fn:escapeXml(requestScope['jakarta.servlet.error.message'])}</p>
  <a href="${ctx}/home" class="btn btn-accent">Back to the store</a>
</div>

<%@ include file="common/footer.jspf" %>
