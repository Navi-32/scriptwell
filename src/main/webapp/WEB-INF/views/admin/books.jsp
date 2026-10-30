<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Manage books" />
<c:set var="hideFooter" value="true" />
<%@ include file="../common/header.jspf" %>
<%@ include file="sidebar.jspf" %>

<div class="d-flex justify-content-between align-items-center mb-4">
  <div><h1 class="h3 mb-0">Books</h1><small class="text-muted-sw">${fn:length(books)} titles in the catalogue</small></div>
  <a href="${ctx}/admin/books/edit" class="btn btn-accent"><i class="bi bi-plus-lg me-1"></i>Add book</a>
</div>

<div class="table-sw">
  <div class="table-responsive">
    <table class="table table-hover">
      <thead><tr><th>#</th><th>Book</th><th>Category</th><th>Price</th><th>Stock</th><th>Rating</th><th>Status</th><th class="text-end">Actions</th></tr></thead>
      <tbody>
        <c:forEach items="${books}" var="b">
          <tr class="${b.active ? '' : 'opacity-50'}">
            <td class="text-muted-sw">${b.id}</td>
            <td><div class="d-flex gap-2 align-items-center"><img src="${ctx}/assets/covers/${b.coverImage}" class="admin-thumb" alt="">
              <div><div class="fw-semibold">${fn:escapeXml(b.title)}</div><div class="small text-muted-sw">${fn:escapeXml(b.author)}</div></div></div></td>
            <td>${fn:escapeXml(b.categoryName)}</td>
            <td>&#8377;<fmt:formatNumber value="${b.price}" maxFractionDigits="0" /></td>
            <td><span class="badge ${b.stock == 0 ? 'bg-secondary' : (b.stock <= 5 ? 'bg-danger' : 'bg-success-subtle text-success')}">${b.stock}</span></td>
            <td>${b.rating}</td>
            <td>${b.active ? 'Active' : 'Inactive'}</td>
            <td class="text-end text-nowrap">
              <a href="${ctx}/admin/books/edit?id=${b.id}" class="btn btn-sm btn-outline-ink"><i class="bi bi-pencil"></i></a>
              <form method="post" action="${ctx}/admin/books/delete" class="d-inline" data-confirm="Delete &quot;${fn:escapeXml(b.title)}&quot;?">
                <input type="hidden" name="id" value="${b.id}">
                <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash3"></i></button>
              </form>
            </td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </div>
</div>

  </div>
</div>
<%@ include file="../common/footer.jspf" %>
