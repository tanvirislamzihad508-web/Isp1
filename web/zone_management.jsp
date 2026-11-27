<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<% if (session.getAttribute("role")==null || (!"ADMIN".equals(session.getAttribute("role")) && !"STAFF".equals(session.getAttribute("role")))) { response.sendRedirect("login.jsp"); return; } 
   String role = (String) session.getAttribute("role"); String navColor = "STAFF".equals(role) ? "#198754" : "#0d6efd";
%>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Manage Zones</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
    body { background-color: #f4f7f6; color: #333; }
    .navbar { display: flex; align-items: center; justify-content: space-between; padding: 15px 30px; background-color: <%=navColor%>; color: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .navbar a { color: white; text-decoration: none; margin-right: 20px; font-size: 15px; }
    .nav-brand { font-size: 20px; font-weight: bold; margin-right: 30px; }
    .nav-right { display: flex; align-items: center; }
    .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 14px; display: inline-block; }
    .btn-light { background-color: white; color: <%=navColor%> !important; font-weight: bold; }
    .btn-primary { background-color: #0d6efd; color: white; }
    .btn-success { background-color: #198754; color: white; }
    .container { max-width: 1000px; margin: 40px auto; padding: 0 20px; }
    .card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); margin-bottom: 20px;}
    table { width: 100%; border-collapse: collapse; margin-top: 15px; }
    th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; font-size: 14px; vertical-align: middle; }
    th { background-color: #f8f9fa; color: #555; }
    .form-control { padding: 8px; border: 1px solid #ccc; border-radius: 4px; width: 100%; }
    .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; background-color: #d1e7dd; color: #0f5132; }
    .form-row { display: flex; gap: 15px; align-items: flex-end; }
    .form-group { flex: 1; }
</style>
</head><body>

<nav class="navbar">
  <div>
    <a class="nav-brand" href="<%= "STAFF".equals(role) ? "staff_dashboard.jsp" : "admin_dashboard.jsp" %>"><%= "STAFF".equals(role) ? "ISP Staff" : "ISP Admin" %></a>
    <a href="packages.jsp">Packages</a><a href="customers.jsp">Customers</a><a href="bills.jsp">Bills</a><a href="staff_payment.jsp">Payments</a><a href="complaints.jsp">Complaints</a>
    <a href="zone_management.jsp" style="font-weight:bold; text-decoration:underline;">Manage Zones</a>
  </div>
  <div class="nav-right">
    <span style="margin-right: 20px;">Welcome, <%=session.getAttribute("username")%></span>
    <a href="logout" class="btn btn-light">Logout</a>
  </div>
</nav>

<div class="container">
  <% if ("updated".equals(request.getParameter("msg"))) { %><div class="alert">Zone status updated successfully!</div><% } %>
  <% if ("added".equals(request.getParameter("msg"))) { %><div class="alert" style="background:#cce5ff; color:#004085;">New zone added successfully!</div><% } %>
  
  <div class="card">
    <h3 style="margin-bottom: 15px; color: <%=navColor%>;">➕ Add New Zone</h3>
    <form method="post" action="zone_update.jsp" class="form-row">
      <input type="hidden" name="action" value="add">
      <div class="form-group"><label>Area Name</label><input type="text" name="areaName" class="form-control" required placeholder="e.g. Mirpur"></div>
      <div class="form-group"><label>Status</label>
        <select name="status" class="form-control">
          <option value="ACTIVE">ACTIVE</option>
          <option value="MAINTENANCE">MAINTENANCE</option>
          <option value="OFFLINE">OFFLINE</option>
        </select>
      </div>
      <div class="form-group" style="flex: 2;"><label>Reason</label><input type="text" name="reason" class="form-control" placeholder="e.g. Fiber cut"></div>
      <button type="submit" class="btn btn-success">Add Zone</button>
    </form>
  </div>

  <div class="card">
    <h2 style="margin-bottom: 20px;">WiFi Zone Status</h2>
    <table>
      <thead>
        <tr>
          <th>Area Name</th><th>Status</th><th>Reason (Visible to Customers)</th><th>Action</th>
        </tr>
      </thead>
      <tbody>
        <% 
           try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement();
               ResultSet r=st.executeQuery("SELECT * FROM ZONE_STATUS ORDER BY AREA_NAME")){
               boolean hasData = false;
               while(r.next()){ hasData = true;
                   int zid = r.getInt("ZONE_ID");
                   String status = r.getString("STATUS");
                   String reason = r.getString("REASON") != null ? r.getString("REASON") : "";
        %>
        <tr>
            <td><b><%= r.getString("AREA_NAME") %></b></td>
            <td>
              <select name="status" form="updateForm_<%=zid%>" class="form-control" style="width: 130px;">
                <option value="ACTIVE" <%= "ACTIVE".equals(status)?"selected":"" %>>ACTIVE</option>
                <option value="MAINTENANCE" <%= "MAINTENANCE".equals(status)?"selected":"" %>>MAINTENANCE</option>
                <option value="OFFLINE" <%= "OFFLINE".equals(status)?"selected":"" %>>OFFLINE</option>
              </select>
            </td>
            <td><input type="text" name="reason" form="updateForm_<%=zid%>" class="form-control" value="<%= reason %>" placeholder="e.g. Fiber cut"></td>
            <td>
              <form method="post" action="zone_update.jsp" id="updateForm_<%=zid%>">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="zoneId" value="<%=zid%>">
                <button type="submit" class="btn btn-primary" style="width: 100%;">Update</button>
              </form>
            </td>
        </tr>
        <% } if(!hasData) { %><tr><td colspan="4" style="text-align:center; color:#999;">No zones added yet. Add one above.</td></tr><% }
           } catch(Exception e) { out.print(e.getMessage()); } %>
      </tbody>
    </table>
  </div>
</div>
</body></html>