<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection,java.text.DecimalFormat"%>
<% if (session.getAttribute("role")==null || !"CUSTOMER".equals(session.getAttribute("role"))) { response.sendRedirect("login.jsp"); return; } 
   int uid = (Integer) session.getAttribute("userId"); DecimalFormat df = new DecimalFormat("#,##0.00"); %>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Customer Dashboard</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
    body { background-color: #f4f7f6; color: #333; }
    .navbar { display: flex; align-items: center; justify-content: space-between; padding: 15px 30px; background-color: #212529; color: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .navbar a { color: white; text-decoration: none; margin-right: 20px; font-size: 15px; transition: 0.3s; }
    .navbar a:hover { opacity: 0.8; } .navbar a.active { font-weight: bold; border-bottom: 3px solid white; padding-bottom: 5px; }
    .nav-brand { font-size: 20px; font-weight: bold; margin-right: 30px; } .nav-right { display: flex; align-items: center; }
    .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 14px; display: inline-block; }
    .btn-light { background-color: white; color: #212529 !important; font-weight: bold; }
    .btn-pay { background-color: #fff; color: #dc3545; font-weight: bold; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; margin-top: 10px;}
    .btn-pay:hover { background-color: #f8f9fa; }
    .container { max-width: 800px; margin: 40px auto; padding: 0 20px; }
    .card { background: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); overflow: hidden; margin-bottom: 20px;}
    .card-header { background-color: #212529; color: white; padding: 15px 20px; font-size: 18px; font-weight: bold; display: flex; justify-content: space-between; align-items: center;}
    .card-body { padding: 20px; }
    .badge { padding: 5px 10px; border-radius: 4px; font-size: 14px; font-weight: bold; color: white; background-color: #198754; }
    .pkg-row { border-bottom: 1px solid #eee; padding: 15px 0; display: flex; justify-content: space-between; align-items: center;}
    .pkg-row:last-child { border-bottom: none; }
    .pkg-name { font-size: 16px; font-weight: bold; color: #0d6efd; }
    .pkg-detail { font-size: 13px; color: #666; margin-top: 5px; }
    .due-box { background: #dc3545; color: white; padding: 20px; border-radius: 8px; text-align: center; box-shadow: 0 4px 10px rgba(220, 53, 69, 0.3); margin-bottom: 20px;}
    .due-box h3 { font-size: 16px; opacity: 0.9; margin-bottom: 10px; font-weight: normal;} .due-box h1 { font-size: 36px; margin: 0; }
    .clear-box { background: #198754; color: white; padding: 20px; border-radius: 8px; text-align: center; box-shadow: 0 4px 10px rgba(25, 135, 84, 0.3); margin-bottom: 20px;}
    .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; background-color: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
    
    /* Zone Status Box Styles */
    .zone-box { padding: 15px 20px; border-radius: 8px; margin-bottom: 20px; display: flex; align-items: center; gap: 15px; border-left: 6px solid #ccc;}
    .zone-box-active { background-color: #d1e7dd; color: #0f5132; border-left-color: #198754; }
    .zone-box-maintenance { background-color: #fff3cd; color: #856404; border-left-color: #ffc107; }
    .zone-box-offline { background-color: #f8d7da; color: #842029; border-left-color: #dc3545; }
    .zone-icon { font-size: 28px; }
    .zone-title { font-size: 16px; font-weight: bold; margin-bottom: 3px;}
    .zone-desc { font-size: 14px; }

    /* Modal CSS */
    .modal { display: none; position: fixed; z-index: 1; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.5); }
    .modal-content { background-color: #fefefe; margin: 10% auto; padding: 20px; border: 1px solid #888; width: 400px; border-radius: 8px; color: #333; text-align: left;}
    .modal-content input, .modal-content select { width: 100%; padding: 8px; margin: 8px 0; border: 1px solid #ccc; border-radius: 4px; }
    .close { color: #aaa; float: right; font-size: 28px; font-weight: bold; cursor: pointer; }
</style>
</head><body>
<nav class="navbar"><div><a class="nav-brand" href="customer_dashboard.jsp">My ISP</a><a href="customer_dashboard.jsp">My Profile</a><a href="customer_bills.jsp">My Bills</a><a href="customer_complaints.jsp">Support</a></div>
<div class="nav-right"><span style="margin-right: 20px;">Welcome, <b><%=session.getAttribute("username")%></b></span><a href="logout" class="btn btn-light">Logout</a></div></nav>
<div class="container">
  <h2 style="margin-bottom: 20px;">Welcome to Your Dashboard</h2>
  
  <% 
    double totalDue = 0;
    String dueQuery = "SELECT NVL(SUM(B.AMOUNT - NVL((SELECT SUM(AMOUNT_PAID) FROM PAYMENT WHERE BILL_ID=B.BILL_ID),0)),0) FROM BILL B JOIN SUBSCRIPTION S ON B.SUBSCRIPTION_ID = S.SUBSCRIPTION_ID JOIN CUSTOMER C ON S.CUSTOMER_ID = C.CUSTOMER_ID WHERE C.USER_ID = ? AND B.STATUS IN ('UNPAID', 'PARTIAL')";
    try(Connection c=DBConnection.getConnection(); PreparedStatement ps= c.prepareStatement(dueQuery)){
        ps.setInt(1, uid); ResultSet rsDue = ps.executeQuery(); if(rsDue.next()) totalDue = rsDue.getDouble(1);
    } catch(Exception e) {}

    String payBkash = "", payNagad = "";
    try (Connection c = DBConnection.getConnection(); Statement st = c.createStatement()) {
        ResultSet rs = st.executeQuery("SELECT SETTING_KEY, SETTING_VALUE FROM SYSTEM_SETTINGS WHERE SETTING_KEY IN ('BKASH_NUMBER', 'NAGAD_NUMBER')");
        while (rs.next()) {
            if ("BKASH_NUMBER".equals(rs.getString(1))) payBkash = rs.getString(2);
            if ("NAGAD_NUMBER".equals(rs.getString(1))) payNagad = rs.getString(2);
        }
    } catch (Exception e) {}

    // কাস্টমারের এরিয়া এবং জোন স্ট্যাটাস চেক করা
    String custArea = "Not Assigned";
    String zoneStatus = "ACTIVE"; // ডিফল্ট স্ট্যাটাস
    String zoneReason = "Your area is operating normally.";
    
    try(Connection c = DBConnection.getConnection()) {
        PreparedStatement psArea = c.prepareStatement("SELECT AREA FROM CUSTOMER WHERE USER_ID=?");
        psArea.setInt(1, uid);
        ResultSet rsArea = psArea.executeQuery();
        if(rsArea.next() && rsArea.getString(1) != null && !rsArea.getString(1).trim().isEmpty()) {
            custArea = rsArea.getString(1).trim();
            
            // Case-insensitive এবং Space-insensitive ম্যাচিং (UPPER & TRIM ব্যবহার করে)
            PreparedStatement psZone = c.prepareStatement("SELECT STATUS, REASON FROM ZONE_STATUS WHERE UPPER(TRIM(AREA_NAME)) = UPPER(TRIM(?))");
            psZone.setString(1, custArea);
            ResultSet rsZone = psZone.executeQuery();
            if(rsZone.next()) {
                zoneStatus = rsZone.getString(1);
                String rsn = rsZone.getString(2);
                if(rsn != null && !rsn.trim().isEmpty()) {
                    zoneReason = rsn;
                } else {
                    zoneReason = "No specific reason provided.";
                }
            }
        }
    } catch(Exception e) {
        zoneReason = "Error checking status.";
    }
    
    // স্ট্যাটাস অনুযায়ী CSS ক্লাস এবং আইকন সেট করা
    String boxClass = "zone-box-active";
    String icon = "🟢";
    String statusText = "Internet is ACTIVE in your area";
    
    if("MAINTENANCE".equals(zoneStatus)) {
        boxClass = "zone-box-maintenance";
        icon = "🟡";
        statusText = "Maintenance in progress in your area";
    } else if("OFFLINE".equals(zoneStatus)) {
        boxClass = "zone-box-offline";
        icon = "🔴";
        statusText = "Internet is OFFLINE in your area";
    }
  %>

  <!-- জোন স্ট্যাটাস বক্স (সবসময় দেখাবে) -->
  <div class="zone-box <%=boxClass%>">
      <div class="zone-icon"><%=icon%></div>
      <div>
          <div class="zone-title"><%=statusText%> (<%=custArea%>)</div>
          <div class="zone-desc">Details: <%=zoneReason%></div>
      </div>
  </div>

  <% if (totalDue > 0) { %>
      <div class="due-box">
          <h3>Total Outstanding Due</h3>
          <h1><%= df.format(totalDue) %> Tk</h1>
          <div style="background: rgba(255,255,255,0.2); padding: 15px; border-radius: 6px; margin-top: 15px; text-align: left; font-size: 15px;">
              <p style="margin-bottom: 8px; font-weight: bold;">💳 Payment Numbers:</p>
              <p style="margin-bottom: 5px;">বিকাশ (bKash): <b><%= (payBkash != null && !payBkash.isEmpty()) ? payBkash : "Not Set" %></b></p>
              <p style="margin-bottom: 5px;">নগদ (Nagad): <b><%= (payNagad != null && !payNagad.isEmpty()) ? payNagad : "Not Set" %></b></p>
              <p style="font-size: 13px; font-style: italic; opacity: 0.9;">* Send Money করার পর নিচের বাটনে ক্লিক করে TrxID সাবমিট করুন।</p>
          </div>
          <button class="btn-pay" onclick="document.getElementById('paymentModal').style.display='block'">Pay Now & Submit TrxID</button>
      </div>
  <% } else { %>
      <div class="clear-box"><h3>All Dues Cleared</h3><p style="font-size:15px; margin-top:5px;">Thank you! You have no outstanding bills.</p></div>
  <% } %>

  <div class="card">
    <div class="card-header"><span>My Active Packages</span><a href="customer_bills.jsp" style="font-size:12px; background:rgba(255,255,255,0.2); padding:5px 10px; border-radius:4px; color:white; text-decoration:none;">View Bills</a></div>
    <div class="card-body">
    <% String q = "SELECT P.PACKAGE_NAME, P.SPEED_MBPS, P.MONTHLY_PRICE, S.STATUS, C.AREA FROM CUSTOMER C JOIN SUBSCRIPTION S ON C.CUSTOMER_ID = S.CUSTOMER_ID JOIN PACKAGE P ON S.PACKAGE_ID = P.PACKAGE_ID WHERE C.USER_ID = ? AND S.STATUS = 'ACTIVE'";
      try(Connection c=DBConnection.getConnection(); PreparedStatement ps=c.prepareStatement(q)){
          ps.setInt(1, uid); ResultSet r=ps.executeQuery(); boolean hasPkg = false;
          while(r.next()){ hasPkg = true; %>
            <div class="pkg-row"><div><div class="pkg-name"><%=r.getString("PACKAGE_NAME")%> (<%=r.getInt("SPEED_MBPS")%> Mbps)</div><div class="pkg-detail">Area: <%=r.getString("AREA")%> | Price: <%=r.getDouble("MONTHLY_PRICE")%> Tk/month</div></div><span class="badge">ACTIVE</span></div>
      <% } if(!hasPkg) { %><div class="alert">No active packages found. Please contact support.</div><% } 
      } catch(Exception e){%><div class="alert" style="background:#f8d7da;color:#842029;"><%=e.getMessage()%></div><%}%>
    </div>
  </div>
</div>

<!-- Payment Modal (আগের মতোই আছে) -->
<div id="paymentModal" class="modal">
  <div class="modal-content">
    <span class="close" onclick="document.getElementById('paymentModal').style.display='none'">&times;</span>
    <h3 style="margin-bottom: 15px; color: #0d6efd;">Submit Payment Info</h3>
    <form method="post" action="SubmitPaymentRequestServlet">
        <label>Select Unpaid Bill</label>
        <select name="billId" required>
            <option value="">-- Select Bill --</option>
            <% 
            String billQ = "SELECT B.BILL_ID, B.BILL_MONTH, B.AMOUNT FROM BILL B JOIN SUBSCRIPTION S ON B.SUBSCRIPTION_ID=S.SUBSCRIPTION_ID JOIN CUSTOMER C ON S.CUSTOMER_ID=C.CUSTOMER_ID WHERE C.USER_ID=? AND B.STATUS IN ('UNPAID','PARTIAL')";
            try(Connection c=DBConnection.getConnection(); PreparedStatement ps=c.prepareStatement(billQ)){
                ps.setInt(1, uid); ResultSet r = ps.executeQuery();
                while(r.next()) { %>
                    <option value="<%=r.getInt(1)%>"><%=r.getString(2)%> (Due: <%=r.getDouble(3)%> Tk)</option>
                <% } } catch(Exception e){} %>
        </select>
        <label>Payment Method</label>
        <select name="method" required>
            <option value="BKASH">bKash</option>
            <option value="NAGAD">Nagad</option>
        </select>
        <label>Amount Sent (Tk)</label>
        <input type="number" step="0.01" name="amount" required>
        <label>Transaction ID (TrxID)</label>
        <input type="text" name="trxId" required placeholder="e.g. 9H7A6B5C">
        <button type="submit" style="background: #198754; color: white; width: 100%; padding: 10px; margin-top: 15px; border: none; border-radius: 4px; font-weight: bold; cursor: pointer;">Submit Payment</button>
    </form>
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