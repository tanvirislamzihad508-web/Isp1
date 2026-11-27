<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<% if (session.getAttribute("role")==null) { response.sendRedirect("login.jsp"); return; } 
   String role = (String) session.getAttribute("role"); String navColor = "STAFF".equals(role) ? "#198754" : "#0d6efd"; %>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Packages</title>
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
    .btn-success { background-color: #198754; color: white; } .btn-warning { background-color: #ffc107; color: #000; } .btn-danger { background-color: #dc3545; color: white; }
    .container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }
    table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-radius: 8px; overflow: hidden; }
    th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #e0e0e0; }
    th { background-color: #343a40; color: white; font-weight: 500; }
    tr:hover { background-color: #f8f9fa; }
    .actions form { display: inline; }
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
  <h2 style="margin-bottom: 20px;">Internet Packages</h2>
  <a href="package_form.jsp" class="btn btn-success" style="margin-bottom: 20px;">+ New Package</a>
  <table>
    <thead><tr><th>ID</th><th>Name</th><th>Speed (Mbps)</th><th>Price</th><th>Status</th><th>Action</th></tr></thead>
    <tbody>
    <% try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement(); ResultSet r=st.executeQuery("SELECT * FROM PACKAGE ORDER BY PACKAGE_ID")){
      while(r.next()){ %>
      <tr><td><%=r.getInt("PACKAGE_ID")%></td><td><%=r.getString("PACKAGE_NAME")%></td><td><%=r.getInt("SPEED_MBPS")%></td><td><%=r.getDouble("MONTHLY_PRICE")%></td><td><%=r.getString("STATUS")%></td>
        <td class="actions"><a class="btn btn-warning" style="padding: 4px 10px; font-size: 12px;" href="package_form.jsp?id=<%=r.getInt("PACKAGE_ID")%>">Edit</a>
          <form method="post" action="packages" onsubmit="return confirm('Delete?')"><input type="hidden" name="action" value="delete"><input type="hidden" name="id" value="<%=r.getInt("PACKAGE_ID")%>"><button class="btn btn-danger" style="padding: 4px 10px; font-size: 12px;">Delete</button></form>
        </td></tr>
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