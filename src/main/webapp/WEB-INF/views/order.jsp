<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Order #${order.id}" />
<%@ include file="common/header.jspf" %>
<c:set var="st" value="${order.status}" />

<div class="container py-4" style="max-width:960px">
  <c:if test="${placed}">
    <div class="panel text-center py-5 mb-4">
      <div class="success-icon mb-3"><i class="bi bi-check-lg"></i></div>
      <h1 class="h2">Thank you, your order is confirmed!</h1>
      <p class="text-muted-sw mb-1">Order <strong>#${order.id}</strong> has been placed successfully.</p>
      <p class="text-muted-sw">Payment reference <code>${order.paymentRef}</code></p>
      <div class="d-flex gap-2 justify-content-center mt-3">
        <a href="${ctx}/books" class="btn btn-accent">Continue shopping</a>
        <a href="${ctx}/orders" class="btn btn-outline-ink">View all orders</a>
      </div>
    </div>
  </c:if>

  <div class="panel mb-4">
    <div class="d-flex flex-wrap justify-content-between align-items-start gap-2 mb-4">
      <div>
        <h2 class="h4 mb-1">Order #${order.id}</h2>
        <div class="text-muted-sw small">Placed on <fmt:formatDate value="${order.orderDate}" pattern="dd MMM yyyy, hh:mm a" /></div>
      </div>
      <span class="badge fs-6 text-bg-${order.statusColor}">${st}</span>
    </div>

    <c:choose>
      <c:when test="${st == 'CANCELLED'}">
        <div class="alert alert-danger mb-0"><i class="bi bi-x-octagon me-2"></i>This order was cancelled. The books have been returned to stock.</div>
      </c:when>
      <c:otherwise>
        <div class="timeline">
          <div class="step done"><i class="bi bi-receipt"></i><div class="mt-1">Placed</div></div>
          <div class="step ${st == 'SHIPPED' or st == 'DELIVERED' ? 'done' : ''}"><i class="bi bi-truck"></i><div class="mt-1">Shipped</div></div>
          <div class="step ${st == 'DELIVERED' ? 'done' : ''}"><i class="bi bi-house-check"></i><div class="mt-1">Delivered</div></div>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <div class="row g-4">
    <div class="col-md-7">
      <div class="panel h-100">
        <h5 class="mb-3">Items</h5>
        <c:forEach items="${order.items}" var="it">
          <div class="d-flex gap-3 align-items-center mb-3">
            <img src="${ctx}/assets/covers/${it.coverImage}" class="cart-thumb" style="width:52px" alt="">
            <div class="flex-grow-1">
              <a class="fw-semibold text-decoration-none text-reset" href="${ctx}/book?id=${it.bookId}">${fn:escapeXml(it.title)}</a>
              <div class="small text-muted-sw">${fn:escapeXml(it.author)} &middot; Qty ${it.quantity} &times; &#8377;<fmt:formatNumber value="${it.price}" maxFractionDigits="0" /></div>
            </div>
            <div class="fw-semibold">&#8377;<fmt:formatNumber value="${it.lineTotal}" maxFractionDigits="0" /></div>
          </div>
        </c:forEach>
      </div>
    </div>
    <div class="col-md-5">
      <div class="panel mb-4">
        <h5 class="mb-3">Payment</h5>
        <div class="summary-row"><span>Subtotal</span><span>&#8377;<fmt:formatNumber value="${order.subtotal}" maxFractionDigits="0" /></span></div>
        <div class="summary-row"><span>Delivery</span><span>${order.shippingCharge == 0 ? 'FREE' : ''}<c:if test="${order.shippingCharge > 0}">&#8377;<fmt:formatNumber value="${order.shippingCharge}" maxFractionDigits="0" /></c:if></span></div>
        <div class="summary-row summary-total"><span>Total</span><span>&#8377;<fmt:formatNumber value="${order.total}" maxFractionDigits="0" /></span></div>
        <div class="small text-muted-sw mt-2">Paid via <strong>${order.paymentMethod == 'COD' ? 'Cash on delivery' : order.paymentMethod}</strong> &middot; ${order.paymentRef}</div>
      </div>
      <div class="panel">
        <h5 class="mb-2">Deliver to</h5>
        <div class="fw-semibold">${fn:escapeXml(order.customerName)}</div>
        <div class="small text-muted-sw">${fn:escapeXml(order.shippingAddress)}</div>
        <div class="small text-muted-sw">${fn:escapeXml(order.customerPhone)}</div>
        <c:if test="${order.cancellable and not sessionScope.user.admin}">
          <form method="post" action="${ctx}/orders" class="mt-3" data-confirm="Cancel order #${order.id}?">
            <input type="hidden" name="orderId" value="${order.id}">
            <button class="btn btn-outline-danger btn-sm w-100"><i class="bi bi-x-circle me-1"></i>Cancel order</button>
          </form>
        </c:if>
      </div>
    </div>
  </div>
  <div class="mt-4">
    <a href="${sessionScope.user.admin ? ctx.concat('/admin/orders') : ctx.concat('/orders')}" class="text-decoration-none"><i class="bi bi-arrow-left me-1"></i>Back to orders</a>
  </div>
</div>

<%@ include file="common/footer.jspf" %>
