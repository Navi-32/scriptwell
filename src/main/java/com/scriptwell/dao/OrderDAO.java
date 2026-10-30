package com.scriptwell.dao;

import com.scriptwell.model.Order;
import com.scriptwell.util.DBConnection;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Checkout, order history and admin order management through PKG_ORDER. */
public class OrderDAO {

    /** Converts the user's cart into an order. Returns {orderId, paymentRef}. */
    public Object[] placeOrder(int userId, String address, String payment) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_order.place_order(?,?,?,?,?)}")) {
            cs.setInt(1, userId);
            cs.setString(2, address);
            cs.setString(3, payment);
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.registerOutParameter(5, Types.VARCHAR);
            cs.execute();
            return new Object[] { cs.getInt(4), cs.getString(5) };
        }
    }

    /** Buys a single book directly, leaving the cart untouched. */
    public Object[] buyNow(int userId, int bookId, int qty, String address, String payment)
            throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_order.buy_now(?,?,?,?,?,?,?)}")) {
            cs.setInt(1, userId);
            cs.setInt(2, bookId);
            cs.setInt(3, qty);
            cs.setString(4, address);
            cs.setString(5, payment);
            cs.registerOutParameter(6, Types.NUMERIC);
            cs.registerOutParameter(7, Types.VARCHAR);
            cs.execute();
            return new Object[] { cs.getInt(6), cs.getString(7) };
        }
    }

    public List<Order> userOrders(int userId) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_order.get_user_orders(?,?)}")) {
            cs.setInt(1, userId);
            cs.registerOutParameter(2, Types.REF_CURSOR);
            cs.execute();
            List<Order> list = new ArrayList<>();
            try (ResultSet rs = cs.getObject(2, ResultSet.class)) {
                while (rs.next()) {
                    Order o = mapSummary(rs);
                    o.setFirstCover(rs.getString("first_cover"));
                    list.add(o);
                }
            }
            return list;
        }
    }

    /** @param userId owner check; pass null for the admin view. */
    public Order find(int orderId, Integer userId) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_order.get_order(?,?,?,?)}")) {
            cs.setInt(1, orderId);
            BookDAO.setInt(cs, 2, userId);
            cs.registerOutParameter(3, Types.REF_CURSOR);
            cs.registerOutParameter(4, Types.REF_CURSOR);
            cs.execute();
            Order o = null;
            try (ResultSet rs = cs.getObject(3, ResultSet.class)) {
                if (rs.next()) {
                    o = new Order();
                    o.setId(rs.getInt("order_id"));
                    o.setOrderDate(rs.getTimestamp("order_date"));
                    o.setSubtotal(rs.getDouble("subtotal"));
                    o.setShippingCharge(rs.getDouble("shipping_charge"));
                    o.setTotal(rs.getDouble("total_amount"));
                    o.setStatus(rs.getString("status"));
                    o.setShippingAddress(rs.getString("shipping_address"));
                    o.setPaymentMethod(rs.getString("payment_method"));
                    o.setPaymentRef(rs.getString("payment_ref"));
                    o.setCustomerName(rs.getString("full_name"));
                    o.setCustomerEmail(rs.getString("email"));
                    o.setCustomerPhone(rs.getString("phone"));
                }
            }
            ResultSet items = cs.getObject(4, ResultSet.class);
            if (o != null) o.setItems(CartDAO.readItems(items));
            else items.close();
            return o;
        }
    }

    public List<Order> allOrders(String status) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_order.get_all_orders(?,?)}")) {
            BookDAO.setString(cs, 1, status);
            cs.registerOutParameter(2, Types.REF_CURSOR);
            cs.execute();
            List<Order> list = new ArrayList<>();
            try (ResultSet rs = cs.getObject(2, ResultSet.class)) {
                while (rs.next()) {
                    Order o = mapSummary(rs);
                    o.setCustomerName(rs.getString("full_name"));
                    o.setCustomerEmail(rs.getString("email"));
                    list.add(o);
                }
            }
            return list;
        }
    }

    public void updateStatus(int orderId, String status) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_order.update_status(?,?)}")) {
            cs.setInt(1, orderId);
            cs.setString(2, status);
            cs.execute();
        }
    }

    public void cancel(int orderId, int userId) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_order.cancel_order(?,?)}")) {
            cs.setInt(1, orderId);
            cs.setInt(2, userId);
            cs.execute();
        }
    }

    /** Calls the stand-alone procedure SP_GET_DASHBOARD_STATS (six OUT parameters). */
    public Map<String, Number> dashboardStats() throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call sp_get_dashboard_stats(?,?,?,?,?,?)}")) {
            for (int i = 1; i <= 6; i++) cs.registerOutParameter(i, Types.NUMERIC);
            cs.execute();
            Map<String, Number> m = new LinkedHashMap<>();
            m.put("books", cs.getInt(1));
            m.put("customers", cs.getInt(2));
            m.put("orders", cs.getInt(3));
            m.put("revenue", cs.getDouble(4));
            m.put("lowStock", cs.getInt(5));
            m.put("pending", cs.getInt(6));
            return m;
        }
    }

    /** Rows of {name, units, revenue} for the dashboard chart. */
    public List<Object[]> salesByCategory() throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_order.sales_by_category(?)}")) {
            cs.registerOutParameter(1, Types.REF_CURSOR);
            cs.execute();
            List<Object[]> rows = new ArrayList<>();
            try (ResultSet rs = cs.getObject(1, ResultSet.class)) {
                while (rs.next()) {
                    rows.add(new Object[] { rs.getString(1), rs.getInt(2), rs.getDouble(3) });
                }
            }
            return rows;
        }
    }

    private Order mapSummary(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setId(rs.getInt("order_id"));
        o.setOrderDate(rs.getTimestamp("order_date"));
        o.setTotal(rs.getDouble("total_amount"));
        o.setStatus(rs.getString("status"));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setPaymentRef(rs.getString("payment_ref"));
        o.setItemCount(rs.getInt("item_count"));
        return o;
    }
}
