package com.scriptwell.controller;

import com.scriptwell.dao.CartDAO;
import com.scriptwell.dao.UserDAO;
import com.scriptwell.model.User;
import com.scriptwell.util.DBConnection;
import com.scriptwell.util.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(urlPatterns = { "/login", "/register", "/logout" })
public class AuthServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        switch (req.getServletPath()) {
            case "/logout":
                HttpSession s = req.getSession(false);
                if (s != null) s.invalidate();
                WebUtil.flash(req, "success", "You have been signed out. See you soon!");
                resp.sendRedirect(req.getContextPath() + "/home");
                break;
            case "/register":
                req.getRequestDispatcher(WebUtil.VIEWS + "register.jsp").forward(req, resp);
                break;
            default:
                req.getRequestDispatcher(WebUtil.VIEWS + "login.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if ("/register".equals(req.getServletPath())) register(req, resp);
        else login(req, resp);
    }

    private void login(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = WebUtil.str(req, "email");
        String password = req.getParameter("password");
        try {
            User user = userDAO.login(email, password);
            startSession(req, user);
            WebUtil.flash(req, "success", "Welcome back, " + user.getFirstName() + "!");
            String next = req.getParameter("next");
            if (user.isAdmin() && (next == null || next.isBlank())) next = "/admin";
            resp.sendRedirect(req.getContextPath() + safeNext(next));
        } catch (SQLException e) {
            req.setAttribute("error", DBConnection.friendlyMessage(e));
            req.setAttribute("email", email);
            req.getRequestDispatcher(WebUtil.VIEWS + "login.jsp").forward(req, resp);
        }
    }

    private void register(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String name = WebUtil.str(req, "fullName");
        String email = WebUtil.str(req, "email");
        String password = WebUtil.str(req, "password");
        String phone = WebUtil.str(req, "phone");
        String address = WebUtil.str(req, "address");
        try {
            if (!password.equals(req.getParameter("confirm"))) {
                throw new IllegalArgumentException("Passwords do not match");
            }
            userDAO.register(name, email, password, phone, address);
            startSession(req, userDAO.login(email, password));
            WebUtil.flash(req, "success", "Account created. Welcome to ScriptWell, " + name.split(" ")[0] + "!");
            resp.sendRedirect(req.getContextPath() + safeNext(req.getParameter("next")));
            return;
        } catch (SQLException e) {
            req.setAttribute("error", DBConnection.friendlyMessage(e));
        } catch (IllegalArgumentException e) {
            req.setAttribute("error", e.getMessage());
        }
        req.getRequestDispatcher(WebUtil.VIEWS + "register.jsp").forward(req, resp);
    }

    private void startSession(HttpServletRequest req, User user) throws SQLException {
        HttpSession old = req.getSession(false);
        if (old != null) old.invalidate(); // prevent session fixation
        HttpSession s = req.getSession(true);
        s.setAttribute("user", user);
        s.setAttribute("cartCount", cartDAO.count(user.getId()));
    }

    /** Only allow redirects inside this application. */
    private String safeNext(String next) {
        if (next == null || next.isBlank() || !next.startsWith("/") || next.startsWith("//")) return "/home";
        return next;
    }
}
