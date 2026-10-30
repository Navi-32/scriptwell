package com.scriptwell.controller;

import com.scriptwell.dao.CartDAO;
import com.scriptwell.model.CartItem;
import com.scriptwell.model.User;
import com.scriptwell.util.DBConnection;
import com.scriptwell.util.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = WebUtil.currentUser(req);
        try {
            List<CartItem> items = cartDAO.items(user.getId());
            double subtotal = cartDAO.total(user.getId());
            double shipping = cartDAO.shippingFor(subtotal);
            req.setAttribute("items", items);
            req.setAttribute("subtotal", subtotal);
            req.setAttribute("shipping", shipping);
            req.setAttribute("total", subtotal + shipping);
            req.getSession().setAttribute("cartCount", cartDAO.count(user.getId()));
        } catch (SQLException e) {
            req.setAttribute("error", DBConnection.friendlyMessage(e));
        }
        req.getRequestDispatcher(WebUtil.VIEWS + "cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = WebUtil.currentUser(req);
        String action = WebUtil.str(req, "action");
        int bookId = WebUtil.intParam(req, "bookId", 0);
        int qty = WebUtil.intParam(req, "qty", 1);
        boolean ajax = "fetch".equals(req.getHeader("X-Requested-With"));
        String message;
        boolean ok = true;
        try {
            switch (action) {
                case "add":    cartDAO.add(user.getId(), bookId, qty); message = "Added to your cart"; break;
                case "update": cartDAO.update(user.getId(), bookId, qty); message = "Cart updated"; break;
                case "remove": cartDAO.remove(user.getId(), bookId); message = "Item removed from cart"; break;
                case "clear":  cartDAO.clear(user.getId()); message = "Cart cleared"; break;
                default: message = "Unknown action"; ok = false;
            }
        } catch (SQLException e) {
            ok = false;
            message = DBConnection.friendlyMessage(e);
        }

        int count = 0;
        try {
            count = cartDAO.count(user.getId());
        } catch (SQLException ignored) { }
        req.getSession().setAttribute("cartCount", count);

        if (ajax) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"ok\":" + ok + ",\"count\":" + count
                    + ",\"message\":\"" + message.replace("\\", "\\\\").replace("\"", "\\\"") + "\"}");
            return;
        }
        WebUtil.flash(req, ok ? "success" : "danger", message);
        String back = "add".equals(action) && ok ? req.getHeader("Referer") : null;
        resp.sendRedirect(back != null ? back : req.getContextPath() + "/cart");
    }
}
