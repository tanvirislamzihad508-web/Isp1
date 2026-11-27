<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection,java.text.SimpleDateFormat"%>
<% if (session.getAttribute("role")==null || !"ADMIN".equals(session.getAttribute("role"))) { response.sendRedirect("login.jsp"); return; } %>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Activity Logs</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
    body { background-color: #f4f7f6; color: #333; }
    .navbar { display: flex; align-items: center; justify-content: space-between; padding: 15px 30px; background-color: #0d6efd; color: white; }
    .navbar a { color: white; text-decoration: none; margin-right: 20px; font-size: 15px; }
    .nav-brand { font-size: 20px; font-weight: bold; margin-right: 30px; }
    .container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }
    table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
    th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #e0e0e0; font-size: 14px;}
    th { background-color: #343a40; color: white; }
    tr:hover { background-color: #f8f9fa; }
    .badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; color: white; background: #0d6efd;}
</style>
</head><body>
<nav class="navbar">
  <div>
    <a class="nav-brand" href="admin_dashboard.jsp">ISP Admin</a>
    <a href="admin_dashboard.jsp">Dashboard</a>
    <a href="staff_management.jsp">Staff Management</a>
    <a href="admin_activity_log.jsp" style="font-weight:bold; text-decoration:underline;">Activity Logs</a>
  </div>
  <div><a href="logout" style="background:white; color:#0d6efd; padding:5px 10px; border-radius:4px; font-weight:bold;">Logout</a></div>
</nav>
<div class="container">
    <h2 style="margin-bottom: 20px;">System Activity Logs</h2>
    <table>
        <thead><tr><th>Time</th><th>User</th><th>Action</th><th>Details</th></tr></thead>
        <tbody>
        <% 
        String q = "SELECT * FROM ACTIVITY_LOG ORDER BY LOG_ID DESC";
        try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement(); ResultSet rs=st.executeQuery(q)){
            boolean hasData = false;
            while(rs.next()){ hasData = true; %>
            <tr>
                <td style="color:#666;"><%= new SimpleDateFormat("dd MMM yyyy, hh:mm a").format(rs.getDate("LOG_TIME")) %></td>
                <td><b><%= rs.getString("USERNAME") %></b></td>
                <td><span class="badge"><%= rs.getString("ACTION_TYPE") %></span></td>
                <td><%= rs.getString("DETAILS") %></td>
            </tr>
        <% } if(!hasData) { %><tr><td colspan="4" style="text-align:center; color:#999;">No activity found.</td></tr><% } 
        } catch(Exception e) { out.print("<tr><td colspan='4'>" + e.getMessage() + "</td></tr>"); } %>
        </tbody>
    </table>
</div>
</body></html>