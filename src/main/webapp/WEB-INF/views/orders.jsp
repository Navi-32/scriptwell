<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="My orders" />
<%@ include file="common/header.jspf" %>

<div class="container py-4" style="max-width:960px">
  <h1 class="h2 mb-4">My orders</h1>
  <c:if test="${not empty error}"><div class="alert alert-danger">${error}</div></c:if>
  <c:choose>
    <c:when test="${empty orders}">
      <div class="panel text-center py-5">
        <i class="bi bi-receipt fs-1 text-muted-sw"></i>
        <h4 class="mt-3">No orders yet</h4>
        <p class="text-muted-sw">When you buy a book it will show up here.</p>
        <a href="${ctx}/books" class="btn btn-accent">Browse books</a>
      </div>
    </c:when>
    <c:otherwise>
      <c:forEach items="${orders}" var="o">
        <a href="${ctx}/order?id=${o.id}" class="panel d-flex flex-wrap gap-3 align-items-center mb-3 text-decoration-none text-reset">
          <img src="${ctx}/assets/covers/${o.firstCover}" class="cart-thumb" style="width:52px" alt="">
          <div class="flex-grow-1">
            <div class="fw-semibold">Order #${o.id}</div>
            <div class="small text-muted-sw"><fmt:formatDate value="${o.orderDate}" pattern="dd MMM yyyy" /> &middot; ${o.itemCount} item${o.itemCount == 1 ? '' : 's'} &middot; ${o.paymentMethod}</div>
          </div>
          <span class="badge text-bg-${o.statusColor}">${o.status}</span>
          <div class="fw-bold" style="width:90px;text-align:right">&#8377;<fmt:formatNumber value="${o.total}" maxFractionDigits="0" /></div>
          <i class="bi bi-chevron-right text-muted-sw"></i>
        </a>
      </c:forEach>
    </c:otherwise>
  </c:choose>
</div>

<%@ include file="common/footer.jspf" %>
