<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Customers" />
<c:set var="hideFooter" value="true" />
<%@ include file="../common/header.jspf" %>
<%@ include file="sidebar.jspf" %>

<div class="mb-4"><h1 class="h3 mb-0">Customers</h1><small class="text-muted-sw">${fn:length(users)} registered accounts</small></div>

<div class="table-sw">
  <div class="table-responsive">
    <table class="table table-hover">
      <thead><tr><th>#</th><th>Name</th><th>Email</th><th>Phone</th><th>Role</th><th>Joined</th><th>Orders</th><th>Total spent</th></tr></thead>
      <tbody>
        <c:forEach items="${users}" var="u">
          <tr>
            <td class="text-muted-sw">${u.id}</td>
            <td class="fw-semibold">${fn:escapeXml(u.fullName)}</td>
            <td>${fn:escapeXml(u.email)}</td>
            <td>${fn:escapeXml(u.phone)}</td>
            <td><span class="badge ${u.admin ? 'bg-ink' : 'text-bg-light border'}">${u.role}</span></td>
            <td><fmt:formatDate value="${u.createdAt}" pattern="dd MMM yyyy" /></td>
            <td>${u.orderCount}</td>
            <td class="fw-semibold">&#8377;<fmt:formatNumber value="${u.totalSpent}" maxFractionDigits="0" /></td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </div>
</div>

  </div>
</div>
<%@ include file="../common/footer.jspf" %>
