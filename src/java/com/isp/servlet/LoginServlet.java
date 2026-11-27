package com.isp.servlet;

import com.isp.db.DBConnection;
import com.isp.util.PasswordUtil;
import com.isp.util.AuditLogger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String user = req.getParameter("username"); 
        String pass = req.getParameter("password");
        if(user != null) user = user.trim(); 
        if(pass != null) pass = pass.trim();
        
        try (Connection c = DBConnection.getConnection(); 
             PreparedStatement ps = c.prepareStatement("SELECT USER_ID,ROLE,STATUS,PASSWORD_HASH FROM USERS WHERE USERNAME=?")) {
            ps.setString(1, user); 
            ResultSet rs = ps.executeQuery();
            
            if (rs.next() && "ACTIVE".equals(rs.getString("STATUS")) && PasswordUtil.verify(pass, rs.getString("PASSWORD_HASH"))) {
                HttpSession oldSession = req.getSession(false); 
                if (oldSession != null) oldSession.invalidate();
                
                HttpSession s = req.getSession(true);
                int userId = rs.getInt("USER_ID");
                String role = rs.getString("ROLE");
                
                // সেশন আইডি ডাটাবেসে সেভ করা (Single Device Login এর জন্য)
                PreparedStatement upSession = c.prepareStatement("UPDATE USERS SET SESSION_ID=? WHERE USER_ID=?");
                upSession.setString(1, s.getId());
                upSession.setInt(2, userId);
                upSession.executeUpdate();
                c.commit();

                s.setAttribute("userId", userId); 
                s.setAttribute("username", user); 
                s.setAttribute("role", role);
                
                // Activity Log
                AuditLogger.log(c, userId, user, "LOGIN", "User logged in");

                if ("ADMIN".equals(role)) resp.sendRedirect("admin_dashboard.jsp");
                else if ("STAFF".equals(role)) resp.sendRedirect("staff_dashboard.jsp");
                else resp.sendRedirect("customer_dashboard.jsp");
            } else { 
                resp.sendRedirect("login.jsp?msg=invalid"); 
            }
        } catch (Exception e) { throw new ServletException(e); }
    }
}