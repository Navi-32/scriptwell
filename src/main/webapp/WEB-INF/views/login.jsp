<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Sign in" />
<%@ include file="common/header.jspf" %>

<div class="container auth-wrap py-5">
  <div class="row g-0 shadow-sm" style="border-radius:14px;overflow:hidden">
    <div class="col-md-5 auth-side p-5 d-flex flex-column justify-content-between">
      <div>
        <div class="eyebrow" style="color:#e5b04a">Welcome back</div>
        <p class="quote mt-3">&ldquo;A reader lives a thousand lives before he dies.&rdquo;</p>
        <small style="color:#bbb">&mdash; George R.R. Martin</small>
      </div>
      <div class="small mt-5" style="color:#ccc">
        <div class="mb-1"><i class="bi bi-info-circle me-1"></i>Demo accounts</div>
        <div>Customer: <code class="text-warning">demo@scriptwell.com</code> / <code class="text-warning">demo123</code></div>
        <div>Admin: <code class="text-warning">admin@scriptwell.com</code> / <code class="text-warning">admin123</code></div>
      </div>
    </div>
    <div class="col-md-7 bg-white p-5">
      <h2 class="mb-1">Sign in</h2>
      <p class="text-muted-sw mb-4">New to ScriptWell? <a href="${ctx}/register${empty param.next ? '' : '?next='.concat(fn:escapeXml(param.next))}">Create an account</a></p>
      <c:if test="${not empty error}"><div class="alert alert-danger"><i class="bi bi-exclamation-circle me-2"></i>${fn:escapeXml(error)}</div></c:if>
      <form method="post" action="${ctx}/login" novalidate class="needs-validation">
        <input type="hidden" name="next" value="${fn:escapeXml(param.next)}">
        <div class="mb-3">
          <label class="form-label">Email address</label>
          <input type="email" name="email" class="form-control form-control-lg" required value="${fn:escapeXml(email)}" placeholder="you@example.com" autofocus>
        </div>
        <div class="mb-4">
          <label class="form-label">Password</label>
          <input type="password" name="password" class="form-control form-control-lg" required placeholder="Your password">
        </div>
        <button class="btn btn-accent btn-lg w-100">Sign in</button>
      </form>
    </div>
  </div>
</div>

<%@ include file="common/footer.jspf" %>
