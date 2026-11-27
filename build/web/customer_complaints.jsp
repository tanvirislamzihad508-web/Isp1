<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<% 
   if (session.getAttribute("role")==null || !"CUSTOMER".equals(session.getAttribute("role"))) { 
       response.sendRedirect("login.jsp"); return; 
   } 
   int uid = (Integer) session.getAttribute("userId");
%>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Support - My ISP</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
    body { background-color: #f4f7f6; color: #333; }
    
    /* Customer Navbar (Dark Theme) */
    .navbar { display: flex; align-items: center; justify-content: space-between; padding: 15px 30px; background-color: #212529; color: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .navbar a { color: white; text-decoration: none; margin-right: 20px; font-size: 15px; transition: 0.3s; }
    .navbar a:hover { opacity: 0.8; }
    .navbar a.active { font-weight: bold; border-bottom: 3px solid white; padding-bottom: 5px; }
    .nav-brand { font-size: 20px; font-weight: bold; margin-right: 30px; }
    .nav-right { display: flex; align-items: center; }
    
    .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 14px; display: inline-block; transition: 0.2s; }
    .btn:hover { opacity: 0.8; }
    .btn-light { background-color: white; color: #212529 !important; font-weight: bold; }
    .btn-primary { background-color: #0d6efd; color: white; width: 100%; font-weight: bold; padding: 12px; font-size: 16px; border-radius: 4px; border: none; cursor: pointer;}
    .btn-primary:hover { background-color: #0b5ed7; }
    
    .container { max-width: 1000px; margin: 40px auto; padding: 0 20px; display: flex; gap: 20px; flex-wrap: wrap; }
    .col { flex: 1; min-width: 300px; }
    
    .card { background: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); padding: 20px; }
    .card-title { margin-bottom: 20px; font-size: 20px; color: #333; border-bottom: 2px solid #f1f1f1; padding-bottom: 10px;}
    
    .form-group { margin-bottom: 15px; }
    .form-group label { display: block; margin-bottom: 8px; font-weight: 600; font-size: 14px; color: #555; }
    .form-control { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px; font-family: inherit;}
    .form-control:focus { border-color: #0d6efd; outline: none; }
    
    table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; }
    th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #e0e0e0; font-size: 14px;}
    th { background-color: #343a40; color: white; font-weight: 500; }
    tr:hover { background-color: #f8f9fa; }
    
    .badge { padding: 5px 10px; border-radius: 20px; font-size: 12px; font-weight: bold; color: white; display: inline-block;}
    .bg-open { background-color: #dc3545; }
    .bg-progress { background-color: #ffc107; color: #000; }
    .bg-resolved { background-color: #198754; }
    
    /* Alert Messages */
    .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; font-weight: bold; font-size: 14px; }
    .alert-success { background-color: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
    .alert-danger { background-color: #f8d7da; color: #842029; border: 1px solid #f5c2c7; }
</style>
</head><body>

<nav class="navbar">
  <div>
    <a class="nav-brand" href="customer_dashboard.jsp">My ISP</a>
    <a href="customer_dashboard.jsp">My Profile</a>
    <a href="customer_bills.jsp">My Bills</a>
    <a href="customer_complaints.jsp">Support</a>
  </div>
  <div class="nav-right">
    <span style="margin-right: 20px;">Welcome, <b><%=session.getAttribute("username")%></b></span>
    <a href="logout" class="btn btn-light">Logout</a>
  </div>
</nav>

<div class="container">
  
  <%-- সাকসেস বা এরর মেসেজ দেখানোর লজিক --%>
  <% if (request.getParameter("msg") != null) { 
       String msgType = request.getParameter("type") != null ? request.getParameter("type") : "success";
       String alertClass = "danger".equals(msgType) ? "alert-danger" : "alert-success";
  %>
      <div class="alert <%=alertClass%>" style="width: 100%;">
          <%= request.getParameter("msg") %>
      </div>
  <% } %>

  <!-- Left Column: Submit Form -->
  <div class="col">
    <div class="card">
      <h3 class="card-title">Submit a Complaint</h3>
      <form method="post" action="complaints">
        <input type="hidden" name="action" value="submit">
        
        <div class="form-group">
            <label>Subject</label>
            <input name="subject" class="form-control" required placeholder="e.g. Internet is slow, No connection">
        </div>
        
        <div class="form-group">
            <label>Description (Details)</label>
            <textarea name="description" class="form-control" rows="4" required placeholder="Describe your issue briefly..."></textarea>
        </div>
        
        <button type="submit" class="btn-primary">Submit Complaint</button>
      </form>
    </div>
  </div>

  <!-- Right Column: My Complaints List -->
  <div class="col">
    <div class="card" style="padding: 0; overflow: hidden;">
      <div style="padding: 20px; border-bottom: 1px solid #eee;">
          <h3 style="margin: 0; font-size: 20px; color: #333;">My Complaints</h3>
      </div>
      <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Subject</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
        <% 
          String q = "SELECT CO.COMPLAINT_ID, CO.SUBJECT, CO.STATUS " +
                     "FROM COMPLAINT CO " +
                     "JOIN CUSTOMER C ON CO.CUSTOMER_ID = C.CUSTOMER_ID " +
                     "WHERE C.USER_ID = ? " +
                     "ORDER BY CO.COMPLAINT_ID DESC";
                     
          try(Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(q)){
              ps.setInt(1, uid); 
              ResultSet r = ps.executeQuery();
              boolean hasData = false;
              
              while(r.next()){ 
                  hasData = true; 
                  String status = r.getString(3);
                  String badgeClass = "OPEN".equals(status) ? "bg-open" : ("IN_PROGRESS".equals(status) ? "bg-progress" : "bg-resolved");
        %>
            <tr>
                <td style="font-weight: bold; color: #666;">#<%=r.getInt(1)%></td>
                <td><%=r.getString(2)%></td>
                <td><span class="badge <%=badgeClass%>"><%=status%></span></td>
            </tr>
        <% } 
           if(!hasData) { %>
            <tr>
                <td colspan="3" style="text-align: center; color: #999; padding: 30px;">No complaints submitted yet.</td>
            </tr>
        <% } 
          } catch(Exception e) { %>
            <tr>
                <td colspan="3" style="text-align: center; color: #dc3545;">Error loading complaints: <%= e.getMessage() %></td>
            </tr>
        <% } %>
        </tbody>
      </table>
    </div>
  </div>
  
</div>

<script>
  // Navbar Active Link Highlighter
  document.addEventListener("DOMContentLoaded", function() {
    const currentPath = window.location.pathname;
    document.querySelectorAll('.navbar a').forEach(link => {
      if (currentPath.includes(link.getAttribute('href')) && !link.classList.contains('nav-brand') && !link.classList.contains('btn-light')) {
          link.classList.add('active');
      }
    });
  });
</script>
</body></html>