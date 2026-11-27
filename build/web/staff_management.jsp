<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<% if (session.getAttribute("role")==null || !"ADMIN".equals(session.getAttribute("role"))) { response.sendRedirect("login.jsp"); return; } %>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Staff Management</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
    body { background-color: #f4f7f6; color: #333; }
    .navbar { display: flex; align-items: center; justify-content: space-between; padding: 15px 30px; background-color: #0d6efd; color: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .navbar a { color: white; text-decoration: none; margin-right: 20px; font-size: 15px; }
    .nav-brand { font-size: 20px; font-weight: bold; margin-right: 30px; }
    .container { max-width: 1000px; margin: 40px auto; padding: 0 20px; display: flex; gap: 20px; flex-wrap: wrap; }
    .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); flex: 1; min-width: 300px; }
    .form-group { margin-bottom: 15px; } .form-group label { display: block; margin-bottom: 5px; font-weight: bold; font-size: 14px;}
    .form-control { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; }
    .btn { padding: 10px 15px; border: none; border-radius: 4px; cursor: pointer; font-size: 15px; font-weight: bold; width: 100%; color: white; background: #198754; }
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { padding: 10px; text-align: left; border-bottom: 1px solid #eee; font-size: 14px;}
    th { background-color: #343a40; color: white; }
    .alert { padding: 12px; border-radius: 4px; margin-bottom: 15px; font-size: 14px;}
    .alert-success { background-color: #d1e7dd; color: #0f5132; } .alert-danger { background-color: #f8d7da; color: #842029; }
    .btn-del { background: #dc3545; color: white; padding: 5px 10px; text-decoration: none; border-radius: 4px; font-size: 12px;}
</style>
</head><body>
<nav class="navbar">
  <div>
    <a class="nav-brand" href="admin_dashboard.jsp">ISP Admin</a>
    <a href="admin_dashboard.jsp">Dashboard</a>
    <a href="staff_management.jsp" style="font-weight:bold; text-decoration:underline;">Staff Management</a>
    <a href="admin_activity_log.jsp">Activity Logs</a>
  </div>
  <div><a href="logout" style="background:white; color:#0d6efd; padding:5px 10px; border-radius:4px; font-weight:bold;">Logout</a></div>
</nav>
<div class="container">
  <div class="card">
    <h3 style="margin-bottom: 15px; color: #0d6efd;">➕ Add New Staff</h3>
    <% if (request.getParameter("msg") != null) { String t = request.getParameter("type")!=null?request.getParameter("type"):"success"; %>
        <div class="alert alert-<%=t%>"><%= request.getParameter("msg") %></div>
    <% } %>
    <form method="post" action="staff">
      <input type="hidden" name="action" value="save">
      <div class="form-group"><label>Username (Login ID)</label><input type="text" name="username" class="form-control" required placeholder="e.g. staff2"></div>
      <div class="form-group"><label>Password</label><input type="text" name="password" class="form-control" required placeholder="e.g. pass123"></div>
      <button type="submit" class="btn">Create Staff Account</button>
    </form>
  </div>

  <div class="card" style="flex: 2;">
    <h3 style="margin-bottom: 15px; color: #333;">Current Staff Members</h3>
    <table>
      <thead><tr><th>User ID</th><th>Username</th><th>Password</th><th>Action</th></tr></thead>
      <tbody>
        <% try(Connection c = DBConnection.getConnection(); Statement st = c.createStatement();
            ResultSet rs = st.executeQuery("SELECT USER_ID, USERNAME, PLAIN_PASSWORD FROM USERS WHERE ROLE='STAFF' ORDER BY USER_ID")) {
            boolean hasStaff = false;
            while(rs.next()) { hasStaff = true; %>
            <tr>
              <td><%= rs.getInt("USER_ID") %></td>
              <td><b><%= rs.getString("USERNAME") %></b></td>
              <td><span style="background:#eee; padding:3px 6px; border-radius:3px; font-family:monospace;"><%= rs.getString("PLAIN_PASSWORD") %></span></td>
              <td>
                <form method="post" action="staff" style="display:inline;" onsubmit="return confirm('Delete this staff?')">
                  <input type="hidden" name="action" value="delete">
                  <input type="hidden" name="id" value="<%= rs.getInt("USER_ID") %>">
                  <button type="submit" class="btn-del">Delete</button>
                </form>
              </td>
            </tr>
        <% } if(!hasStaff) { %><tr><td colspan="4" style="text-align:center; color:#999;">No staff members found.</td></tr><% }
        } catch(Exception e) { out.print(e.getMessage()); } %>
      </tbody>
    </table>
  </div>
</div>
</body></html>