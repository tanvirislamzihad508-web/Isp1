<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<% if (session.getAttribute("role")==null) { response.sendRedirect("login.jsp"); return; } 
   String role = (String) session.getAttribute("role"); String navColor = "STAFF".equals(role) ? "#198754" : "#0d6efd"; %>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Complaints</title>
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
    table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-radius: 8px; overflow: hidden; }
    th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #e0e0e0; }
    th { background-color: #343a40; color: white; font-weight: 500; }
    tr:hover { background-color: #f8f9fa; }
    .badge { padding: 5px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; color: white; }
    .bg-open { background-color: #dc3545; } .bg-progress { background-color: #ffc107; color: #000; } .bg-resolved { background-color: #198754; }
    .form-inline { display: flex; gap: 5px; }
    .form-select { padding: 4px 8px; border-radius: 4px; border: 1px solid #ccc; }
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
  <h2 style="margin-bottom: 20px;">Customer Complaints</h2>
  <table>
    <thead><tr><th>ID</th><th>Customer Name</th><th>Subject</th><th>Status</th><th>Update Status</th></tr></thead>
    <tbody>
    <% try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement();
          ResultSet r=st.executeQuery("SELECT CO.COMPLAINT_ID, CU.NAME, CO.SUBJECT, CO.STATUS FROM COMPLAINT CO JOIN CUSTOMER CU ON CO.CUSTOMER_ID=CU.CUSTOMER_ID ORDER BY CO.COMPLAINT_ID DESC")){
        while(r.next()){ int cid = r.getInt(1); String status = r.getString(4);
            String badgeClass = "OPEN".equals(status) ? "bg-open" : ("IN_PROGRESS".equals(status) ? "bg-progress" : "bg-resolved"); %>
        <tr><td><%=cid%></td><td><%=r.getString(2)%></td><td><%=r.getString(3)%></td>
          <td><span class="badge <%=badgeClass%>"><%=status%></span></td>
          <td><form method="post" action="complaints" class="form-inline"><input type="hidden" name="action" value="update"><input type="hidden" name="id" value="<%=cid%>">
              <select name="status" class="form-select"><option value="OPEN" <%= "OPEN".equals(status)?"selected":"" %>>OPEN</option><option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(status)?"selected":"" %>>IN PROGRESS</option><option value="RESOLVED" <%= "RESOLVED".equals(status)?"selected":"" %>>RESOLVED</option></select>
              <button class="btn btn-primary" style="padding: 4px 10px; font-size: 12px;">Set</button>
          </form></td></tr>
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