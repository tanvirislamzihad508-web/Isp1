package com.isp.filter;

import com.isp.db.DBConnection;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebFilter(urlPatterns = {"/*"})
public class AuthFilter implements Filter {
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest r = (HttpServletRequest) req; 
        HttpServletResponse p = (HttpServletResponse) res;
        HttpSession s = r.getSession(false); 
        String path = r.getRequestURI();
        
        if (path.endsWith("login.jsp") || path.endsWith("login") || path.endsWith("logout") || 
            path.endsWith("forgot_password.jsp") || path.endsWith("forgot") || path.endsWith("index.html") || 
            path.contains("css") || path.contains("js")) {
            chain.doFilter(req, res); return;
        }
        
        if (s == null || s.getAttribute("role") == null) {
            p.sendRedirect(r.getContextPath() + "/login.jsp?msg=login-required"); return;
        }
        
        // Single Device Login Check
        Integer userId = (Integer) s.getAttribute("userId");
        try (Connection c = DBConnection.getConnection(); 
             PreparedStatement ps = c.prepareStatement("SELECT SESSION_ID FROM USERS WHERE USER_ID=?")) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String dbSessionId = rs.getString("SESSION_ID");
                // যদি ডাটাবেসের সেশন আইডি আর বর্তমান সেশন আইডি না মেলে (মানে অন্য কেউ লগইন করেছে)
                if (dbSessionId == null || !dbSessionId.equals(s.getId())) {
                    s.invalidate();
                    p.sendRedirect(r.getContextPath() + "/login.jsp?msg=invalid-session");
                    return;
                }
            }
        } catch (Exception e) { /* Ignore DB error for filter */ }

        String role = (String) s.getAttribute("role");
        if (path.contains("admin_") && !"ADMIN".equals(role)) { p.sendError(403, "Access Denied!"); return; }
        if (path.contains("staff_") && !"STAFF".equals(role) && !"ADMIN".equals(role)) { p.sendError(403, "Access Denied!"); return; }
        
        chain.doFilter(req, res);
    }
    public void init(FilterConfig f) {}
    public void destroy() {}
}