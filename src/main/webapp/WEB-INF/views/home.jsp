<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Online Book Store" />
<%@ include file="common/header.jspf" %>

<section class="hero pt-5 pb-5 mb-5">
  <div class="container py-lg-4">
    <div class="row align-items-center g-5">
      <div class="col-lg-6">
        <span class="hero-badge mb-3"><i class="bi bi-stars me-1"></i>Free delivery on orders above &#8377;499</span>
        <h1 class="mb-3">Find the book that <em class="text-warning">writes</em> your next chapter.</h1>
        <p class="lead mb-4">Classics, bestsellers and programming essentials &mdash; curated, beautifully presented and delivered fast.</p>
        <form class="d-flex gap-2 mb-4" action="${ctx}/books">
          <input class="form-control form-control-lg" name="q" placeholder="Try &ldquo;Orwell&rdquo;, &ldquo;Java&rdquo; or &ldquo;habits&rdquo;">
          <button class="btn btn-accent btn-lg px-4">Search</button>
        </form>
        <div class="d-flex gap-5">
          <div class="hero-stat"><strong>30+</strong><span>Curated titles</span></div>
          <div class="hero-stat"><strong>${fn:length(categories)}</strong><span>Categories</span></div>
          <div class="hero-stat"><strong>4.6&#9733;</strong><span>Average rating</span></div>
        </div>
      </div>
      <div class="col-lg-6 d-none d-lg-block">
        <div class="hero-stack">
          <c:forEach items="${featured}" var="b" end="2">
            <img src="${ctx}/assets/covers/${b.coverImage}" alt="${fn:escapeXml(b.title)}">
          </c:forEach>
        </div>
      </div>
    </div>
  </div>
</section>

<div class="container">
  <c:if test="${not empty error}"><div class="alert alert-danger">${error}</div></c:if>

  <section class="mb-5">
    <div class="section-title">
      <div><div class="eyebrow">Explore</div><h2>Shop by category</h2></div>
      <a href="${ctx}/books" class="fw-semibold text-decoration-none">View all <i class="bi bi-arrow-right"></i></a>
    </div>
    <div class="row g-3">
      <c:forEach items="${categories}" var="cat">
        <div class="col-6 col-md-4 col-xl-3">
          <a class="cat-tile" href="${ctx}/books?category=${cat.id}">
            <span class="cat-icon"><i class="bi ${cat.icon}"></i></span>
            <span><span class="fw-semibold d-block">${fn:escapeXml(cat.name)}</span><small>${cat.bookCount} books</small></span>
          </a>
        </div>
      </c:forEach>
      <div class="col-6 col-md-4 col-xl-3">
        <a class="cat-tile" href="${ctx}/books" style="background:#1c1a2e;color:#fff">
          <span class="cat-icon" style="background:#b8532c;color:#fff"><i class="bi bi-grid"></i></span>
          <span><span class="fw-semibold d-block">All books</span><small style="color:#bbb">Browse everything</small></span>
        </a>
      </div>
    </div>
  </section>

  <section class="mb-5">
    <div class="section-title">
      <div><div class="eyebrow">Readers love these</div><h2>Top rated</h2></div>
      <a href="${ctx}/books?sort=rating" class="fw-semibold text-decoration-none">See more <i class="bi bi-arrow-right"></i></a>
    </div>
    <div class="row g-4">
      <c:forEach items="${featured}" var="b">
        <div class="col-6 col-md-4 col-lg-3"><sw:bookCard book="${b}" /></div>
      </c:forEach>
    </div>
  </section>

  <section class="mb-5">
    <div class="row g-4 align-items-stretch">
      <div class="col-lg-4">
        <div class="panel h-100 d-flex flex-column justify-content-center" style="background:linear-gradient(160deg,#fbeee4,#f6dccb);border:0">
          <div class="eyebrow">Fresh off the press</div>
          <h2 class="mb-3">New arrivals</h2>
          <p class="text-muted-sw">The most recent editions in our collection, from contemporary fiction to the latest programming guides.</p>
          <a href="${ctx}/books?sort=newest" class="btn btn-ink align-self-start">Shop new arrivals</a>
        </div>
      </div>
      <div class="col-lg-8">
        <div class="row g-3">
          <c:forEach items="${arrivals}" var="b">
            <div class="col-6 col-md-4">
              <a href="${ctx}/book?id=${b.id}" class="d-flex gap-3 align-items-center panel p-3 text-decoration-none text-reset h-100">
                <img src="${ctx}/assets/covers/${b.coverImage}" class="cart-thumb" alt="">
                <span><span class="fw-semibold d-block small">${fn:escapeXml(b.title)}</span>
                  <small class="text-muted-sw d-block">${fn:escapeXml(b.author)}</small>
                  <span class="price small">&#8377;<fmt:formatNumber value="${b.price}" maxFractionDigits="0" /></span></span>
              </a>
            </div>
          </c:forEach>
        </div>
      </div>
    </div>
  </section>

  <section class="row g-3 text-center">
    <div class="col-md-4"><div class="panel"><i class="bi bi-truck fs-2 text-accent"></i><h6 class="mt-2 mb-1">Fast, free delivery</h6><small class="text-muted-sw">On every order above &#8377;499</small></div></div>
    <div class="col-md-4"><div class="panel"><i class="bi bi-credit-card fs-2 text-accent"></i><h6 class="mt-2 mb-1">Card, UPI or Cash</h6><small class="text-muted-sw">Pay the way you like</small></div></div>
    <div class="col-md-4"><div class="panel"><i class="bi bi-arrow-counterclockwise fs-2 text-accent"></i><h6 class="mt-2 mb-1">Easy cancellation</h6><small class="text-muted-sw">Cancel anytime before shipping</small></div></div>
  </section>
</div>

<%@ include file="common/footer.jspf" %>
