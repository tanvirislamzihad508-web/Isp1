<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection,java.text.SimpleDateFormat"%>
<% if (session.getAttribute("role")==null) { response.sendRedirect("login.jsp"); return; } 
   String role = (String) session.getAttribute("role"); String navColor = "STAFF".equals(role) ? "#198754" : "#0d6efd"; %>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Bills</title>
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
    .btn-success { background-color: #198754; color: white; }
    .container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }
    .form-row { display: flex; gap: 15px; margin-bottom: 20px; align-items: center; }
    .form-control { padding: 10px; border: 1px solid #ccc; border-radius: 4px; }
    .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; background-color: #d1e7dd; color: #0f5132; }
    table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-radius: 8px; overflow: hidden; }
    th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #e0e0e0; }
    th { background-color: #343a40; color: white; font-weight: 500; }
    tr:hover { background-color: #f8f9fa; }
    .badge { padding: 5px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; color: white; }
    .bg-paid { background-color: #198754; } .bg-partial { background-color: #ffc107; color: #000; } .bg-unpaid { background-color: #dc3545; }
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
  <% if ("success".equals(request.getParameter("msg"))) { %><div class="alert">Bills generated successfully!</div><% } %>
  <h2 style="margin-bottom: 20px;">Monthly Bills</h2>
  <form method="post" action="bills" class="form-row">
    <input type="hidden" name="action" value="generate">
    <input name="month" class="form-control" value="<%=new SimpleDateFormat("yyyy-MM").format(new java.util.Date())%>" required>
    <button class="btn btn-success">Generate Bills</button>
  </form>
  <table>
    <thead><tr><th>ID</th><th>Customer</th><th>Package</th><th>Month</th><th>Amount</th><th>Status</th></tr></thead>
    <tbody>
    <% String q="SELECT B.BILL_ID,C.NAME,P.PACKAGE_NAME,B.BILL_MONTH,B.AMOUNT,B.STATUS FROM BILL B JOIN SUBSCRIPTION S ON B.SUBSCRIPTION_ID=S.SUBSCRIPTION_ID JOIN CUSTOMER C ON S.CUSTOMER_ID=C.CUSTOMER_ID JOIN PACKAGE P ON S.PACKAGE_ID=P.PACKAGE_ID ORDER BY B.BILL_ID DESC";
      try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement(); ResultSet r=st.executeQuery(q)){
        while(r.next()){ String st2=r.getString(6); String cls = "PAID".equals(st2)?"bg-paid":("PARTIAL".equals(st2)?"bg-partial":"bg-unpaid"); %>
        <tr><td><%=r.getInt(1)%></td><td><%=r.getString(2)%></td><td><%=r.getString(3)%></td><td><%=r.getString(4)%></td><td><%=r.getDouble(5)%></td><td><span class="badge <%=cls%>"><%=st2%></span></td></tr>
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