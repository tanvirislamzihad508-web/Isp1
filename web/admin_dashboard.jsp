<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection,java.text.DecimalFormat,java.text.SimpleDateFormat"%>
<% if (session.getAttribute("role")==null || !"ADMIN".equals(session.getAttribute("role"))) { response.sendRedirect("login.jsp"); return; } 
   DecimalFormat df = new DecimalFormat("#,##0.00");
%>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Admin Dashboard</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
    body { background-color: #f4f7f6; color: #333; }
    .navbar { display: flex; align-items: center; justify-content: space-between; padding: 15px 30px; background-color: #0d6efd; color: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .navbar a { color: white; text-decoration: none; margin-right: 20px; font-size: 15px; transition: 0.3s; }
    .navbar a:hover { opacity: 0.8; } .navbar a.active { font-weight: bold; border-bottom: 3px solid white; padding-bottom: 5px; }
    .nav-brand { font-size: 20px; font-weight: bold; margin-right: 30px; } .nav-right { display: flex; align-items: center; }
    .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 14px; display: inline-block; }
    .btn-light { background-color: white; color: #0d6efd !important; font-weight: bold; }
    .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }
    .row { display: flex; gap: 20px; flex-wrap: wrap; margin-bottom: 30px; }
    .card { flex: 1; min-width: 220px; padding: 20px; border-radius: 8px; color: white; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
    .bg-info { background: linear-gradient(135deg, #0dcaf0, #0aa2c0); color: #fff; } .bg-success { background: linear-gradient(135deg, #198754, #146c43); }
    .bg-warning { background: linear-gradient(135deg, #ffc107, #ffca2c); color: #000; } .bg-danger { background: linear-gradient(135deg, #dc3545, #b02a37); }
    .card h6 { font-size: 14px; margin-bottom: 10px; font-weight: 600; text-transform: uppercase;} .card h2 { font-size: 28px; margin: 0; font-weight: bold;}
    .dashboard-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; }
    @media (max-width: 900px) { .dashboard-grid { grid-template-columns: 1fr; } }
    .panel { background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); overflow: hidden; margin-bottom: 20px;}
    .panel-header { padding: 15px 20px; background-color: #f8f9fa; border-bottom: 1px solid #eee; font-weight: bold; color: #333; display: flex; justify-content: space-between; align-items: center;}
    .panel-body { padding: 20px; }
    .table-sm { width: 100%; border-collapse: collapse; } .table-sm th, .table-sm td { padding: 10px; text-align: left; border-bottom: 1px solid #eee; font-size: 14px; }
    .table-sm th { color: #666; font-weight: 600; } .table-sm tr:last-child td { border-bottom: none; }
    .badge { padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; color: white; }
    .bg-badge-success { background-color: #198754; } .bg-badge-danger { background-color: #dc3545; }
    .quick-actions { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
    .action-btn { display: flex; align-items: center; justify-content: center; padding: 15px; border-radius: 6px; text-decoration: none; font-weight: bold; font-size: 14px; color: white; transition: 0.2s; border: 1px solid transparent;}
    .action-btn:hover { transform: scale(1.02); }
    .act-blue { background-color: #e3f2fd; color: #0d6efd; } .act-green { background-color: #e8f5e9; color: #198754; }
    .act-yellow { background-color: #fff8e1; color: #d39e00; } .act-red { background-color: #ffebee; color: #dc3545; }
    .zone-item { display: flex; flex-direction: column; padding: 12px 0; border-bottom: 1px solid #eee; font-size: 14px; }
    .zone-item:last-child { border-bottom: none; } .zone-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;}
    .zone-name { font-weight: bold; color: #333; display: flex; align-items: center; gap: 8px;}
    .zone-dot { width: 10px; height: 10px; border-radius: 50%; display: inline-block; }
    .dot-active { background-color: #198754; box-shadow: 0 0 5px #198754; } .dot-maintenance { background-color: #ffc107; box-shadow: 0 0 5px #ffc107; } .dot-offline { background-color: #dc3545; box-shadow: 0 0 5px #dc3545; }
    .zone-status { font-size: 11px; font-weight: bold; padding: 3px 8px; border-radius: 12px; }
    .status-active { background-color: #d1e7dd; color: #0f5132; } .status-maintenance { background-color: #fff3cd; color: #856404; } .status-offline { background-color: #f8d7da; color: #842029; }
    .zone-reason { font-size: 12px; color: #666; font-style: italic; margin-left: 18px;}
    .alert-box { background-color: #fff3cd; color: #856404; border: 1px solid #ffeeba; padding: 15px; border-radius: 6px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; }
</style>
</head><body>
<nav class="navbar">
  <div>
    <a class="nav-brand" href="admin_dashboard.jsp">ISP Admin</a>
    <a href="packages.jsp">Packages</a>
    <a href="customers.jsp">Customers</a>
    <a href="bills.jsp">Bills</a>
    <a href="staff_payment.jsp">Payments</a>
    <a href="complaints.jsp">Complaints</a>
    
    <!-- নতুন লিংকগুলো -->
    <a href="admin_payment_requests.jsp" style="color: #ffd700;">⚙️ Payment Requests</a>
    <a href="staff_management.jsp" style="color: #ffd700;">👥 Manage Staff</a>
    <a href="admin_activity_log.jsp" style="color: #ffd700;">📜 Activity Logs</a>
  </div>
  <div class="nav-right">
    <span style="margin-right: 20px;">Welcome, <b><%=session.getAttribute("username")%></b></span>
    <a href="logout" class="btn btn-light">Logout</a>
  </div>
</nav>
<div class="container">

  <%-- পেন্ডিং রিকোয়েস্ট অ্যালার্ট --%>
  <% 
    int pendingReqs = 0;
    try(Connection c = DBConnection.getConnection(); Statement st = c.createStatement(); 
        ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM PAYMENT_REQUESTS WHERE STATUS='PENDING'")) {
        if(rs.next()) pendingReqs = rs.getInt(1);
    } catch(Exception e) {}
    if (pendingReqs > 0) { 
  %>
    <div class="alert-box">
        <div><strong>🔔 নতুন পেমেন্ট রিকোয়েস্ট!</strong> আপনার কাছে <b><%= pendingReqs %></b> টি পেন্ডিং পেমেন্ট রিকোয়েস্ট জমা আছে।</div>
        <a href="admin_payment_requests.jsp" style="background-color: #ffc107; color: #000; padding: 8px 15px; text-decoration: none; border-radius: 4px; font-weight: bold;">Check Now</a>
    </div>
  <% } %>

  <div class="row">
    <% int custCount=0,pkgCount=0,dueCount=0; double monthlyRevenue=0;
      try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement()){
        ResultSet r=st.executeQuery("SELECT COUNT(*) FROM CUSTOMER"); if(r.next()) custCount=r.getInt(1);
        r=st.executeQuery("SELECT COUNT(*) FROM PACKAGE"); if(r.next()) pkgCount=r.getInt(1);
        r=st.executeQuery("SELECT COUNT(*) FROM BILL WHERE STATUS IN ('UNPAID','PARTIAL')"); if(r.next()) dueCount=r.getInt(1);
        r=st.executeQuery("SELECT NVL(SUM(AMOUNT_PAID),0) FROM PAYMENT WHERE TO_CHAR(PAYMENT_DATE, 'YYYY-MM') = TO_CHAR(SYSDATE, 'YYYY-MM')"); 
        if(r.next()) monthlyRevenue=r.getDouble(1);
      } catch(Exception e) { out.print(e.getMessage()); } %>
    <div class="card bg-info"><h6>Total Customers</h6><h2><%=custCount%></h2></div>
    <div class="card bg-success"><h6>Monthly Revenue</h6><h2><%=df.format(monthlyRevenue)%> Tk</h2></div>
    <div class="card bg-warning"><h6>Total Packages</h6><h2><%=pkgCount%></h2></div>
    <div class="card bg-danger"><h6>Due Bills</h6><h2><%=dueCount%></h2></div>
  </div>
  
  <div class="dashboard-grid">
    <div>
        <div class="panel">
            <div class="panel-header"><span>Recent Payments</span><a href="staff_payment.jsp" style="font-size: 12px; color: #0d6efd; text-decoration: none;">View All</a></div>
            <div class="panel-body" style="padding: 0;">
                <table class="table-sm">
                    <thead><tr><th>Customer</th><th>Amount</th><th>Method</th><th>Date</th></tr></thead>
                    <tbody>
                        <% try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement();
                              ResultSet r=st.executeQuery("SELECT * FROM (SELECT C.NAME, P.AMOUNT_PAID, P.METHOD, P.PAYMENT_DATE FROM PAYMENT P JOIN BILL B ON P.BILL_ID=B.BILL_ID JOIN SUBSCRIPTION S ON B.SUBSCRIPTION_ID=S.SUBSCRIPTION_ID JOIN CUSTOMER C ON S.CUSTOMER_ID=C.CUSTOMER_ID ORDER BY P.PAYMENT_DATE DESC) WHERE ROWNUM <= 5")){
                            boolean hasData = false;
                            while(r.next()){ hasData = true; %>
                            <tr><td><b><%=r.getString(1)%></b></td><td style="color: #198754; font-weight: bold;">+ <%=r.getDouble(2)%> Tk</td>
                                <td><span class="badge" style="background:#6c757d;"><%=r.getString(3)%></span></td><td style="color: #666;"><%=new SimpleDateFormat("dd MMM").format(r.getDate(4))%></td></tr>
                        <% } if(!hasData){ %><tr><td colspan="4" style="text-align:center; color:#999;">No payments recorded yet.</td></tr><% } 
                        } catch(Exception e) {} %>
                    </tbody>
                </table>
            </div>
        </div>
        <div class="panel">
            <div class="panel-header"><span>Top Due Customers</span><a href="bills.jsp" style="font-size: 12px; color: #0d6efd; text-decoration: none;">View Due List</a></div>
            <div class="panel-body" style="padding: 0;">
                <table class="table-sm">
                    <thead><tr><th>Customer</th><th>Month</th><th>Due Amount</th><th>Status</th></tr></thead>
                    <tbody>
                        <% try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement();
                              ResultSet r=st.executeQuery("SELECT * FROM (SELECT C.NAME, B.BILL_MONTH, B.AMOUNT, B.STATUS FROM BILL B JOIN SUBSCRIPTION S ON B.SUBSCRIPTION_ID=S.SUBSCRIPTION_ID JOIN CUSTOMER C ON S.CUSTOMER_ID=C.CUSTOMER_ID WHERE B.STATUS IN ('UNPAID','PARTIAL') ORDER BY B.AMOUNT DESC) WHERE ROWNUM <= 5")){
                            boolean hasData = false;
                            while(r.next()){ hasData = true; %>
                            <tr><td><b><%=r.getString(1)%></b></td><td><%=r.getString(2)%></td>
                                <td style="color: #dc3545; font-weight: bold;"><%=r.getDouble(3)%> Tk</td>
                                <td><span class="badge <%= "UNPAID".equals(r.getString(4)) ? "bg-badge-danger" : "bg-warning text-dark" %>"><%=r.getString(4)%></span></td></tr>
                        <% } if(!hasData){ %><tr><td colspan="4" style="text-align:center; color:#198754;">Excellent! No due bills found.</td></tr><% } 
                        } catch(Exception e) {} %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <div>
        <div class="panel">
            <div class="panel-header">Quick Actions</div>
            <div class="panel-body"><div class="quick-actions">
                <a href="customer_form.jsp" class="action-btn act-blue">+ Customer</a><a href="package_form.jsp" class="action-btn act-green">+ Package</a>
                <a href="bills.jsp" class="action-btn act-yellow">Generate Bill</a><a href="staff_payment.jsp" class="action-btn act-red">Add Payment</a>
            </div></div>
        </div>
        <div class="panel">
            <div class="panel-header"><span>WiFi Zone Status</span><a href="zone_management.jsp" style="font-size: 12px; color: #0d6efd; text-decoration: none;">Manage Zones</a></div>
            <div class="panel-body" style="padding: 10px 20px;">
                <% try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement(); ResultSet r=st.executeQuery("SELECT * FROM ZONE_STATUS ORDER BY AREA_NAME")){
                       boolean hasZones = false;
                       while(r.next()){ hasZones = true; String status = r.getString("STATUS");
                           String dotClass = "dot-active"; String badgeClass = "status-active";
                           if("MAINTENANCE".equals(status)) { dotClass = "dot-maintenance"; badgeClass = "status-maintenance"; }
                           else if("OFFLINE".equals(status)) { dotClass = "dot-offline"; badgeClass = "status-offline"; } %>
                <div class="zone-item">
                    <div class="zone-top"><div class="zone-name"><span class="zone-dot <%=dotClass%>"></span> <%= r.getString("AREA_NAME") %></div><span class="zone-status <%=badgeClass%>"><%= status %></span></div>
                    <% if(r.getString("REASON") != null) { %><div class="zone-reason">Reason: <%= r.getString("REASON") %></div><% } %>
                </div>
                <% } if(!hasZones) { %><div style="text-align:center; padding: 20px 0; color:#999; font-size: 14px;">No zones found.</div><% } 
                   } catch(Exception e) { out.print("Error: " + e.getMessage()); } %>
            </div>
        </div>
    </div>
  </div>
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