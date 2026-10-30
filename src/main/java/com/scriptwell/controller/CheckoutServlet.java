package com.scriptwell.controller;

import com.scriptwell.dao.BookDAO;
import com.scriptwell.dao.CartDAO;
import com.scriptwell.dao.OrderDAO;
import com.scriptwell.model.Book;
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

/**
 * GET  /checkout                  -> checkout for the whole cart
 * GET  /checkout?bookId=N&qty=Q   -> "Buy Now" checkout for one book
 * POST /checkout                  -> simulated payment, then PKG_ORDER places the order
 */
@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAO();
    private final BookDAO bookDAO = new BookDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            if (!prepareSummary(req)) {
                WebUtil.flash(req, "warning", "Your cart is empty. Add a book before checking out.");
                resp.sendRedirect(req.getContextPath() + "/books");
                return;
            }
        } catch (SQLException e) {
            req.setAttribute("error", DBConnection.friendlyMessage(e));
        }
        req.getRequestDispatcher(WebUtil.VIEWS + "checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = WebUtil.currentUser(req);
        String address = String.join(", ",
                WebUtil.str(req, "address"), WebUtil.str(req, "city"),
                WebUtil.str(req, "state") + " " + WebUtil.str(req, "pincode")).trim();
        String payment = WebUtil.str(req, "payment");
        Integer bookId = WebUtil.intParam(req, "bookId");
        int qty = WebUtil.intParam(req, "qty", 1);

        try {
            String paymentError = validatePayment(req, payment);
            if (paymentError != null) throw new IllegalArgumentException(paymentError);

            Object[] result = bookId != null
                    ? orderDAO.buyNow(user.getId(), bookId, qty, address, payment)
                    : orderDAO.placeOrder(user.getId(), address, payment);

            req.getSession().setAttribute("cartCount", cartDAO.count(user.getId()));
            resp.sendRedirect(req.getContextPath() + "/order?id=" + result[0] + "&placed=1");
            return;
        } catch (SQLException e) {
            req.setAttribute("error", DBConnection.friendlyMessage(e));
        } catch (IllegalArgumentException e) {
            req.setAttribute("error", e.getMessage());
        }
        try {
            prepareSummary(req);
        } catch (SQLException ignored) { }
        req.getRequestDispatcher(WebUtil.VIEWS + "checkout.jsp").forward(req, resp);
    }

    /** Puts the items and totals for the summary panel into the request. */
    private boolean prepareSummary(HttpServletRequest req) throws SQLException {
        User user = WebUtil.currentUser(req);
        Integer bookId = WebUtil.intParam(req, "bookId");
        List<CartItem> items;
        double subtotal;

        if (bookId != null) {
            Book b = bookDAO.findById(bookId);
            if (b == null) return false;
            int qty = Math.max(1, Math.min(WebUtil.intParam(req, "qty", 1), 99));
            CartItem item = new CartItem();
            item.setBookId(b.getId());
            item.setTitle(b.getTitle());
            item.setAuthor(b.getAuthor());
            item.setCoverImage(b.getCoverImage());
            item.setPrice(b.getPrice());
            item.setStock(b.getStock());
            item.setQuantity(qty);
            item.setLineTotal(b.getPrice() * qty);
            items = List.of(item);
            subtotal = item.getLineTotal();
            req.setAttribute("buyNow", item);
        } else {
            items = cartDAO.items(user.getId());
            subtotal = cartDAO.total(user.getId());
        }
        if (items.isEmpty()) return false;

        double shipping = cartDAO.shippingFor(subtotal);
        req.setAttribute("items", items);
        req.setAttribute("subtotal", subtotal);
        req.setAttribute("shipping", shipping);
        req.setAttribute("total", subtotal + shipping);
        return true;
    }

    /** The payment is simulated: we only check the format, nothing is charged or stored. */
    private String validatePayment(HttpServletRequest req, String method) {
        switch (method) {
            case "CARD": {
                String card = WebUtil.str(req, "cardNumber").replaceAll("\\s", "");
                if (!card.matches("\\d{16}") || !luhn(card)) return "Please enter a valid 16-digit card number";
                if (!WebUtil.str(req, "expiry").matches("(0[1-9]|1[0-2])/\\d{2}")) return "Expiry must be in MM/YY format";
                if (!WebUtil.str(req, "cvv").matches("\\d{3}")) return "CVV must be 3 digits";
                return null;
            }
            case "UPI":
                return WebUtil.str(req, "upiId").matches("[\\w.\\-]{2,}@[a-zA-Z]{2,}") ? null : "Please enter a valid UPI ID (e.g. name@okbank)";
            case "COD":
                return null;
            default:
                return "Please choose a payment method";
        }
    }

    private boolean luhn(String number) {
        int sum = 0;
        boolean dbl = false;
        for (int i = number.length() - 1; i >= 0; i--) {
            int d = number.charAt(i) - '0';
            if (dbl && (d *= 2) > 9) d -= 9;
            sum += d;
            dbl = !dbl;
        }
        return sum % 10 == 0;
    }
}
