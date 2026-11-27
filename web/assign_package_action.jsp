<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<%
    String custId = request.getParameter("customerId");
    String actionType = request.getParameter("actionType");
    String packageId = request.getParameter("packageId");

    if (custId != null && actionType != null && packageId != null) {
        try (Connection c = DBConnection.getConnection()) {
            if ("UPDATE".equals(actionType)) {
                // পুরোনো প্যাকেজ আপডেট করা
                PreparedStatement ps = c.prepareStatement("UPDATE SUBSCRIPTION SET PACKAGE_ID=? WHERE CUSTOMER_ID=? AND STATUS='ACTIVE'");
                ps.setInt(1, Integer.parseInt(packageId));
                ps.setInt(2, Integer.parseInt(custId));
                ps.executeUpdate();
            } else if ("ADD".equals(actionType)) {
                // নতুন প্যাকেজ যোগ করা (মাল্টিপল কানেকশন)
                PreparedStatement ps = c.prepareStatement("INSERT INTO SUBSCRIPTION (CUSTOMER_ID, PACKAGE_ID, STATUS) VALUES (?, ?, 'ACTIVE')");
                ps.setInt(1, Integer.parseInt(custId));
                ps.setInt(2, Integer.parseInt(packageId));
                ps.executeUpdate();
            }
            c.commit();
        } catch (Exception e) { e.printStackTrace(); }
    }
    response.sendRedirect("customers.jsp?msg=" + java.net.URLEncoder.encode("Package assigned successfully!", "UTF-8") + "&type=success");
%>