<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Manage orders" />
<c:set var="hideFooter" value="true" />
<%@ include file="../common/header.jspf" %>
<%@ include file="sidebar.jspf" %>

<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
  <div><h1 class="h3 mb-0">Orders</h1><small class="text-muted-sw">${fn:length(orders)} orders${empty status ? '' : ' with status '.concat(status)}</small></div>
  <div class="btn-group">
    <a href="${ctx}/admin/orders" class="btn btn-sm ${empty status ? 'btn-ink' : 'btn-outline-ink'}">All</a>
    <c:forEach items="${['PLACED','SHIPPED','DELIVERED','CANCELLED']}" var="s">
      <a href="${ctx}/admin/orders?status=${s}" class="btn btn-sm ${status == s ? 'btn-ink' : 'btn-outline-ink'}">${s}</a>
    </c:forEach>
  </div>
</div>

<div class="table-sw">
  <div class="table-responsive">
    <table class="table table-hover">
      <thead><tr><th>Order</th><th>Customer</th><th>Date</th><th>Items</th><th>Payment</th><th>Total</th><th>Status</th><th>Update status</th></tr></thead>
      <tbody>
        <c:if test="${empty orders}"><tr><td colspan="8" class="text-center text-muted-sw py-4">No orders found.</td></tr></c:if>
        <c:forEach items="${orders}" var="o">
          <tr>
            <td><a href="${ctx}/order?id=${o.id}" class="fw-semibold text-decoration-none">#${o.id}</a></td>
            <td>${fn:escapeXml(o.customerName)}<div class="small text-muted-sw">${o.customerEmail}</div></td>
            <td><fmt:formatDate value="${o.orderDate}" pattern="dd MMM yyyy" /></td>
            <td>${o.itemCount}</td>
            <td>${o.paymentMethod}<div class="small text-muted-sw">${o.paymentRef}</div></td>
            <td class="fw-semibold">&#8377;<fmt:formatNumber value="${o.total}" maxFractionDigits="0" /></td>
            <td><span class="badge text-bg-${o.statusColor}">${o.status}</span></td>
            <td>
              <c:choose>
                <c:when test="${o.status == 'CANCELLED' or o.status == 'DELIVERED'}"><span class="small text-muted-sw">Closed</span></c:when>
                <c:otherwise>
                  <form method="post" action="${ctx}/admin/orders/status" class="d-flex gap-1">
                    <input type="hidden" name="id" value="${o.id}">
                    <input type="hidden" name="returnTo" value="/admin/orders${empty status ? '' : '?status='.concat(status)}">
                    <select name="status" class="form-select form-select-sm" style="width:130px">
                      <c:forEach items="${['PLACED','SHIPPED','DELIVERED','CANCELLED']}" var="s"><option ${o.status == s ? 'selected' : ''}>${s}</option></c:forEach>
                    </select>
                    <button class="btn btn-sm btn-accent"><i class="bi bi-check2"></i></button>
                  </form>
                </c:otherwise>
              </c:choose>
            </td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </div>
</div>

  </div>
</div>
<%@ include file="../common/footer.jspf" %>
