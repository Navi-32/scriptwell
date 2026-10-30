package com.scriptwell.controller;

import com.scriptwell.dao.BookDAO;
import com.scriptwell.dao.OrderDAO;
import com.scriptwell.dao.UserDAO;
import com.scriptwell.model.Book;
import com.scriptwell.util.DBConnection;
import com.scriptwell.util.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Administrator area (protected by AuthFilter):
 *   /admin              dashboard          /admin/orders      order management
 *   /admin/books        book list (CRUD)   /admin/inventory   low stock + stock log
 *   /admin/books/edit   add / edit form    /admin/users       customers
 */
@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getPathInfo() == null ? "/" : req.getPathInfo();
        String view;
        try {
            switch (path) {
                case "/books":
                    req.setAttribute("books", bookDAO.allForAdmin());
                    view = "books";
                    break;
                case "/books/edit":
                    Integer id = WebUtil.intParam(req, "id");
                    req.setAttribute("book", id == null ? new Book() : bookDAO.findById(id));
                    req.setAttribute("categories", bookDAO.categories());
                    view = "book-form";
                    break;
                case "/orders":
                    String status = WebUtil.str(req, "status");
                    req.setAttribute("orders", orderDAO.allOrders(status));
                    req.setAttribute("status", status);
                    view = "orders";
                    break;
                case "/inventory":
                    req.setAttribute("lowStock", bookDAO.lowStock(5));
                    req.setAttribute("log", bookDAO.inventoryLog(40));
                    view = "inventory";
                    break;
                case "/users":
                    req.setAttribute("users", userDAO.all());
                    view = "users";
                    break;
                default:
                    req.setAttribute("stats", orderDAO.dashboardStats());
                    req.setAttribute("sales", orderDAO.salesByCategory());
                    req.setAttribute("recent", orderDAO.allOrders(null).stream().limit(6).toList());
                    req.setAttribute("lowStock", bookDAO.lowStock(5));
                    view = "dashboard";
            }
        } catch (SQLException e) {
            req.setAttribute("error", DBConnection.friendlyMessage(e));
            view = "dashboard";
        }
        req.setAttribute("adminPage", view);
        req.getRequestDispatcher(WebUtil.VIEWS + "admin/" + view + ".jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getPathInfo() == null ? "/" : req.getPathInfo();
        String back = "/admin/books";
        try {
            switch (path) {
                case "/books/save": {
                    Book b = readBook(req);
                    if (b.getId() == 0) {
                        int id = bookDAO.add(b);
                        WebUtil.flash(req, "success", "Book #" + id + " \"" + b.getTitle() + "\" added.");
                    } else {
                        bookDAO.update(b);
                        WebUtil.flash(req, "success", "\"" + b.getTitle() + "\" updated.");
                    }
                    break;
                }
                case "/books/delete": {
                    String outcome = bookDAO.delete(WebUtil.intParam(req, "id", 0));
                    WebUtil.flash(req, "success", "DELETED".equals(outcome)
                            ? "Book deleted."
                            : "Book has order history, so it was deactivated instead of deleted.");
                    break;
                }
                case "/books/stock": {
                    int change = WebUtil.intParam(req, "change", 0);
                    bookDAO.adjustStock(WebUtil.intParam(req, "id", 0), change);
                    WebUtil.flash(req, "success", "Stock adjusted by " + (change > 0 ? "+" : "") + change + ".");
                    back = "/admin/inventory";
                    break;
                }
                case "/orders/status": {
                    int id = WebUtil.intParam(req, "id", 0);
                    String status = WebUtil.str(req, "status");
                    orderDAO.updateStatus(id, status);
                    WebUtil.flash(req, "success", "Order #" + id + " marked as " + status + ".");
                    back = "/admin/orders";
                    break;
                }
                default:
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
            }
        } catch (SQLException e) {
            WebUtil.flash(req, "danger", DBConnection.friendlyMessage(e));
            if (path.equals("/books/save")) {
                // stay on the form so the admin can correct the input
                req.setAttribute("error", DBConnection.friendlyMessage(e));
                req.getSession().removeAttribute("flashMsg");
                req.setAttribute("book", readBook(req));
                try {
                    req.setAttribute("categories", bookDAO.categories());
                } catch (SQLException ignored) { }
                req.setAttribute("adminPage", "book-form");
                req.getRequestDispatcher(WebUtil.VIEWS + "admin/book-form.jsp").forward(req, resp);
                return;
            }
            if (path.startsWith("/orders")) back = "/admin/orders";
            if (path.equals("/books/stock")) back = "/admin/inventory";
        }
        String ret = req.getParameter("returnTo");
        if (ret != null && ret.startsWith("/admin")) back = ret;
        resp.sendRedirect(req.getContextPath() + back);
    }

    private Book readBook(HttpServletRequest req) {
        Book b = new Book();
        b.setId(WebUtil.intParam(req, "id", 0));
        b.setTitle(WebUtil.str(req, "title"));
        b.setAuthor(WebUtil.str(req, "author"));
        b.setIsbn(WebUtil.str(req, "isbn"));
        b.setCategoryId(WebUtil.intParam(req, "categoryId", 0));
        Double price = WebUtil.doubleParam(req, "price");
        b.setPrice(price == null ? 0 : price);
        b.setStock(WebUtil.intParam(req, "stock", -1));
        b.setDescription(WebUtil.str(req, "description"));
        String cover = WebUtil.str(req, "coverImage");
        b.setCoverImage(cover.isEmpty() ? null : cover);
        b.setPublisher(WebUtil.str(req, "publisher"));
        b.setPubYear(WebUtil.intParam(req, "pubYear"));
        b.setPages(WebUtil.intParam(req, "pages"));
        Double rating = WebUtil.doubleParam(req, "rating");
        b.setRating(rating == null ? 4.0 : rating);
        b.setActive(req.getParameter("active") != null || b.getId() == 0);
        return b;
    }
}
