package com.isp.servlet;
import com.isp.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/payments")
public class PaymentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try (Connection c = DBConnection.getConnection()) {
            PreparedStatement ps = c.prepareStatement("INSERT INTO PAYMENT (BILL_ID,AMOUNT_PAID,METHOD,RECEIVED_BY) VALUES (?,?,?,?)");
            ps.setInt(1, Integer.parseInt(req.getParameter("billId"))); ps.setDouble(2, Double.parseDouble(req.getParameter("amount")));
            ps.setString(3, req.getParameter("method")); ps.setInt(4, (Integer) req.getSession().getAttribute("userId"));
            ps.executeUpdate(); c.commit();
        } catch (Exception e) { throw new ServletException(e); }
        resp.sendRedirect("staff_payment.jsp?msg=paid");
    }
}