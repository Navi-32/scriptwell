package com.scriptwell.dao;

import com.scriptwell.model.Book;
import com.scriptwell.model.Category;
import com.scriptwell.util.DBConnection;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Book and category access through the PKG_BOOK PL/SQL package. */
public class BookDAO {

    public List<Book> search(String keyword, Integer categoryId, Double minPrice,
                             Double maxPrice, String sort) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_book.search_books(?,?,?,?,?,?)}")) {
            setString(cs, 1, keyword);
            setInt(cs, 2, categoryId);
            setDouble(cs, 3, minPrice);
            setDouble(cs, 4, maxPrice);
            setString(cs, 5, sort);
            cs.registerOutParameter(6, Types.REF_CURSOR);
            cs.execute();
            return readBooks(cs.getObject(6, ResultSet.class));
        }
    }

    public Book findById(int id) throws SQLException {
        List<Book> list = cursorCall("{call pkg_book.get_book(?,?)}", id);
        return list.isEmpty() ? null : list.get(0);
    }

    public List<Book> featured(int limit) throws SQLException {
        return cursorCall("{call pkg_book.get_featured(?,?)}", limit);
    }

    public List<Book> newArrivals(int limit) throws SQLException {
        return cursorCall("{call pkg_book.get_new_arrivals(?,?)}", limit);
    }

    public List<Book> related(int bookId) throws SQLException {
        return cursorCall("{call pkg_book.get_related(?,?)}", bookId);
    }

    public List<Book> lowStock(int threshold) throws SQLException {
        return cursorCall("{call pkg_book.get_low_stock(?,?)}", threshold);
    }

    public List<Book> allForAdmin() throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_book.get_all_books_admin(?)}")) {
            cs.registerOutParameter(1, Types.REF_CURSOR);
            cs.execute();
            return readBooks(cs.getObject(1, ResultSet.class));
        }
    }

    public List<Category> categories() throws SQLException {
        List<Category> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_book.get_categories(?)}")) {
            cs.registerOutParameter(1, Types.REF_CURSOR);
            cs.execute();
            try (ResultSet rs = cs.getObject(1, ResultSet.class)) {
                while (rs.next()) {
                    Category c = new Category();
                    c.setId(rs.getInt("category_id"));
                    c.setName(rs.getString("name"));
                    c.setDescription(rs.getString("description"));
                    c.setIcon(rs.getString("icon"));
                    c.setBookCount(rs.getInt("book_count"));
                    list.add(c);
                }
            }
        }
        return list;
    }

    public int add(Book b) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall(
                     "{call pkg_book.add_book(?,?,?,?,?,?,?,?,?,?,?,?,?)}")) {
            bindBook(cs, b, 1);
            cs.registerOutParameter(13, Types.NUMERIC);
            cs.execute();
            return cs.getInt(13);
        }
    }

    public void update(Book b) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall(
                     "{call pkg_book.update_book(?,?,?,?,?,?,?,?,?,?,?,?,?,?)}")) {
            cs.setInt(1, b.getId());
            bindBook(cs, b, 2);
            cs.setString(14, b.isActive() ? "Y" : "N");
            cs.execute();
        }
    }

    /** @return DELETED or DEACTIVATED (books with sales history are kept). */
    public String delete(int id) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_book.delete_book(?,?)}")) {
            cs.setInt(1, id);
            cs.registerOutParameter(2, Types.VARCHAR);
            cs.execute();
            return cs.getString(2);
        }
    }

    public void adjustStock(int id, int change) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_book.adjust_stock(?,?)}")) {
            cs.setInt(1, id);
            cs.setInt(2, change);
            cs.execute();
        }
    }

    public List<Map<String, Object>> inventoryLog(int limit) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_book.get_inventory_log(?,?)}")) {
            cs.setInt(1, limit);
            cs.registerOutParameter(2, Types.REF_CURSOR);
            cs.execute();
            try (ResultSet rs = cs.getObject(2, ResultSet.class)) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("logId", rs.getInt("log_id"));
                    row.put("title", rs.getString("title"));
                    row.put("oldStock", rs.getObject("old_stock"));
                    row.put("newStock", rs.getInt("new_stock"));
                    row.put("change", rs.getInt("change_qty"));
                    row.put("reason", rs.getString("reason"));
                    row.put("changedAt", rs.getTimestamp("changed_at"));
                    list.add(row);
                }
            }
        }
        return list;
    }

    // ------------------------------------------------------------------

    private List<Book> cursorCall(String sql, int arg) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, arg);
            cs.registerOutParameter(2, Types.REF_CURSOR);
            cs.execute();
            return readBooks(cs.getObject(2, ResultSet.class));
        }
    }

    private void bindBook(CallableStatement cs, Book b, int i) throws SQLException {
        cs.setString(i, b.getTitle());
        cs.setString(i + 1, b.getAuthor());
        setString(cs, i + 2, b.getIsbn());
        cs.setInt(i + 3, b.getCategoryId());
        cs.setDouble(i + 4, b.getPrice());
        cs.setInt(i + 5, b.getStock());
        setString(cs, i + 6, b.getDescription());
        setString(cs, i + 7, b.getCoverImage());
        setString(cs, i + 8, b.getPublisher());
        setInt(cs, i + 9, b.getPubYear());
        setInt(cs, i + 10, b.getPages());
        cs.setDouble(i + 11, b.getRating());
    }

    static List<Book> readBooks(ResultSet rs) throws SQLException {
        List<Book> list = new ArrayList<>();
        try (rs) {
            while (rs.next()) {
                Book b = new Book();
                b.setId(rs.getInt("book_id"));
                b.setTitle(rs.getString("title"));
                b.setAuthor(rs.getString("author"));
                b.setIsbn(rs.getString("isbn"));
                b.setCategoryId(rs.getInt("category_id"));
                b.setCategoryName(rs.getString("category_name"));
                b.setPrice(rs.getDouble("price"));
                b.setStock(rs.getInt("stock"));
                b.setDescription(rs.getString("description"));
                b.setCoverImage(rs.getString("cover_image"));
                b.setPublisher(rs.getString("publisher"));
                b.setPubYear((Integer) rs.getObject("pub_year", Integer.class));
                b.setPages((Integer) rs.getObject("pages", Integer.class));
                b.setRating(rs.getDouble("rating"));
                b.setActive("Y".equals(rs.getString("is_active")));
                list.add(b);
            }
        }
        return list;
    }

    static void setString(CallableStatement cs, int i, String v) throws SQLException {
        if (v == null || v.isBlank()) cs.setNull(i, Types.VARCHAR);
        else cs.setString(i, v.trim());
    }

    static void setInt(CallableStatement cs, int i, Integer v) throws SQLException {
        if (v == null) cs.setNull(i, Types.NUMERIC);
        else cs.setInt(i, v);
    }

    static void setDouble(CallableStatement cs, int i, Double v) throws SQLException {
        if (v == null) cs.setNull(i, Types.NUMERIC);
        else cs.setDouble(i, v);
    }
}
