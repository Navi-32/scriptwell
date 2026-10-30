<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Create account" />
<%@ include file="common/header.jspf" %>

<div class="container auth-wrap py-5">
  <div class="row g-0 shadow-sm" style="border-radius:14px;overflow:hidden">
    <div class="col-md-5 auth-side p-5">
      <div class="eyebrow" style="color:#e5b04a">Join ScriptWell</div>
      <h2 class="mt-3 mb-4 text-white">Your next favourite book is waiting.</h2>
      <ul class="list-unstyled" style="color:#ddd">
        <li class="mb-3"><i class="bi bi-check2-circle text-warning me-2"></i>Save books in your cart</li>
        <li class="mb-3"><i class="bi bi-check2-circle text-warning me-2"></i>One-click Buy Now checkout</li>
        <li class="mb-3"><i class="bi bi-check2-circle text-warning me-2"></i>Track and cancel your orders</li>
      </ul>
    </div>
    <div class="col-md-7 bg-white p-5">
      <h2 class="mb-1">Create your account</h2>
      <p class="text-muted-sw mb-4">Already a member? <a href="${ctx}/login">Sign in</a></p>
      <c:if test="${not empty error}"><div class="alert alert-danger"><i class="bi bi-exclamation-circle me-2"></i>${fn:escapeXml(error)}</div></c:if>
      <form method="post" action="${ctx}/register">
        <input type="hidden" name="next" value="${fn:escapeXml(param.next)}">
        <div class="row g-3">
          <div class="col-12">
            <label class="form-label">Full name</label>
            <input name="fullName" class="form-control" required maxlength="100" value="${fn:escapeXml(param.fullName)}">
          </div>
          <div class="col-md-6">
            <label class="form-label">Email</label>
            <input type="email" name="email" class="form-control" required maxlength="120" value="${fn:escapeXml(param.email)}">
          </div>
          <div class="col-md-6">
            <label class="form-label">Phone</label>
            <input name="phone" class="form-control" pattern="[0-9+ ]{10,15}" maxlength="15" value="${fn:escapeXml(param.phone)}" placeholder="10-digit mobile">
          </div>
          <div class="col-12">
            <label class="form-label">Address <span class="text-muted-sw small">(optional, used at checkout)</span></label>
            <input name="address" class="form-control" maxlength="300" value="${fn:escapeXml(param.address)}">
          </div>
          <div class="col-md-6">
            <label class="form-label">Password</label>
            <input type="password" id="password" name="password" class="form-control" required minlength="6">
          </div>
          <div class="col-md-6">
            <label class="form-label">Confirm password</label>
            <input type="password" id="confirm" name="confirm" class="form-control" required minlength="6">
          </div>
        </div>
        <button class="btn btn-accent btn-lg w-100 mt-4">Create account</button>
      </form>
    </div>
  </div>
</div>

<%@ include file="common/footer.jspf" %>
