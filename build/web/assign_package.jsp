<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<% if (session.getAttribute("role")==null) { response.sendRedirect("login.jsp"); return; } 
   String role = (String) session.getAttribute("role"); String navColor = "STAFF".equals(role) ? "#198754" : "#0d6efd";
   String custId = request.getParameter("id");
   if(custId == null) { response.sendRedirect("customers.jsp"); return; }
%>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Assign Package</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
    body { background-color: #f4f7f6; color: #333; }
    .navbar { display: flex; align-items: center; justify-content: space-between; padding: 15px 30px; background-color: <%=navColor%>; color: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .navbar a { color: white; text-decoration: none; margin-right: 20px; font-size: 15px; }
    .nav-brand { font-size: 20px; font-weight: bold; margin-right: 30px; }
    .nav-right { display: flex; align-items: center; }
    .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 14px; display: inline-block; }
    .btn-light { background-color: white; color: <%= "STAFF".equals(role) ? "#198754" : "#0d6efd" %> !important; font-weight: bold; }
    .btn-primary { background-color: #0d6efd; color: white; width: 100%; padding: 12px; font-size: 16px;}
    .container { max-width: 500px; margin: 50px auto; padding: 0 20px; }
    .card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
    .form-group { margin-bottom: 20px; }
    .form-group label { display: block; margin-bottom: 8px; font-weight: bold; color: #555; }
    .form-control { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 15px; }
    .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; background-color: #e3f2fd; color: #0d6efd; border: 1px solid #b6d4fe;}
</style>
</head><body>

<nav class="navbar">
  <div>
    <a class="nav-brand" href="<%= "STAFF".equals(role) ? "staff_dashboard.jsp" : "admin_dashboard.jsp" %>"><%= "STAFF".equals(role) ? "ISP Staff" : "ISP Admin" %></a>
    <a href="customers.jsp">Back to Customers</a>
  </div>
  <div class="nav-right">
    <a href="logout" class="btn btn-light">Logout</a>
  </div>
</nav>

<div class="container">
  <div class="card">
    <h3 class="mb-4">Assign / Change Package</h3>
    <%
      String custName = "";
      try(Connection c=DBConnection.getConnection(); PreparedStatement ps=c.prepareStatement("SELECT NAME FROM CUSTOMER WHERE CUSTOMER_ID=?")){
         ps.setInt(1, Integer.parseInt(custId)); ResultSet r=ps.executeQuery();
         if(r.next()) custName = r.getString(1);
      }
    %>
    <div class="alert">
      <b>Customer:</b> <%= custName %> (ID: <%= custId %>)
    </div>
    
    <form method="post" action="assign_package_action.jsp">
      <input type="hidden" name="customerId" value="<%= custId %>">
      
      <div class="form-group">
        <label>Action Type</label>
        <select name="actionType" class="form-control" required>
          <option value="UPDATE">Update Current Package (Upgrade/Downgrade)</option>
          <option value="ADD">Add Additional Package (Multi-Connection)</option>
        </select>
      </div>

      <div class="form-group">
        <label>Select New Package</label>
        <select name="packageId" class="form-control" required>
          <option value="">-- Select Package --</option>
          <%
            try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement(); 
                ResultSet r=st.executeQuery("SELECT PACKAGE_ID, PACKAGE_NAME, SPEED_MBPS, MONTHLY_PRICE FROM PACKAGE WHERE STATUS='ACTIVE'")){
                while(r.next()){ %>
                <option value="<%= r.getInt(1) %>"><%= r.getString(2) %> (<%= r.getInt(3) %> Mbps - <%= r.getDouble(4) %> Tk)</option>
            <% }} %>
        </select>
      </div>

      <button type="submit" class="btn btn-primary">Confirm & Save</button>
    </form>
  </div>
</div>
</body></html>