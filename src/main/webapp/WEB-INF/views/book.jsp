<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="${book.title}" />
<%@ include file="common/header.jspf" %>

<div class="container py-4">
  <nav class="small mb-4">
    <a href="${ctx}/home" class="text-decoration-none text-muted-sw">Home</a> <i class="bi bi-chevron-right small text-muted-sw"></i>
    <a href="${ctx}/books?category=${book.categoryId}" class="text-decoration-none text-muted-sw">${fn:escapeXml(book.categoryName)}</a> <i class="bi bi-chevron-right small text-muted-sw"></i>
    <span>${fn:escapeXml(book.title)}</span>
  </nav>

  <div class="row g-5">
    <div class="col-lg-5">
      <div class="detail-cover"><img src="${ctx}/assets/covers/${book.coverImage}" alt="${fn:escapeXml(book.title)}"></div>
    </div>
    <div class="col-lg-7">
      <span class="badge rounded-pill text-bg-light border mb-2">${fn:escapeXml(book.categoryName)}</span>
      <h1 class="display-6 fw-bold mb-1">${fn:escapeXml(book.title)}</h1>
      <p class="fs-5 text-muted-sw mb-2">by <span class="text-dark">${fn:escapeXml(book.author)}</span></p>
      <div class="stars fs-6 mb-3">
        <c:forEach begin="1" end="5" var="s"><i class="bi ${s <= book.rating + 0.25 ? 'bi-star-fill' : (s - 0.5 <= book.rating ? 'bi-star-half' : 'bi-star')}"></i></c:forEach>
        <span class="text-muted-sw ms-1">${book.rating} / 5</span>
      </div>

      <div class="d-flex align-items-end gap-3 mb-3">
        <span class="display-6 fw-bold">&#8377;<fmt:formatNumber value="${book.price}" maxFractionDigits="0" /></span>
        <c:choose>
          <c:when test="${!book.inStock}"><span class="badge bg-secondary mb-2">Out of stock</span></c:when>
          <c:when test="${book.lowStock}"><span class="badge bg-danger mb-2">Hurry, only ${book.stock} left</span></c:when>
          <c:otherwise><span class="badge bg-success-subtle text-success mb-2"><i class="bi bi-check-circle me-1"></i>In stock</span></c:otherwise>
        </c:choose>
      </div>
      <p class="lead fs-6 mb-4" style="line-height:1.75">${fn:escapeXml(book.description)}</p>

      <c:if test="${book.inStock}">
        <div class="panel mb-4">
          <div class="d-flex flex-wrap gap-3 align-items-center">
            <div class="input-group qty-group">
              <button class="btn btn-outline-secondary" type="button" data-qty-step="-1"><i class="bi bi-dash"></i></button>
              <input type="number" class="form-control" id="qtyInput" value="1" min="1" max="${book.stock < 10 ? book.stock : 10}">
              <button class="btn btn-outline-secondary" type="button" data-qty-step="1"><i class="bi bi-plus"></i></button>
            </div>
            <form class="js-add-cart" action="${ctx}/cart" method="post">
              <input type="hidden" name="action" value="add"><input type="hidden" name="bookId" value="${book.id}">
              <input type="hidden" name="qty" value="1" class="js-qty-mirror">
              <button class="btn btn-outline-ink btn-lg px-4"><i class="bi bi-bag-plus me-2"></i>Add to cart</button>
            </form>
            <form action="${ctx}/checkout" method="get">
              <input type="hidden" name="bookId" value="${book.id}">
              <input type="hidden" name="qty" value="1" class="js-qty-mirror">
              <button class="btn btn-accent btn-lg px-4"><i class="bi bi-lightning-charge me-2"></i>Buy now</button>
            </form>
          </div>
          <small class="text-muted-sw d-block mt-3"><i class="bi bi-truck me-1"></i>Free delivery on orders of &#8377;499 or more. Usually ships in 1&ndash;2 days.</small>
        </div>
      </c:if>

      <table class="meta-table w-100">
        <tr><td>Publisher</td><td>${fn:escapeXml(book.publisher)}</td></tr>
        <tr><td>Published</td><td>${book.pubYear}</td></tr>
        <tr><td>Pages</td><td>${book.pages}</td></tr>
        <tr><td>ISBN</td><td>${book.isbn}</td></tr>
        <tr><td>Category</td><td>${fn:escapeXml(book.categoryName)}</td></tr>
      </table>
    </div>
  </div>

  <c:if test="${not empty related}">
    <section class="mt-5">
      <div class="section-title"><div><div class="eyebrow">You may also like</div><h2>More in ${fn:escapeXml(book.categoryName)}</h2></div></div>
      <div class="row g-4">
        <c:forEach items="${related}" var="b">
          <div class="col-6 col-md-3"><sw:bookCard book="${b}" /></div>
        </c:forEach>
      </div>
    </section>
  </c:if>
</div>

<%@ include file="common/footer.jspf" %>
