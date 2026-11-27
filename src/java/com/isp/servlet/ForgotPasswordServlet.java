package com.isp.servlet;

import com.isp.db.DBConnection;
import com.isp.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.Random;
import java.net.URLEncoder;

@WebServlet("/forgot")
public class ForgotPasswordServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String contact = req.getParameter("contact");
        if(contact != null) contact = contact.trim(); // স্পেস রিমুভ করা হলো

        try (Connection c = DBConnection.getConnection()) {
            // কাস্টমার টেবিল থেকে ইউজার আইডি বের করা
            PreparedStatement ps = c.prepareStatement("SELECT C.USER_ID, C.PHONE, C.EMAIL FROM CUSTOMER C WHERE TRIM(C.PHONE)=? OR TRIM(C.EMAIL)=?");
            ps.setString(1, contact); 
            ps.setString(2, contact); 
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                int userId = rs.getInt("USER_ID"); 
                String phone = rs.getString("PHONE"); 
                
                if(userId == 0) {
                     resp.sendRedirect("forgot_password.jsp?msg=" + URLEncoder.encode("Error: User account not linked properly.", "UTF-8"));
                     return;
                }

                // নতুন ৬ ডিজিটের পাসওয়ার্ড
                String newPass = String.format("%06d", new Random().nextInt(999999));
                
                // USERS টেবিলে পাসওয়ার্ড আপডেট করা
                PreparedStatement up = c.prepareStatement("UPDATE USERS SET PASSWORD_HASH=?, PLAIN_PASSWORD=? WHERE USER_ID=?");
                up.setString(1, PasswordUtil.hash(newPass)); 
                up.setString(2, newPass); 
                up.setInt(3, userId); 
                
                int rowsUpdated = up.executeUpdate();
                c.commit(); // কনফার্ম করা হলো

                if(rowsUpdated > 0) {
                    String notifMsg = "Success! SMS sent to " + phone + ". New Password: " + newPass;
                    resp.sendRedirect("forgot_password.jsp?msg=" + URLEncoder.encode(notifMsg, "UTF-8"));
                } else {
                    resp.sendRedirect("forgot_password.jsp?msg=" + URLEncoder.encode("Error: Failed to update password.", "UTF-8"));
                }
                
            } else { 
                resp.sendRedirect("forgot_password.jsp?msg=" + URLEncoder.encode("No account found with this Phone/Email.", "UTF-8")); 
            }
        } catch (Exception e) { 
            throw new ServletException(e); 
        }
    }
}