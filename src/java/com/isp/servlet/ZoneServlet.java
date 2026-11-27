package com.isp.servlet;

import com.isp.db.DBConnection;
import com.isp.util.AuditLogger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/zones")
public class ZoneServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        
        if (req.getSession().getAttribute("role") == null || !"ADMIN".equals(req.getSession().getAttribute("role"))) {
            resp.sendRedirect("login.jsp"); return;
        }

        int adminId = (Integer) req.getSession().getAttribute("userId");
        String adminName = (String) req.getSession().getAttribute("username");

        try (Connection c = DBConnection.getConnection()) {
            if ("save".equals(action)) {
                PreparedStatement ps = c.prepareStatement("INSERT INTO ZONE_STATUS (AREA_NAME, STATUS, REASON) VALUES (?, ?, ?)");
                ps.setString(1, req.getParameter("areaName"));
                ps.setString(2, req.getParameter("status"));
                ps.setString(3, req.getParameter("reason"));
                ps.executeUpdate();
                AuditLogger.log(c, adminId, adminName, "ADD_ZONE", "Added zone: " + req.getParameter("areaName"));
            } 
            else if ("update".equals(action)) {
                PreparedStatement ps = c.prepareStatement("UPDATE ZONE_STATUS SET STATUS=?, REASON=?, UPDATED_AT=SYSDATE WHERE ZONE_ID=?");
                ps.setString(1, req.getParameter("status"));
                ps.setString(2, req.getParameter("reason"));
                ps.setInt(3, Integer.parseInt(req.getParameter("zoneId")));
                ps.executeUpdate();
                AuditLogger.log(c, adminId, adminName, "UPDATE_ZONE", "Updated zone ID: " + req.getParameter("zoneId"));
            } 
            else if ("delete".equals(action)) {
                PreparedStatement ps = c.prepareStatement("DELETE FROM ZONE_STATUS WHERE ZONE_ID=?");
                ps.setInt(1, Integer.parseInt(req.getParameter("zoneId")));
                ps.executeUpdate();
                AuditLogger.log(c, adminId, adminName, "DELETE_ZONE", "Deleted zone ID: " + req.getParameter("zoneId"));
            }
            c.commit();
        } catch (Exception e) { throw new ServletException(e); }
        
        resp.sendRedirect("zone_management.jsp");
    }
}