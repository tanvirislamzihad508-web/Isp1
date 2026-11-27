<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<% if (session.getAttribute("role")==null) { response.sendRedirect("login.jsp"); return; } %>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Staff Dashboard</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
    body { background-color: #f4f7f6; color: #333; }
    .navbar { display: flex; align-items: center; justify-content: space-between; padding: 15px 30px; background-color: #198754; color: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .navbar a { color: white; text-decoration: none; margin-right: 20px; font-size: 15px; transition: 0.3s; }
    .navbar a:hover { opacity: 0.8; } .navbar a.active { font-weight: bold; border-bottom: 3px solid white; padding-bottom: 5px; }
    .nav-brand { font-size: 20px; font-weight: bold; margin-right: 30px; } .nav-right { display: flex; align-items: center; }
    .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 14px; display: inline-block; }
    .btn-light { background-color: white; color: #198754 !important; font-weight: bold; }
    .container { max-width: 1100px; margin: 40px auto; padding: 0 20px; text-align: center; }
    .welcome-box { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin-top: 50px; }
    h2 { color: #198754; margin-bottom: 10px; } p { color: #666; }
    .alert-box { background-color: #fff3cd; color: #856404; border: 1px solid #ffeeba; padding: 15px; border-radius: 6px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; text-align: left; }
</style>
</head><body>
<nav class="navbar">
  <div>
    <a class="nav-brand" href="staff_dashboard.jsp">ISP Staff</a>
    <a href="packages.jsp">Packages</a><a href="customers.jsp">Customers</a><a href="bills.jsp">Bills</a><a href="staff_payment.jsp">Payments</a><a href="complaints.jsp">Complaints</a>
    <!-- Manage Zones লিংক যোগ করা হলো -->
    <a href="zone_management.jsp">Manage Zones</a>
  </div>
  <div class="nav-right"><span style="margin-right: 20px;">Welcome, <%=session.getAttribute("username")%></span><a href="logout" class="btn btn-light">Logout</a></div>
</nav>
<div class="container">
  <%-- পেন্ডিং রিকোয়েস্ট অ্যালার্ট --%>
  <% 
    int pendingReqs = 0;
    try(Connection c = DBConnection.getConnection(); Statement st = c.createStatement(); 
        ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM PAYMENT_REQUESTS WHERE STATUS='PENDING'")) {
        if(rs.next()) pendingReqs = rs.getInt(1);
    } catch(Exception e) {}
    if (pendingReqs > 0) { 
  %>
    <div class="alert-box" style="max-width: 800px; margin: 0 auto 20px auto;">
        <div><strong>🔔 নতুন পেমেন্ট রিকোয়েস্ট!</strong> আপনার কাছে <b><%= pendingReqs %></b> টি পেন্ডিং পেমেন্ট রিকোয়েস্ট জমা আছে।</div>
        <a href="admin_payment_requests.jsp" style="background-color: #ffc107; color: #000; padding: 8px 15px; text-decoration: none; border-radius: 4px; font-weight: bold;">Check Now</a>
    </div>
  <% } %>
  <div class="welcome-box"><h2>Staff Dashboard</h2><p>Welcome to the Staff Panel. Please use the navigation menu above to manage customers, bills, zones, and payments.</p></div>
</div>
</body></html>