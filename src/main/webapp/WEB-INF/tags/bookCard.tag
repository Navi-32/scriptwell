<%@ tag body-content="empty" pageEncoding="UTF-8" %>
<%@ attribute name="book" required="true" type="com.scriptwell.model.Book" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<div class="book-card">
  <a href="${ctx}/book?id=${book.id}" class="book-cover-wrap d-block">
    <c:choose>
      <c:when test="${!book.inStock}"><span class="badge bg-secondary badge-stock">Out of stock</span></c:when>
      <c:when test="${book.lowStock}"><span class="badge bg-danger badge-stock">Only ${book.stock} left</span></c:when>
    </c:choose>
    <img class="book-cover" src="${ctx}/assets/covers/${book.coverImage}" alt="${fn:escapeXml(book.title)}" loading="lazy">
  </a>
  <div class="card-body">
    <small class="text-accent fw-semibold" style="font-size:.72rem">${fn:escapeXml(book.categoryName)}</small>
    <a class="title mt-1" href="${ctx}/book?id=${book.id}">${fn:escapeXml(book.title)}</a>
    <div class="author mb-2">${fn:escapeXml(book.author)}</div>
    <div class="stars mb-2"><c:forEach begin="1" end="5" var="s"><i class="bi ${s <= book.rating + 0.25 ? 'bi-star-fill' : (s - 0.5 <= book.rating ? 'bi-star-half' : 'bi-star')}"></i></c:forEach>
      <span class="text-muted-sw ms-1"><fmt:formatNumber value="${book.rating}" minFractionDigits="1" /></span></div>
    <div class="d-flex align-items-center justify-content-between mt-auto">
      <span class="price">&#8377;<fmt:formatNumber value="${book.price}" maxFractionDigits="0" /></span>
      <form class="js-add-cart" action="${ctx}/cart" method="post">
        <input type="hidden" name="action" value="add"><input type="hidden" name="bookId" value="${book.id}"><input type="hidden" name="qty" value="1">
        <button class="btn btn-accent btn-cart-sm" title="Add to cart" ${book.inStock ? '' : 'disabled'}><i class="bi bi-bag-plus"></i></button>
      </form>
    </div>
  </div>
</div>
