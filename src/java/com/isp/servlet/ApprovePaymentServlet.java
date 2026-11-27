package com.isp.servlet;

import com.isp.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/ApprovePaymentServlet")
public class ApprovePaymentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int reqId = Integer.parseInt(req.getParameter("reqId"));
        int billId = Integer.parseInt(req.getParameter("billId"));
        double amount = Double.parseDouble(req.getParameter("amount"));
        String method = req.getParameter("method");
        int adminId = (Integer) req.getSession().getAttribute("userId");

        try (Connection c = DBConnection.getConnection()) {
            // ১. Payment টেবিলে আসল পেমেন্ট এন্ট্রি দেওয়া (ট্রিগার বিলের স্ট্যাটাস PAID করে দিবে)
            PreparedStatement ps1 = c.prepareStatement("INSERT INTO PAYMENT (BILL_ID, AMOUNT_PAID, METHOD, RECEIVED_BY) VALUES (?,?,?,?)");
            ps1.setInt(1, billId); 
            ps1.setDouble(2, amount); 
            ps1.setString(3, method); 
            ps1.setInt(4, adminId);
            ps1.executeUpdate();

            // ২. Payment Request এর স্ট্যাটাস APPROVED করা
            PreparedStatement ps2 = c.prepareStatement("UPDATE PAYMENT_REQUESTS SET STATUS='APPROVED' WHERE REQ_ID=?");
            ps2.setInt(1, reqId); 
            ps2.executeUpdate();
            
            c.commit();
        } catch (Exception e) { throw new ServletException(e); }
        resp.sendRedirect("admin_payment_requests.jsp?msg=success");
    }
}