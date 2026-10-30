package com.scriptwell.util;

import com.scriptwell.model.User;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/** Small helpers shared by the servlets. */
public final class WebUtil {

    private WebUtil() { }

    public static final String VIEWS = "/WEB-INF/views/";

    public static User currentUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s == null ? null : (User) s.getAttribute("user");
    }

    /** One-time message shown on the next page (flash scope). */
    public static void flash(HttpServletRequest req, String type, String text) {
        HttpSession s = req.getSession();
        s.setAttribute("flashType", type);
        s.setAttribute("flashMsg", text);
    }

    public static Integer intParam(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        if (v == null || v.isBlank()) return null;
        try {
            return Integer.valueOf(v.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public static int intParam(HttpServletRequest req, String name, int fallback) {
        Integer v = intParam(req, name);
        return v == null ? fallback : v;
    }

    public static Double doubleParam(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        if (v == null || v.isBlank()) return null;
        try {
            return Double.valueOf(v.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public static String str(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v == null ? "" : v.trim();
    }
}
