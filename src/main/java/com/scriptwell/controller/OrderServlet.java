package com.scriptwell.controller;

import com.scriptwell.dao.OrderDAO;
import com.scriptwell.model.Order;
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

/** /orders = order history, /order?id=N = order details / confirmation. */
@WebServlet(urlPatterns = { "/orders", "/order" })
public class OrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = WebUtil.currentUser(req);
        try {
            if ("/order".equals(req.getServletPath())) {
                Integer id = WebUtil.intParam(req, "id");
                Order order = id == null ? null : orderDAO.find(id, user.isAdmin() ? null : user.getId());
                if (order == null) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                    return;
                }
                req.setAttribute("order", order);
                req.setAttribute("placed", req.getParameter("placed") != null);
                req.getRequestDispatcher(WebUtil.VIEWS + "order.jsp").forward(req, resp);
                return;
            }
            req.setAttribute("orders", orderDAO.userOrders(user.getId()));
        } catch (SQLException e) {
            if (e.getErrorCode() == 20008) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                return;
            }
            req.setAttribute("error", DBConnection.friendlyMessage(e));
        }
        req.getRequestDispatcher(WebUtil.VIEWS + "orders.jsp").forward(req, resp);
    }

    /** Customer cancels an order that has not shipped yet. */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = WebUtil.currentUser(req);
        int id = WebUtil.intParam(req, "orderId", 0);
        try {
            orderDAO.cancel(id, user.getId());
            WebUtil.flash(req, "success", "Order #" + id + " was cancelled and the books returned to stock.");
        } catch (SQLException e) {
            WebUtil.flash(req, "danger", DBConnection.friendlyMessage(e));
        }
        resp.sendRedirect(req.getContextPath() + "/order?id=" + id);
    }
}
