package com.scriptwell.filter;

import com.scriptwell.model.User;
import com.scriptwell.util.WebUtil;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/** Requires a signed-in user for shopping pages, and the ADMIN role for /admin. */
@WebFilter(urlPatterns = { "/cart", "/checkout", "/orders", "/order", "/admin/*" })
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        User user = WebUtil.currentUser(req);

        if (user == null) {
            if ("fetch".equals(req.getHeader("X-Requested-With"))) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json");
                resp.getWriter().write("{\"ok\":false,\"login\":true,\"message\":\"Please sign in first\"}");
                return;
            }
            String next = req.getServletPath() + (req.getPathInfo() != null ? req.getPathInfo() : "");
            if ("GET".equals(req.getMethod()) && req.getQueryString() != null) next += "?" + req.getQueryString();
            WebUtil.flash(req, "info", "Please sign in to continue.");
            resp.sendRedirect(req.getContextPath() + "/login?next="
                    + URLEncoder.encode(next, StandardCharsets.UTF_8));
            return;
        }
        if (req.getServletPath().startsWith("/admin") && !user.isAdmin()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Administrators only");
            return;
        }
        chain.doFilter(request, response);
    }
}
