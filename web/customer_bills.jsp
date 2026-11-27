<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<% if (session.getAttribute("role")==null) { response.sendRedirect("login.jsp"); return; } int uid=(Integer)session.getAttribute("userId"); %>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>My Bills</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
    body { background-color: #f4f7f6; color: #333; }
    .navbar { display: flex; align-items: center; justify-content: space-between; padding: 15px 30px; background-color: #212529; color: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .navbar a { color: white; text-decoration: none; margin-right: 20px; font-size: 15px; transition: 0.3s; }
    .navbar a:hover { opacity: 0.8; }
    .navbar a.active { font-weight: bold; border-bottom: 3px solid white; padding-bottom: 5px; }
    .nav-brand { font-size: 20px; font-weight: bold; margin-right: 30px; }
    .nav-right { display: flex; align-items: center; }
    .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 14px; display: inline-block; }
    .btn-light { background-color: white; color: #212529 !important; font-weight: bold; }
    .btn-outline-dark { border: 1px solid #333; color: #333; background: transparent; padding: 4px 10px; font-size: 12px; border-radius: 4px; }
    .container { max-width: 900px; margin: 40px auto; padding: 0 20px; }
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
    <a class="nav-brand" href="customer_dashboard.jsp">My ISP</a>
    <a href="customer_dashboard.jsp">My Profile</a><a href="customer_bills.jsp">My Bills</a><a href="customer_complaints.jsp">Support</a>
  </div>
  <div class="nav-right">
    <a href="logout" class="btn btn-light">Logout</a>
  </div>
</nav>
<div class="container">
  <h2 style="margin-bottom: 20px;">My Bills</h2>
  <table>
    <thead><tr><th>Bill ID</th><th>Month</th><th>Amount</th><th>Due Date</th><th>Status</th><th>Print</th></tr></thead>
    <tbody>
    <% String q="SELECT B.BILL_ID,B.BILL_MONTH,B.AMOUNT,B.DUE_DATE,B.STATUS FROM BILL B JOIN SUBSCRIPTION S ON B.SUBSCRIPTION_ID=S.SUBSCRIPTION_ID JOIN CUSTOMER C ON S.CUSTOMER_ID=C.CUSTOMER_ID WHERE C.USER_ID=? ORDER BY B.BILL_MONTH DESC";
      try(Connection c=DBConnection.getConnection(); PreparedStatement ps=c.prepareStatement(q)){
        ps.setInt(1,uid); ResultSet r=ps.executeQuery();
        while(r.next()){ String st=r.getString(5); String cls = "PAID".equals(st)?"bg-paid":("PARTIAL".equals(st)?"bg-partial":"bg-unpaid"); %>
          <tr><td><%=r.getInt(1)%></td><td><%=r.getString(2)%></td><td><%=r.getDouble(3)%></td><td><%=r.getDate(4)%></td>
            <td><span class="badge <%=cls%>"><%=st%></span></td>
            <td><a class="btn-outline-dark" target="_blank" href="customer_invoice.jsp?billId=<%=r.getInt(1)%>">Invoice</a></td></tr>
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