package com.scriptwell.controller;

import com.scriptwell.dao.BookDAO;
import com.scriptwell.util.DBConnection;
import com.scriptwell.util.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(urlPatterns = { "", "/home" })
public class HomeServlet extends HttpServlet {

    private final BookDAO bookDAO = new BookDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("categories", bookDAO.categories());
            req.setAttribute("featured", bookDAO.featured(8));
            req.setAttribute("arrivals", bookDAO.newArrivals(6));
        } catch (SQLException e) {
            req.setAttribute("error", DBConnection.friendlyMessage(e));
        }
        req.getRequestDispatcher(WebUtil.VIEWS + "home.jsp").forward(req, resp);
    }
}
