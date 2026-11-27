package com.isp.servlet;
import com.isp.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/bills")
public class BillServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try (Connection c = DBConnection.getConnection()) {
            String month = req.getParameter("month");
            CallableStatement cs = c.prepareCall("{call PROC_GENERATE_BILLS(?)}"); cs.setString(1, month); cs.execute(); c.commit();
        } catch (Exception e) { throw new ServletException(e); }
        resp.sendRedirect("bills.jsp?msg=success");
    }
}