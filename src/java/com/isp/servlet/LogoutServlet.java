package com.isp.servlet;

import com.isp.db.DBConnection;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId != null) {
                try (Connection c = DBConnection.getConnection(); 
                     PreparedStatement ps = c.prepareStatement("UPDATE USERS SET SESSION_ID=NULL WHERE USER_ID=?")) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                    c.commit();
                } catch (Exception e) {}
            }
            session.invalidate();
        }
        resp.sendRedirect("login.jsp?msg=loggedout");
    }
}