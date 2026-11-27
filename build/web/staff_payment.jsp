<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<% if (session.getAttribute("role")==null) { response.sendRedirect("login.jsp"); return; } 
   String role = (String) session.getAttribute("role"); String navColor = "STAFF".equals(role) ? "#198754" : "#0d6efd"; %>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Payments</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
    body { background-color: #f4f7f6; color: #333; }
    .navbar { display: flex; align-items: center; justify-content: space-between; padding: 15px 30px; background-color: <%=navColor%>; color: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .navbar a { color: white; text-decoration: none; margin-right: 20px; font-size: 15px; transition: 0.3s; }
    .navbar a:hover { opacity: 0.8; }
    .navbar a.active { font-weight: bold; border-bottom: 3px solid white; padding-bottom: 5px; }
    .nav-brand { font-size: 20px; font-weight: bold; margin-right: 30px; }
    .nav-right { display: flex; align-items: center; }
    .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 14px; display: inline-block; }
    .btn-light { background-color: white; color: <%= "STAFF".equals(role) ? "#198754" : "#0d6efd" %> !important; font-weight: bold; }
    .btn-primary { background-color: #0d6efd; color: white; }
    .container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }
    .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); margin-bottom: 30px; }
    .form-row { display: flex; gap: 15px; flex-wrap: wrap; align-items: flex-end; }
    .form-group { flex: 1; min-width: 150px; }
    .form-group label { display: block; margin-bottom: 5px; font-size: 14px; font-weight: bold; color: #555; }
    .form-control { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; }
    table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-radius: 8px; overflow: hidden; }
    th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #e0e0e0; }
    th { background-color: #343a40; color: white; font-weight: 500; }
    tr:hover { background-color: #f8f9fa; }
    .badge { padding: 5px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; color: white; background-color: #dc3545; }
    .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; background-color: #d1e7dd; color: #0f5132; border: 1px solid #badbcc;}
</style>
</head><body>
<nav class="navbar">
  <div>
    <a class="nav-brand" href="<%= "STAFF".equals(role) ? "staff_dashboard.jsp" : "admin_dashboard.jsp" %>"><%= "STAFF".equals(role) ? "ISP Staff" : "ISP Admin" %></a>
    <a href="packages.jsp">Packages</a><a href="customers.jsp">Customers</a><a href="bills.jsp">Bills</a><a href="staff_payment.jsp">Payments</a><a href="complaints.jsp">Complaints</a>
  </div>
  <div class="nav-right">
    <span style="margin-right: 20px;">Welcome, <%=session.getAttribute("username")%></span>
    <a href="logout" class="btn btn-light">Logout</a>
  </div>
</nav>
<div class="container">
  <% if ("paid".equals(request.getParameter("msg"))) { %><div class="alert">Payment recorded successfully!</div><% } %>
  <h2 style="margin-bottom: 20px;">Record Payment</h2>
  <div class="card">
    <form method="post" action="payments" class="form-row">
      <div class="form-group"><label>Bill ID</label><input name="billId" type="number" class="form-control" required></div>
      <div class="form-group"><label>Amount</label><input name="amount" type="number" step="0.01" class="form-control" required></div>
      <div class="form-group"><label>Method</label><select name="method" class="form-control"><option>CASH</option><option>BKASH</option><option>NAGAD</option><option>ROCKET</option></select></div>
      <div class="form-group"><button class="btn btn-primary" style="width:100%; padding: 11px;">Save Payment</button></div>
    </form>
  </div>
  <h3 style="margin-bottom: 15px;">Due Bills</h3>
  <table>
    <thead><tr><th>Bill ID</th><th>Customer</th><th>Phone</th><th>Month</th><th>Amount</th><th>Status</th></tr></thead>
    <tbody>
    <% try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement(); ResultSet r=st.executeQuery("SELECT * FROM V_DUE_LIST ORDER BY BILL_ID")){
        while(r.next()){ %>
          <tr><td><%=r.getInt("BILL_ID")%></td><td><%=r.getString("NAME")%></td><td><%=r.getString("PHONE")%></td><td><%=r.getString("BILL_MONTH")%></td><td><%=r.getDouble("AMOUNT")%></td><td><span class="badge"><%=r.getString("STATUS")%></span></td></tr>
    <% }} %>
    </tbody>
  </table>
</div>
<script>
  document.addEventListener("DOMContentLoaded", function() {
    const currentPath = window.location.pathname;
    document.querySelectorAll('.navbar a').forEach(link => {
      if (currentPath.includes(link.getAttribute('href')) && !link.classList.contains('nav-brand') && !link.classList.contains('btn-light')) link.classList.add('active');
    });
  });
</script>
</body></html>