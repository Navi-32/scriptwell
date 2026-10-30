package com.scriptwell.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/** Opens JDBC connections to Oracle using settings from db.properties. */
public final class DBConnection {

    private static final Properties PROPS = new Properties();

    static {
        try (InputStream in = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in == null) throw new IllegalStateException("db.properties not found on classpath");
            PROPS.load(in);
            Class.forName(PROPS.getProperty("db.driver"));
        } catch (Exception e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    private DBConnection() { }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
                PROPS.getProperty("db.url"),
                PROPS.getProperty("db.user"),
                PROPS.getProperty("db.password"));
    }

    /**
     * Turns an Oracle error into a message for the user. Errors raised by our
     * PL/SQL with RAISE_APPLICATION_ERROR (-20000..-20999) carry readable text.
     */
    public static String friendlyMessage(SQLException e) {
        int code = e.getErrorCode();
        if (code >= 20000 && code <= 20999) {
            String msg = e.getMessage();
            int colon = msg.indexOf(':');
            msg = msg.substring(colon + 1).trim();
            int nl = msg.indexOf('\n');
            return (nl > 0 ? msg.substring(0, nl) : msg).trim();
        }
        e.printStackTrace();
        return "Something went wrong while talking to the database. Please try again.";
    }
}
