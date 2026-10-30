<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isNew" value="${empty book or book.id == 0}" />
<c:set var="pageTitle" value="${isNew ? 'Add book' : 'Edit book'}" />
<c:set var="hideFooter" value="true" />
<%@ include file="../common/header.jspf" %>
<%@ include file="sidebar.jspf" %>

<div class="mb-4">
  <a href="${ctx}/admin/books" class="small text-decoration-none"><i class="bi bi-arrow-left"></i> All books</a>
  <h1 class="h3 mt-1">${isNew ? 'Add a new book' : 'Edit book #'}${isNew ? '' : book.id}</h1>
</div>

<form method="post" action="${ctx}/admin/books/save">
  <input type="hidden" name="id" value="${isNew ? 0 : book.id}">
  <div class="row g-4">
    <div class="col-xl-8">
      <div class="panel">
        <div class="row g-3">
          <div class="col-md-8"><label class="form-label">Title *</label><input name="title" class="form-control" required maxlength="200" value="${fn:escapeXml(book.title)}"></div>
          <div class="col-md-4"><label class="form-label">ISBN</label><input name="isbn" class="form-control" maxlength="20" value="${fn:escapeXml(book.isbn)}"></div>
          <div class="col-md-6"><label class="form-label">Author *</label><input name="author" class="form-control" required maxlength="120" value="${fn:escapeXml(book.author)}"></div>
          <div class="col-md-6"><label class="form-label">Category *</label>
            <select name="categoryId" class="form-select" required>
              <c:forEach items="${categories}" var="cat"><option value="${cat.id}" ${cat.id == book.categoryId ? 'selected' : ''}>${fn:escapeXml(cat.name)}</option></c:forEach>
            </select></div>
          <div class="col-md-3"><label class="form-label">Price (&#8377;) *</label><input name="price" type="number" step="0.01" min="1" class="form-control" required value="${isNew ? '' : book.price}"></div>
          <div class="col-md-3"><label class="form-label">Stock *</label><input name="stock" type="number" min="0" class="form-control" required value="${isNew ? 10 : book.stock}"></div>
          <div class="col-md-3"><label class="form-label">Rating</label><input name="rating" type="number" step="0.1" min="0" max="5" class="form-control" value="${isNew ? 4.0 : book.rating}"></div>
          <div class="col-md-3"><label class="form-label">Pages</label><input name="pages" type="number" min="1" class="form-control" value="${book.pages}"></div>
          <div class="col-md-6"><label class="form-label">Publisher</label><input name="publisher" class="form-control" maxlength="100" value="${fn:escapeXml(book.publisher)}"></div>
          <div class="col-md-3"><label class="form-label">Year</label><input name="pubYear" type="number" min="1000" max="2100" class="form-control" value="${book.pubYear}"></div>
          <div class="col-md-3"><label class="form-label">Cover file</label><input name="coverImage" class="form-control" maxlength="100" value="${fn:escapeXml(book.coverImage)}" placeholder="default.svg"></div>
          <div class="col-12"><label class="form-label">Description</label><textarea name="description" rows="5" class="form-control" maxlength="2000">${fn:escapeXml(book.description)}</textarea></div>
          <c:if test="${!isNew}">
            <div class="col-12"><div class="form-check form-switch"><input class="form-check-input" type="checkbox" name="active" id="active" ${book.active ? 'checked' : ''}><label class="form-check-label" for="active">Visible in the store</label></div></div>
          </c:if>
        </div>
      </div>
    </div>
    <div class="col-xl-4">
      <div class="panel text-center">
        <img src="${ctx}/assets/covers/${empty book.coverImage ? 'default.svg' : book.coverImage}" class="book-cover mb-3" style="max-width:180px" alt="">
        <p class="small text-muted-sw">Covers are stored in <code>assets/covers/</code>. Validation runs in <code>pkg_book</code> and trigger <code>trg_books_before_save</code>.</p>
        <button class="btn btn-accent w-100"><i class="bi bi-save me-1"></i>${isNew ? 'Add book' : 'Save changes'}</button>
      </div>
    </div>
  </div>
</form>

  </div>
</div>
<%@ include file="../common/footer.jspf" %>
