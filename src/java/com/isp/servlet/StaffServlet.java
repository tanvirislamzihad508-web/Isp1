package com.isp.servlet;

import com.isp.db.DBConnection;
import com.isp.util.PasswordUtil;
import com.isp.util.AuditLogger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.net.URLEncoder;

@WebServlet("/staff")
public class StaffServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        
        if (req.getSession().getAttribute("role") == null || !"ADMIN".equals(req.getSession().getAttribute("role"))) {
            resp.sendRedirect("login.jsp"); return;
        }

        int adminId = (Integer) req.getSession().getAttribute("userId");
        String adminName = (String) req.getSession().getAttribute("username");

        try (Connection c = DBConnection.getConnection()) {
            if ("save".equals(action)) {
                String username = req.getParameter("username");
                String password = req.getParameter("password");

                PreparedStatement check = c.prepareStatement("SELECT USER_ID FROM USERS WHERE USERNAME=?");
                check.setString(1, username);
                if (check.executeQuery().next()) {
                    resp.sendRedirect("staff_management.jsp?msg=" + URLEncoder.encode("Error: Username already exists!", "UTF-8") + "&type=danger");
                    return;
                }

                PreparedStatement ps = c.prepareStatement("INSERT INTO USERS (USERNAME, PASSWORD_HASH, PLAIN_PASSWORD, ROLE, STATUS) VALUES (?, ?, ?, 'STAFF', 'ACTIVE')");
                ps.setString(1, username);
                ps.setString(2, PasswordUtil.hash(password));
                ps.setString(3, password);
                ps.executeUpdate();
                
                AuditLogger.log(c, adminId, adminName, "CREATE_STAFF", "Created staff account: " + username);
                c.commit();

                resp.sendRedirect("staff_management.jsp?msg=" + URLEncoder.encode("Staff account created successfully!", "UTF-8") + "&type=success");
            } 
            else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                
                try {
                    // ১. প্রথমে কমপ্লেইন টেবিল থেকে এই স্টাফের রেফারেন্স রিমুভ করা (যাতে Foreign Key Error না আসে)
                    PreparedStatement psComp = c.prepareStatement("UPDATE COMPLAINT SET ASSIGNED_TO = NULL WHERE ASSIGNED_TO=?");
                    psComp.setInt(1, id);
                    psComp.executeUpdate();

                    // ২. এরপর ইউজার টেবিল থেকে স্টাফকে ডিলিট করা
                    PreparedStatement ps = c.prepareStatement("DELETE FROM USERS WHERE USER_ID=? AND ROLE='STAFF'");
                    ps.setInt(1, id);
                    ps.executeUpdate();
                    
                    AuditLogger.log(c, adminId, adminName, "DELETE_STAFF", "Deleted staff ID: " + id);
                    c.commit();
                    
                    resp.sendRedirect("staff_management.jsp?msg=" + URLEncoder.encode("Staff deleted successfully!", "UTF-8") + "&type=success");
                } catch (Exception ex) {
                    c.rollback();
                    resp.sendRedirect("staff_management.jsp?msg=" + URLEncoder.encode("Cannot delete this staff. They might have other records.", "UTF-8") + "&type=danger");
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}