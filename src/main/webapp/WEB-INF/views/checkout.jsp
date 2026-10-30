<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Checkout" />
<%@ include file="common/header.jspf" %>
<c:set var="u" value="${sessionScope.user}" />

<div class="container py-4">
  <div class="d-flex align-items-center gap-3 mb-4">
    <h1 class="h2 mb-0">Checkout</h1>
    <c:if test="${not empty buyNow}"><span class="badge text-bg-warning"><i class="bi bi-lightning-charge"></i> Buy Now</span></c:if>
  </div>
  <c:if test="${not empty error}"><div class="alert alert-danger"><i class="bi bi-exclamation-triangle me-2"></i>${fn:escapeXml(error)}</div></c:if>

  <form id="checkoutForm" method="post" action="${ctx}/checkout" novalidate>
    <c:if test="${not empty buyNow}">
      <input type="hidden" name="bookId" value="${buyNow.bookId}">
      <input type="hidden" name="qty" value="${buyNow.quantity}">
    </c:if>
    <div class="row g-4">
      <div class="col-lg-7">
        <div class="panel mb-4">
          <h5 class="mb-3"><span class="badge bg-ink me-2">1</span>Shipping address</h5>
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label">Full name</label>
              <input class="form-control" value="${fn:escapeXml(u.fullName)}" readonly>
            </div>
            <div class="col-md-6">
              <label class="form-label">Phone</label>
              <input class="form-control" value="${fn:escapeXml(u.phone)}" readonly>
            </div>
            <div class="col-12">
              <label class="form-label">Street address</label>
              <input name="address" class="form-control" required minlength="5" maxlength="180" value="${fn:escapeXml(not empty param.address ? param.address : u.address)}" placeholder="House no., street, area">
              <div class="invalid-feedback">Please enter your street address.</div>
            </div>
            <div class="col-md-5">
              <label class="form-label">City</label>
              <input name="city" class="form-control" required maxlength="40" value="${fn:escapeXml(param.city)}">
            </div>
            <div class="col-md-4">
              <label class="form-label">State</label>
              <input name="state" class="form-control" required maxlength="40" value="${fn:escapeXml(param.state)}">
            </div>
            <div class="col-md-3">
              <label class="form-label">PIN code</label>
              <input name="pincode" class="form-control" required pattern="[0-9]{6}" maxlength="6" value="${fn:escapeXml(param.pincode)}">
              <div class="invalid-feedback">6 digits</div>
            </div>
          </div>
        </div>

        <div class="panel">
          <h5 class="mb-3"><span class="badge bg-ink me-2">2</span>Payment <small class="text-muted-sw fw-normal fs-6">(simulated &mdash; no real money is charged)</small></h5>
          <div class="row g-2 mb-3">
            <div class="col-md-4"><label class="pay-option d-flex gap-2 w-100"><input class="form-check-input" type="radio" name="payment" value="CARD" ${empty param.payment or param.payment == 'CARD' ? 'checked' : ''}><span><i class="bi bi-credit-card me-1"></i>Card</span></label></div>
            <div class="col-md-4"><label class="pay-option d-flex gap-2 w-100"><input class="form-check-input" type="radio" name="payment" value="UPI" ${param.payment == 'UPI' ? 'checked' : ''}><span><i class="bi bi-phone me-1"></i>UPI</span></label></div>
            <div class="col-md-4"><label class="pay-option d-flex gap-2 w-100"><input class="form-check-input" type="radio" name="payment" value="COD" ${param.payment == 'COD' ? 'checked' : ''}><span><i class="bi bi-cash-coin me-1"></i>Cash on delivery</span></label></div>
          </div>

          <div data-pay="CARD" class="row g-3">
            <div class="col-12">
              <label class="form-label">Card number</label>
              <input id="cardNumber" name="cardNumber" class="form-control" inputmode="numeric" placeholder="4111 1111 1111 1111" pattern="[0-9 ]{19}" autocomplete="off">
              <div class="form-text">Use test card 4111 1111 1111 1111 with any future expiry and CVV.</div>
            </div>
            <div class="col-md-6"><label class="form-label">Name on card</label><input name="cardName" class="form-control" value="${fn:escapeXml(u.fullName)}"></div>
            <div class="col-md-3"><label class="form-label">Expiry</label><input id="expiry" name="expiry" class="form-control" placeholder="MM/YY" pattern="(0[1-9]|1[0-2])/[0-9]{2}" autocomplete="off"></div>
            <div class="col-md-3"><label class="form-label">CVV</label><input name="cvv" type="password" class="form-control" placeholder="123" pattern="[0-9]{3}" maxlength="3" autocomplete="off"></div>
          </div>
          <div data-pay="UPI" class="d-none">
            <label class="form-label">UPI ID</label>
            <input name="upiId" class="form-control" placeholder="yourname@okbank" pattern="[A-Za-z0-9.\-_]{2,}@[A-Za-z]{2,}">
          </div>
          <div data-pay="COD" class="d-none">
            <div class="alert alert-light border mb-0"><i class="bi bi-info-circle me-2"></i>Pay in cash when your books are delivered.</div>
          </div>
        </div>
      </div>

      <div class="col-lg-5">
        <div class="panel" style="position:sticky;top:90px">
          <h5 class="mb-3">Order summary</h5>
          <c:forEach items="${items}" var="it">
            <div class="d-flex gap-3 align-items-center mb-3">
              <img src="${ctx}/assets/covers/${it.coverImage}" class="cart-thumb" style="width:48px" alt="">
              <div class="flex-grow-1 small">
                <div class="fw-semibold">${fn:escapeXml(it.title)}</div>
                <div class="text-muted-sw">Qty ${it.quantity} &times; &#8377;<fmt:formatNumber value="${it.price}" maxFractionDigits="0" /></div>
              </div>
              <div class="fw-semibold">&#8377;<fmt:formatNumber value="${it.lineTotal}" maxFractionDigits="0" /></div>
            </div>
          </c:forEach>
          <hr>
          <div class="summary-row"><span>Subtotal</span><span>&#8377;<fmt:formatNumber value="${subtotal}" maxFractionDigits="0" /></span></div>
          <div class="summary-row"><span>Delivery</span><span><c:choose><c:when test="${shipping == 0}"><span class="text-success">FREE</span></c:when><c:otherwise>&#8377;<fmt:formatNumber value="${shipping}" maxFractionDigits="0" /></c:otherwise></c:choose></span></div>
          <div class="summary-row summary-total"><span>Total</span><span>&#8377;<fmt:formatNumber value="${total}" maxFractionDigits="0" /></span></div>
          <button id="payBtn" class="btn btn-accent btn-lg w-100 mt-3"><i class="bi bi-lock me-2"></i>Pay &#8377;<fmt:formatNumber value="${total}" maxFractionDigits="0" /> &amp; place order</button>
          <div class="text-center small text-muted-sw mt-3">Stock is reserved and verified by the database when you pay.</div>
        </div>
      </div>
    </div>
  </form>
</div>

<%@ include file="common/footer.jspf" %>
