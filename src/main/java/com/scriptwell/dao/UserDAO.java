package com.scriptwell.dao;

import com.scriptwell.model.User;
import com.scriptwell.util.DBConnection;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/** Registration and login through PKG_USER (passwords are hashed in PL/SQL). */
public class UserDAO {

    public int register(String name, String email, String password, String phone, String address)
            throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_user.register_user(?,?,?,?,?,?)}")) {
            cs.setString(1, name);
            cs.setString(2, email);
            cs.setString(3, password);
            BookDAO.setString(cs, 4, phone);
            BookDAO.setString(cs, 5, address);
            cs.registerOutParameter(6, Types.NUMERIC);
            cs.execute();
            return cs.getInt(6);
        }
    }

    /** Throws SQLException with code 20002 when the credentials are wrong. */
    public User login(String email, String password) throws SQLException {
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_user.login_user(?,?,?)}")) {
            cs.setString(1, email);
            cs.setString(2, password);
            cs.registerOutParameter(3, Types.REF_CURSOR);
            cs.execute();
            try (ResultSet rs = cs.getObject(3, ResultSet.class)) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public List<User> all() throws SQLException {
        List<User> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             CallableStatement cs = con.prepareCall("{call pkg_user.get_all_users(?)}")) {
            cs.registerOutParameter(1, Types.REF_CURSOR);
            cs.execute();
            try (ResultSet rs = cs.getObject(1, ResultSet.class)) {
                while (rs.next()) {
                    User u = map(rs);
                    u.setOrderCount(rs.getInt("order_count"));
                    u.setTotalSpent(rs.getDouble("total_spent"));
                    list.add(u);
                }
            }
        }
        return list;
    }

    private User map(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("user_id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setAddress(rs.getString("address"));
        u.setRole(rs.getString("role"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        return u;
    }
}
