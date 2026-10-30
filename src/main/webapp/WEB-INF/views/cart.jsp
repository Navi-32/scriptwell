<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Your cart" />
<%@ include file="common/header.jspf" %>

<div class="container py-4">
  <h1 class="h2 mb-4">Shopping cart</h1>
  <c:if test="${not empty error}"><div class="alert alert-danger">${error}</div></c:if>

  <c:choose>
    <c:when test="${empty items}">
      <div class="panel text-center py-5">
        <i class="bi bi-bag fs-1 text-muted-sw"></i>
        <h4 class="mt-3">Your cart is empty</h4>
        <p class="text-muted-sw">Looks like you haven't added any books yet.</p>
        <a href="${ctx}/books" class="btn btn-accent">Start shopping</a>
      </div>
    </c:when>
    <c:otherwise>
      <div class="row g-4">
        <div class="col-lg-8">
          <div class="panel p-0">
            <c:forEach items="${items}" var="it" varStatus="st">
              <div class="d-flex gap-3 align-items-center p-3 ${st.last ? '' : 'border-bottom'}">
                <a href="${ctx}/book?id=${it.bookId}"><img src="${ctx}/assets/covers/${it.coverImage}" class="cart-thumb" alt=""></a>
                <div class="flex-grow-1">
                  <a href="${ctx}/book?id=${it.bookId}" class="fw-semibold text-decoration-none text-reset">${fn:escapeXml(it.title)}</a>
                  <div class="small text-muted-sw">${fn:escapeXml(it.author)}</div>
                  <div class="small mt-1">&#8377;<fmt:formatNumber value="${it.price}" maxFractionDigits="0" /> each
                    <c:if test="${it.stock <= 5}"><span class="text-danger ms-2">Only ${it.stock} in stock</span></c:if></div>
                </div>
                <form method="post" action="${ctx}/cart" class="js-auto-submit">
                  <input type="hidden" name="action" value="update"><input type="hidden" name="bookId" value="${it.bookId}">
                  <div class="input-group input-group-sm qty-group" style="width:120px">
                    <button class="btn btn-outline-secondary" type="button" data-qty-step="-1"><i class="bi bi-dash"></i></button>
                    <input type="number" name="qty" class="form-control" value="${it.quantity}" min="1" max="${it.stock}">
                    <button class="btn btn-outline-secondary" type="button" data-qty-step="1"><i class="bi bi-plus"></i></button>
                  </div>
                </form>
                <div class="fw-bold text-end" style="width:90px">&#8377;<fmt:formatNumber value="${it.lineTotal}" maxFractionDigits="0" /></div>
                <form method="post" action="${ctx}/cart">
                  <input type="hidden" name="action" value="remove"><input type="hidden" name="bookId" value="${it.bookId}">
                  <button class="btn btn-sm btn-link text-danger" title="Remove"><i class="bi bi-trash3"></i></button>
                </form>
              </div>
            </c:forEach>
          </div>
          <div class="d-flex justify-content-between mt-3">
            <a href="${ctx}/books" class="btn btn-link text-decoration-none"><i class="bi bi-arrow-left me-1"></i>Continue shopping</a>
            <form method="post" action="${ctx}/cart" data-confirm="Remove all items from your cart?">
              <input type="hidden" name="action" value="clear">
              <button class="btn btn-outline-danger btn-sm"><i class="bi bi-x-circle me-1"></i>Clear cart</button>
            </form>
          </div>
        </div>
        <div class="col-lg-4">
          <div class="panel">
            <h5 class="mb-3">Order summary</h5>
            <div class="summary-row"><span>Subtotal (${sessionScope.cartCount} items)</span><span>&#8377;<fmt:formatNumber value="${subtotal}" maxFractionDigits="0" /></span></div>
            <div class="summary-row"><span>Delivery</span><span>${shipping == 0 ? '<span class="text-success">FREE</span>' : ''}<c:if test="${shipping > 0}">&#8377;<fmt:formatNumber value="${shipping}" maxFractionDigits="0" /></c:if></span></div>
            <c:if test="${shipping > 0}"><div class="small text-muted-sw">Add &#8377;<fmt:formatNumber value="${499 - subtotal}" maxFractionDigits="0" /> more for free delivery.</div></c:if>
            <div class="summary-row summary-total"><span>Total</span><span>&#8377;<fmt:formatNumber value="${total}" maxFractionDigits="0" /></span></div>
            <a href="${ctx}/checkout" class="btn btn-accent btn-lg w-100 mt-3">Proceed to checkout <i class="bi bi-arrow-right ms-1"></i></a>
            <div class="text-center small text-muted-sw mt-3"><i class="bi bi-shield-lock me-1"></i>Secure simulated payment</div>
          </div>
        </div>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<%@ include file="common/footer.jspf" %>
