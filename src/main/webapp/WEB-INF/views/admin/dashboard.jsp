<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Admin dashboard" />
<c:set var="hideFooter" value="true" />
<%@ include file="../common/header.jspf" %>
<%@ include file="sidebar.jspf" %>

<div class="d-flex justify-content-between align-items-center mb-4">
  <div><h1 class="h3 mb-0">Dashboard</h1><small class="text-muted-sw">Store overview, computed by PL/SQL procedure <code>sp_get_dashboard_stats</code></small></div>
  <a href="${ctx}/admin/books/edit" class="btn btn-accent"><i class="bi bi-plus-lg me-1"></i>Add book</a>
</div>

<div class="row g-3 mb-4">
  <div class="col-sm-6 col-xl-3"><div class="stat-card d-flex gap-3 align-items-center">
    <span class="icon" style="background:#e8f5ec;color:#1e8e3e"><i class="bi bi-currency-rupee"></i></span>
    <div><div class="value">&#8377;<fmt:formatNumber value="${stats.revenue}" maxFractionDigits="0" /></div><div class="label">Total revenue</div></div></div></div>
  <div class="col-sm-6 col-xl-3"><div class="stat-card d-flex gap-3 align-items-center">
    <span class="icon" style="background:#fdf0e8;color:#b8532c"><i class="bi bi-receipt"></i></span>
    <div><div class="value">${stats.orders}</div><div class="label">Orders &middot; ${stats.pending} awaiting shipment</div></div></div></div>
  <div class="col-sm-6 col-xl-3"><div class="stat-card d-flex gap-3 align-items-center">
    <span class="icon" style="background:#eceafd;color:#4b3fc9"><i class="bi bi-book"></i></span>
    <div><div class="value">${stats.books}</div><div class="label">Active books</div></div></div></div>
  <div class="col-sm-6 col-xl-3"><div class="stat-card d-flex gap-3 align-items-center">
    <span class="icon" style="background:#fdeaea;color:#c62828"><i class="bi bi-exclamation-triangle"></i></span>
    <div><div class="value">${stats.lowStock}</div><div class="label">Low-stock books &middot; ${stats.customers} customers</div></div></div></div>
</div>

<div class="row g-4">
  <div class="col-xl-7">
    <div class="panel h-100">
      <h5 class="mb-3">Revenue by category</h5>
      <canvas id="salesChart" height="150"></canvas>
    </div>
  </div>
  <div class="col-xl-5">
    <div class="panel h-100">
      <div class="d-flex justify-content-between mb-3"><h5 class="mb-0">Low stock</h5><a href="${ctx}/admin/inventory" class="small">Manage</a></div>
      <c:if test="${empty lowStock}"><p class="text-muted-sw">All books are well stocked.</p></c:if>
      <c:forEach items="${lowStock}" var="b">
        <div class="d-flex align-items-center gap-2 mb-2">
          <img src="${ctx}/assets/covers/${b.coverImage}" class="admin-thumb" alt="">
          <div class="flex-grow-1 small"><div class="fw-semibold">${fn:escapeXml(b.title)}</div><div class="text-muted-sw">${fn:escapeXml(b.author)}</div></div>
          <span class="badge ${b.stock == 0 ? 'bg-secondary' : 'bg-danger'}">${b.stock} left</span>
        </div>
      </c:forEach>
    </div>
  </div>
  <div class="col-12">
    <div class="d-flex justify-content-between mb-2"><h5 class="mb-0">Recent orders</h5><a href="${ctx}/admin/orders" class="small">All orders</a></div>
    <div class="table-sw">
      <table class="table table-hover">
        <thead><tr><th>Order</th><th>Customer</th><th>Date</th><th>Items</th><th>Payment</th><th>Total</th><th>Status</th></tr></thead>
        <tbody>
          <c:forEach items="${recent}" var="o">
            <tr>
              <td><a href="${ctx}/order?id=${o.id}" class="fw-semibold text-decoration-none">#${o.id}</a></td>
              <td>${fn:escapeXml(o.customerName)}<div class="small text-muted-sw">${o.customerEmail}</div></td>
              <td><fmt:formatDate value="${o.orderDate}" pattern="dd MMM yyyy" /></td>
              <td>${o.itemCount}</td>
              <td>${o.paymentMethod}</td>
              <td class="fw-semibold">&#8377;<fmt:formatNumber value="${o.total}" maxFractionDigits="0" /></td>
              <td><span class="badge text-bg-${o.statusColor}">${o.status}</span></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>

  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
  new Chart(document.getElementById("salesChart"), {
    type: "bar",
    data: {
      labels: [<c:forEach items="${sales}" var="s" varStatus="i">"${s[0]}"${i.last ? '' : ','}</c:forEach>],
      datasets: [{ label: "Revenue (Rs.)", borderRadius: 8, backgroundColor: "#b8532c",
        data: [<c:forEach items="${sales}" var="s" varStatus="i">${s[2]}${i.last ? '' : ','}</c:forEach>] }]
    },
    options: { animation: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, grid: { color: "#f0ebe2" } }, x: { grid: { display: false } } } }
  });
</script>
<%@ include file="../common/footer.jspf" %>
