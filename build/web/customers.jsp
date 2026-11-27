<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<% if (session.getAttribute("role")==null || "CUSTOMER".equals(session.getAttribute("role"))) { response.sendRedirect("login.jsp"); return; } 
   String role = (String) session.getAttribute("role"); String navColor = "STAFF".equals(role) ? "#198754" : "#0d6efd"; %>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Customers</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
    body { background-color: #f4f7f6; color: #333; }
    .navbar { display: flex; align-items: center; justify-content: space-between; padding: 15px 30px; background-color: <%=navColor%>; color: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .navbar a { color: white; text-decoration: none; margin-right: 20px; font-size: 15px; transition: 0.3s; }
    .navbar a:hover { opacity: 0.8; } .navbar a.active { font-weight: bold; border-bottom: 3px solid white; padding-bottom: 5px; }
    .nav-brand { font-size: 20px; font-weight: bold; margin-right: 30px; } .nav-right { display: flex; align-items: center; }
    .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 14px; display: inline-block; text-align: center; transition: 0.2s;}
    .btn:hover { opacity: 0.8; }
    .btn-light { background-color: white; color: <%= "STAFF".equals(role) ? "#198754" : "#0d6efd" %> !important; font-weight: bold; }
    .btn-success { background-color: #198754; color: white; } .btn-warning { background-color: #ffc107; color: #000; } 
    .btn-danger { background-color: #dc3545; color: white; } .btn-info { background-color: #0dcaf0; color: #000; font-weight: bold; }
    .container { max-width: 1200px; margin: 40px auto; padding: 0 20px; }
    .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; font-size: 14px; }
    .alert-success { background-color: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; } .alert-danger { background-color: #f8d7da; color: #842029; border: 1px solid #f5c2c7; }
    table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.05); border-radius: 8px; overflow: hidden; }
    th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #e0e0e0; vertical-align: middle; }
    th { background-color: #343a40; color: white; font-weight: 500; } tr:hover { background-color: #f8f9fa; }
    .badge { padding: 5px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; color: white; background-color: #6c757d; font-family: monospace; }
    .pkg-badge { display: inline-block; margin-bottom: 3px; margin-right: 3px; font-family: 'Segoe UI', sans-serif; font-size: 11px; padding: 4px 8px;}
    .bg-paid { background-color: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; } .bg-due { background-color: #f8d7da; color: #842029; border: 1px solid #f5c2c7; }
    .actions form { display: inline; }
</style>
</head><body>
<nav class="navbar">
  <div>
    <a class="nav-brand" href="<%= "STAFF".equals(role) ? "staff_dashboard.jsp" : "admin_dashboard.jsp" %>"><%= "STAFF".equals(role) ? "ISP Staff" : "ISP Admin" %></a>
    <a href="packages.jsp">Packages</a><a href="customers.jsp">Customers</a><a href="bills.jsp">Bills</a><a href="staff_payment.jsp">Payments</a><a href="complaints.jsp">Complaints</a>
  </div>
  <div class="nav-right"><span style="margin-right: 20px;">Welcome, <b><%=session.getAttribute("username")%></b></span><a href="logout" class="btn btn-light">Logout</a></div>
</nav>
<div class="container">
  <h2 style="margin-bottom: 20px;">Customers</h2>
  <% if (request.getParameter("msg") != null) { String t = request.getParameter("type")!=null?request.getParameter("type"):"success"; %>
      <div class="alert alert-<%=t%>"><%= request.getParameter("msg") %></div>
  <% } %>
  <a href="customer_form.jsp" class="btn btn-success" style="margin-bottom: 20px;">+ New Customer</a>
  <table>
    <thead><tr><th>ID</th><th>Name</th><th>Phone (Username)</th><th>Area</th><th>Packages (Current Status)</th><th>Password</th><th>Action</th></tr></thead>
    <tbody>
    <% 
      // LEFT JOIN ব্যবহার করা হয়েছে যাতে ইউজার না থাকলেও কাস্টমার লিস্টে দেখায়
      String q = "SELECT C.CUSTOMER_ID, C.NAME, C.PHONE, C.AREA, U.PLAIN_PASSWORD, " +
                 "(SELECT LISTAGG(P.PACKAGE_NAME || ' (' || NVL((SELECT MAX(B.STATUS) FROM BILL B WHERE B.SUBSCRIPTION_ID = S2.SUBSCRIPTION_ID AND B.BILL_MONTH = TO_CHAR(SYSDATE, 'YYYY-MM')), 'NO BILL') || ')', ' | ') WITHIN GROUP (ORDER BY P.PACKAGE_NAME) " +
                 " FROM SUBSCRIPTION S2 JOIN PACKAGE P ON S2.PACKAGE_ID = P.PACKAGE_ID WHERE S2.CUSTOMER_ID = C.CUSTOMER_ID AND S2.STATUS = 'ACTIVE') AS PKG_STATUS_LIST " +
                 "FROM CUSTOMER C LEFT JOIN USERS U ON C.USER_ID = U.USER_ID ORDER BY C.CUSTOMER_ID";
      try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement(); ResultSet r=st.executeQuery(q)){
        while(r.next()){ 
            String a = r.getString("AREA"); 
            String pkgStatus = r.getString("PKG_STATUS_LIST"); 
            String pass = r.getString("PLAIN_PASSWORD"); 
    %>
        <tr>
          <td><%=r.getInt("CUSTOMER_ID")%></td>
          <td><b><%=r.getString("NAME")%></b></td>
          <td><%=r.getString("PHONE")%></td>
          <td><%= (a==null||a.isEmpty())?"-":a %></td>
          <td style="line-height: 1.8;">
            <% if(pkgStatus != null && !pkgStatus.isEmpty()) { String[] pkgs = pkgStatus.split(" \\| ");
                   for(String p : pkgs) { String badgeColor = "bg-due"; if(p.contains("(PAID)")) badgeColor = "bg-paid"; else if(p.contains("(NO BILL)")) badgeColor = "bg-secondary"; %>
                <span class="badge pkg-badge <%=badgeColor%>"><%= p %></span>
            <% } } else { %><span style="color:#aaa;">-</span><% } %>
          </td>
          <td><% if(pass != null && !pass.isEmpty()) { %><span class="badge"><%= pass %></span><% } else { %><span style="color:#aaa;">***</span><% } %></td>
          <td class="actions">
            <a class="btn btn-info" style="padding: 4px 10px; font-size: 12px;" href="assign_package.jsp?id=<%=r.getInt(1)%>">Package</a>
            <a class="btn btn-warning" style="padding: 4px 10px; font-size: 12px;" href="customer_form.jsp?id=<%=r.getInt(1)%>">Edit</a>
            <form method="post" action="customers" onsubmit="return confirm('Delete customer?')"><input type="hidden" name="action" value="delete"><input type="hidden" name="id" value="<%=r.getInt(1)%>"><button class="btn btn-danger" style="padding: 4px 10px; font-size: 12px;">Delete</button></form>
          </td>
        </tr>
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