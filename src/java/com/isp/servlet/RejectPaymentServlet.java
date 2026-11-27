package com.isp.servlet;

import com.isp.db.DBConnection;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/RejectPaymentServlet")
public class RejectPaymentServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int reqId = Integer.parseInt(req.getParameter("reqId"));
        try (Connection c = DBConnection.getConnection()) {
            PreparedStatement ps = c.prepareStatement("UPDATE PAYMENT_REQUESTS SET STATUS='REJECTED' WHERE REQ_ID=?");
            ps.setInt(1, reqId); 
            ps.executeUpdate();
            c.commit();
        } catch (Exception e) { e.printStackTrace(); }
        resp.sendRedirect("admin_payment_requests.jsp");
    }
}