package com.isp.servlet;

import com.isp.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/SubmitPaymentRequestServlet")
public class SubmitPaymentRequestServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int uid = (Integer) req.getSession().getAttribute("userId");
        try (Connection c = DBConnection.getConnection()) {
            // কাস্টমারের আইডি বের করা
            PreparedStatement getCid = c.prepareStatement("SELECT CUSTOMER_ID FROM CUSTOMER WHERE USER_ID=?");
            getCid.setInt(1, uid);
            ResultSet rsCid = getCid.executeQuery();
            int customerId = 0;
            if(rsCid.next()) customerId = rsCid.getInt(1);

            // পেমেন্ট রিকোয়েস্ট ইনসার্ট করা
            PreparedStatement ps = c.prepareStatement("INSERT INTO PAYMENT_REQUESTS (BILL_ID, CUSTOMER_ID, AMOUNT, METHOD, TRX_ID) VALUES (?,?,?,?,?)");
            ps.setInt(1, Integer.parseInt(req.getParameter("billId")));
            ps.setInt(2, customerId);
            ps.setDouble(3, Double.parseDouble(req.getParameter("amount")));
            ps.setString(4, req.getParameter("method"));
            ps.setString(5, req.getParameter("trxId"));
            ps.executeUpdate();
            c.commit();
        } catch (Exception e) { throw new ServletException(e); }
        
        resp.sendRedirect("customer_dashboard.jsp?msg=request_sent");
    }
}