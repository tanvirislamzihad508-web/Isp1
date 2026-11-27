package com.isp.servlet;
import com.isp.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/packages")
public class PackageServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        try (Connection c = DBConnection.getConnection()) {
            if ("save".equals(action)) {
                String id = req.getParameter("packageId"); String name = req.getParameter("packageName");
                int speed = Integer.parseInt(req.getParameter("speed")); double price = Double.parseDouble(req.getParameter("price"));
                String status = req.getParameter("status");
                if (id == null || id.isEmpty()) {
                    PreparedStatement ps = c.prepareStatement("INSERT INTO PACKAGE (PACKAGE_NAME,SPEED_MBPS,MONTHLY_PRICE,STATUS) VALUES (?,?,?,?)");
                    ps.setString(1,name); ps.setInt(2,speed); ps.setDouble(3,price); ps.setString(4,status); ps.executeUpdate();
                } else {
                    PreparedStatement ps = c.prepareStatement("UPDATE PACKAGE SET PACKAGE_NAME=?,SPEED_MBPS=?,MONTHLY_PRICE=?,STATUS=? WHERE PACKAGE_ID=?");
                    ps.setString(1,name); ps.setInt(2,speed); ps.setDouble(3,price); ps.setString(4,status); ps.setInt(5,Integer.parseInt(id)); ps.executeUpdate();
                }
                c.commit();
            } else if ("delete".equals(action)) {
                PreparedStatement ps = c.prepareStatement("DELETE FROM PACKAGE WHERE PACKAGE_ID=?"); ps.setInt(1, Integer.parseInt(req.getParameter("id"))); ps.executeUpdate(); c.commit();
            }
        } catch (Exception e) { throw new ServletException(e); }
        resp.sendRedirect("packages.jsp");
    }
}