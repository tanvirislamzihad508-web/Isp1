package com.isp.servlet;

import com.isp.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.net.URLEncoder;

@WebServlet("/complaints")
public class ComplaintServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        
        try (Connection c = DBConnection.getConnection()) {
            if ("submit".equals(action)) {
                Integer cid = null;
                PreparedStatement q = c.prepareStatement("SELECT CUSTOMER_ID FROM CUSTOMER WHERE USER_ID=?");
                q.setInt(1, (Integer) req.getSession().getAttribute("userId"));
                ResultSet rs = q.executeQuery();
                if (rs.next()) {
                    cid = rs.getInt(1);
                }

                // ★ নতুন সেফটি চেক: যদি cid null হয় (অর্থাৎ ইউজারের কোনো কাস্টমার প্রোফাইল নেই)
                if (cid == null) {
                    resp.sendRedirect("customer_complaints.jsp?msg=" + URLEncoder.encode("Error: Your account is not linked to any customer profile. Please contact Admin.", "UTF-8") + "&type=danger");
                    return;
                }

                PreparedStatement ps = c.prepareStatement("INSERT INTO COMPLAINT (CUSTOMER_ID,SUBJECT,DESCRIPTION,STATUS) VALUES (?,?,?,'OPEN')");
                ps.setInt(1, cid); 
                ps.setString(2, req.getParameter("subject")); 
                ps.setString(3, req.getParameter("description")); 
                ps.executeUpdate();
                
            } else if ("update".equals(action)) {
                PreparedStatement ps = c.prepareStatement("UPDATE COMPLAINT SET STATUS=?, ASSIGNED_TO=? WHERE COMPLAINT_ID=?");
                ps.setString(1, req.getParameter("status")); 
                ps.setInt(2, (Integer) req.getSession().getAttribute("userId"));
                ps.setInt(3, Integer.parseInt(req.getParameter("id"))); 
                ps.executeUpdate();
            }
            c.commit();
        } catch (Exception e) { 
            throw new ServletException(e); 
        }
        
        String role = (String) req.getSession().getAttribute("role");
        if ("CUSTOMER".equals(role)) {
            resp.sendRedirect("customer_complaints.jsp?msg=ok");
        } else {
            resp.sendRedirect("complaints.jsp?msg=ok");
        }
    }
}