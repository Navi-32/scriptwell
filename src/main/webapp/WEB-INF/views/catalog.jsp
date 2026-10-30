<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Browse books" />
<%@ include file="common/header.jspf" %>

<section class="page-banner py-4 mb-4">
  <div class="container">
    <div class="eyebrow" style="color:#e5b04a">Catalogue</div>
    <h1 class="h2 mb-1">
      <c:choose>
        <c:when test="${not empty q}">Results for &ldquo;${fn:escapeXml(q)}&rdquo;</c:when>
        <c:otherwise>Browse all books</c:otherwise>
      </c:choose>
    </h1>
    <p class="mb-0" style="color:#cfcbe0">${fn:length(books)} book${fn:length(books) == 1 ? '' : 's'} found</p>
  </div>
</section>

<div class="container">
  <c:if test="${not empty error}"><div class="alert alert-danger">${error}</div></c:if>
  <div class="row g-4">
    <aside class="col-lg-3">
      <form class="filter-card" action="${ctx}/books" method="get">
        <h6 class="mb-2">Search</h6>
        <input class="form-control mb-4" name="q" value="${fn:escapeXml(q)}" placeholder="Title, author, ISBN">

        <h6 class="mb-2">Category</h6>
        <div class="form-check">
          <input class="form-check-input" type="radio" name="category" id="cat0" value="" ${empty selCategory ? 'checked' : ''}>
          <label class="form-check-label" for="cat0">All categories</label>
        </div>
        <c:forEach items="${categories}" var="cat">
          <div class="form-check">
            <input class="form-check-input" type="radio" name="category" id="cat${cat.id}" value="${cat.id}" ${selCategory == cat.id ? 'checked' : ''}>
            <label class="form-check-label d-flex justify-content-between" for="cat${cat.id}">${fn:escapeXml(cat.name)} <span class="text-muted-sw small">${cat.bookCount}</span></label>
          </div>
        </c:forEach>

        <h6 class="mt-4 mb-2">Price (&#8377;)</h6>
        <div class="d-flex gap-2 mb-2">
          <input class="form-control" type="number" min="0" name="min" placeholder="Min" value="<fmt:formatNumber value='${min}' groupingUsed='false' maxFractionDigits='0'/>">
          <input class="form-control" type="number" min="0" name="max" placeholder="Max" value="<fmt:formatNumber value='${max}' groupingUsed='false' maxFractionDigits='0'/>">
        </div>
        <div class="d-flex flex-wrap gap-1 mb-4">
          <a class="badge text-bg-light border text-decoration-none" href="${ctx}/books?max=399">Under &#8377;400</a>
          <a class="badge text-bg-light border text-decoration-none" href="${ctx}/books?min=400&max=699">&#8377;400&ndash;699</a>
          <a class="badge text-bg-light border text-decoration-none" href="${ctx}/books?min=700">&#8377;700+</a>
        </div>

        <h6 class="mb-2">Sort by</h6>
        <select class="form-select mb-4" name="sort">
          <option value="">Title (A&ndash;Z)</option>
          <option value="price_asc" ${sort == 'price_asc' ? 'selected' : ''}>Price: low to high</option>
          <option value="price_desc" ${sort == 'price_desc' ? 'selected' : ''}>Price: high to low</option>
          <option value="rating" ${sort == 'rating' ? 'selected' : ''}>Customer rating</option>
          <option value="newest" ${sort == 'newest' ? 'selected' : ''}>Newest first</option>
        </select>
        <button class="btn btn-accent w-100 mb-2"><i class="bi bi-funnel me-1"></i>Apply filters</button>
        <a href="${ctx}/books" class="btn btn-link w-100 text-muted-sw">Reset</a>
      </form>
    </aside>

    <div class="col-lg-9">
      <c:choose>
        <c:when test="${empty books}">
          <div class="panel text-center py-5">
            <i class="bi bi-search fs-1 text-muted-sw"></i>
            <h4 class="mt-3">No books match your search</h4>
            <p class="text-muted-sw">Try a different keyword or clear the filters.</p>
            <a href="${ctx}/books" class="btn btn-ink">Show all books</a>
          </div>
        </c:when>
        <c:otherwise>
          <div class="row g-4">
            <c:forEach items="${books}" var="b">
              <div class="col-6 col-md-4"><sw:bookCard book="${b}" /></div>
            </c:forEach>
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</div>

<%@ include file="common/footer.jspf" %>
