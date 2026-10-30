package com.scriptwell.dao;

import com.scriptwell.model.CartItem;
import com.scriptwell.util.DBConnection;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/** Shopping cart stored in the CART_ITEMS table, managed by PKG_CART. */
public class CartDAO {

    public void add(int userId, int bookId, int qty) throws SQLException {
        call("{call pkg_cart.add_item(?,?,?)}", userId, bookId, qty);
    }

    public void update(int userId, int bookId, int qty) throws SQLException {
        call("{call pkg_cart.update_item(?,?,?)}", userId, bookId, qty);
    }

    public void remove(int userId, int bookId) throws SQLException {
        call("{call pkg_cart.remove_item(?,?)}", userId, bookId);
    }

    public void clear(int userId) throws SQLException {
        call("{call pkg_cart.clear_cart(?)}", userId);
    }

    public List<CartItem> items(int userId) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_cart.get_cart(?,?)}")) {
            cs.setInt(1, userId);
            cs.registerOutParameter(2, Types.REF_CURSOR);
            cs.execute();
            return readItems(cs.getObject(2, ResultSet.class));
        }
    }

    public double total(int userId) throws SQLException {
        return function("{? = call pkg_cart.cart_total(?)}", userId);
    }

    public int count(int userId) throws SQLException {
        return (int) function("{? = call pkg_cart.cart_count(?)}", userId);
    }

    /** Calls the stand-alone PL/SQL function FN_SHIPPING_CHARGE. */
    public double shippingFor(double subtotal) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{? = call fn_shipping_charge(?)}")) {
            cs.registerOutParameter(1, Types.NUMERIC);
            cs.setDouble(2, subtotal);
            cs.execute();
            return cs.getDouble(1);
        }
    }

    static List<CartItem> readItems(ResultSet rs) throws SQLException {
        List<CartItem> list = new ArrayList<>();
        try (rs) {
            boolean hasStock = rs.getMetaData().getColumnCount() >= 8;
            while (rs.next()) {
                CartItem i = new CartItem();
                i.setBookId(rs.getInt("book_id"));
                i.setTitle(rs.getString("title"));
                i.setAuthor(rs.getString("author"));
                i.setCoverImage(rs.getString("cover_image"));
                i.setQuantity(rs.getInt("quantity"));
                i.setLineTotal(rs.getDouble("line_total"));
                if (hasStock) {
                    i.setPrice(rs.getDouble("price"));
                    i.setStock(rs.getInt("stock"));
                } else {
                    i.setPrice(rs.getDouble("unit_price"));
                }
                list.add(i);
            }
        }
        return list;
    }

    private void call(String sql, int... args) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            for (int i = 0; i < args.length; i++) cs.setInt(i + 1, args[i]);
            cs.execute();
        }
    }

    private double function(String sql, int arg) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            cs.registerOutParameter(1, Types.NUMERIC);
            cs.setInt(2, arg);
            cs.execute();
            return cs.getDouble(1);
        }
    }
}
