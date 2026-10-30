<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Inventory" />
<c:set var="hideFooter" value="true" />
<%@ include file="../common/header.jspf" %>
<%@ include file="sidebar.jspf" %>

<div class="mb-4"><h1 class="h3 mb-0">Inventory</h1><small class="text-muted-sw">Every stock change is recorded automatically by trigger <code>trg_books_stock_audit</code></small></div>

<div class="row g-4">
  <div class="col-xl-5">
    <h5 class="mb-2">Low stock (5 or fewer)</h5>
    <div class="table-sw">
      <table class="table">
        <thead><tr><th>Book</th><th>Stock</th><th>Restock</th></tr></thead>
        <tbody>
          <c:if test="${empty lowStock}"><tr><td colspan="3" class="text-muted-sw text-center py-3">Nothing to restock.</td></tr></c:if>
          <c:forEach items="${lowStock}" var="b">
            <tr>
              <td><div class="fw-semibold small">${fn:escapeXml(b.title)}</div><div class="small text-muted-sw">${fn:escapeXml(b.author)}</div></td>
              <td><span class="badge ${b.stock == 0 ? 'bg-secondary' : 'bg-danger'}">${b.stock}</span></td>
              <td>
                <form method="post" action="${ctx}/admin/books/stock" class="d-flex gap-1">
                  <input type="hidden" name="id" value="${b.id}">
                  <input type="number" name="change" value="20" class="form-control form-control-sm" style="width:70px">
                  <button class="btn btn-sm btn-accent"><i class="bi bi-plus-lg"></i></button>
                </form>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
  <div class="col-xl-7">
    <h5 class="mb-2">Stock movement log</h5>
    <div class="table-sw">
      <div class="table-responsive" style="max-height:560px">
        <table class="table table-sm">
          <thead class="sticky-top"><tr><th>#</th><th>Book</th><th>Old</th><th>New</th><th>Change</th><th>Reason</th><th>When</th></tr></thead>
          <tbody>
            <c:forEach items="${log}" var="l">
              <tr>
                <td class="text-muted-sw">${l.logId}</td>
                <td class="small">${fn:escapeXml(l.title)}</td>
                <td>${empty l.oldStock ? '&ndash;' : l.oldStock}</td>
                <td>${l.newStock}</td>
                <td class="fw-semibold ${l.change < 0 ? 'text-danger' : 'text-success'}">${l.change > 0 ? '+' : ''}${l.change}</td>
                <td class="small">${l.reason}</td>
                <td class="small text-muted-sw"><fmt:formatDate value="${l.changedAt}" pattern="dd MMM, HH:mm" /></td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

  </div>
</div>
<%@ include file="../common/footer.jspf" %>
