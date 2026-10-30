package com.scriptwell.controller;

import com.scriptwell.dao.BookDAO;
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

/** /books = searchable, filterable catalogue; /book?id=N = book details. */
@WebServlet(urlPatterns = { "/books", "/book" })
public class CatalogServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            if ("/book".equals(req.getServletPath())) {
                showBook(req, resp);
                return;
            }
            String q = WebUtil.str(req, "q");
            Integer cat = WebUtil.intParam(req, "category");
            Double min = WebUtil.doubleParam(req, "min");
            Double max = WebUtil.doubleParam(req, "max");
            String sort = WebUtil.str(req, "sort");

            req.setAttribute("books", bookDAO.search(q, cat, min, max, sort));
            req.setAttribute("categories", bookDAO.categories());
            req.setAttribute("q", q);
            req.setAttribute("selCategory", cat);
            req.setAttribute("min", min);
            req.setAttribute("max", max);
            req.setAttribute("sort", sort);
            req.getRequestDispatcher(WebUtil.VIEWS + "catalog.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", DBConnection.friendlyMessage(e));
            req.getRequestDispatcher(WebUtil.VIEWS + "catalog.jsp").forward(req, resp);
        }
    }

    private void showBook(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        Integer id = WebUtil.intParam(req, "id");
        Book book = id == null ? null : bookDAO.findById(id);
        if (book == null || !book.isActive()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Book not found");
            return;
        }
        req.setAttribute("book", book);
        req.setAttribute("related", bookDAO.related(book.getId()));
        req.getRequestDispatcher(WebUtil.VIEWS + "book.jsp").forward(req, resp);
    }
}
