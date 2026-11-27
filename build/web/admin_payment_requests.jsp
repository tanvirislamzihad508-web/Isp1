<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<% if (session.getAttribute("role")==null || (!"ADMIN".equals(session.getAttribute("role")) && !"STAFF".equals(session.getAttribute("role")))) { response.sendRedirect("login.jsp"); return; } 
   String role = (String) session.getAttribute("role"); String navColor = "STAFF".equals(role) ? "#198754" : "#0d6efd";
%>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Payment Requests</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
    body { background-color: #f4f7f6; color: #333; }
    .navbar { display: flex; align-items: center; justify-content: space-between; padding: 15px 30px; background-color: <%=navColor%>; color: white; }
    .navbar a { color: white; text-decoration: none; margin-right: 20px; font-size: 15px; }
    .container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }
    table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
    th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #e0e0e0; }
    th { background-color: #343a40; color: white; }
    .btn-approve { background-color: #198754; color: white; padding: 6px 12px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-weight:bold;}
    .btn-reject { background-color: #dc3545; color: white; padding: 6px 12px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-weight:bold;}
</style>
</head><body>
<nav class="navbar">
  <div>
    <a href="<%= "STAFF".equals(role) ? "staff_dashboard.jsp" : "admin_dashboard.jsp" %>" style="font-size: 20px; font-weight: bold;"><%= "STAFF".equals(role) ? "ISP Staff" : "ISP Admin" %></a>
    <a href="<%= "STAFF".equals(role) ? "staff_dashboard.jsp" : "admin_dashboard.jsp" %>">Dashboard</a>
    <a href="admin_payment_requests.jsp" style="font-weight:bold; text-decoration:underline;">Payment Requests</a>
  </div>
  <div><a href="logout" style="background:white; color:<%=navColor%>; padding:5px 10px; border-radius:4px; font-weight:bold;">Logout</a></div>
</nav>
<div class="container">
    <h2 style="margin-bottom: 20px;">Pending Payment Requests</h2>
    <% if("success".equals(request.getParameter("msg"))) { %><div style="padding:15px; background:#d1e7dd; color:#0f5132; margin-bottom:20px; border-radius:4px; font-weight:bold;">✅ Payment Approved Successfully! Bill is now PAID.</div><% } %>
    
    <table>
        <thead><tr><th>Req ID</th><th>Customer</th><th>Bill Month</th><th>Amount</th><th>Method</th><th>TrxID</th><th>Action</th></tr></thead>
        <tbody>
        <% 
        String q = "SELECT R.REQ_ID, C.NAME, C.PHONE, B.BILL_MONTH, R.AMOUNT, R.METHOD, R.TRX_ID, R.BILL_ID FROM PAYMENT_REQUESTS R JOIN CUSTOMER C ON R.CUSTOMER_ID=C.CUSTOMER_ID JOIN BILL B ON R.BILL_ID=B.BILL_ID WHERE R.STATUS='PENDING' ORDER BY R.REQ_ID DESC";
        try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement(); ResultSet rs=st.executeQuery(q)){
            boolean hasData = false;
            while(rs.next()){ hasData = true; %>
            <tr>
                <td><%=rs.getInt("REQ_ID")%></td>
                <td><b><%=rs.getString("NAME")%></b><br><small><%=rs.getString("PHONE")%></small></td>
                <td><%=rs.getString("BILL_MONTH")%></td>
                <td style="color:#198754; font-weight:bold;"><%=rs.getDouble("AMOUNT")%> Tk</td>
                <td><%=rs.getString("METHOD")%></td>
                <td><b style="color:#0d6efd;"><%=rs.getString("TRX_ID")%></b></td>
                <td>
                    <form method="post" action="ApprovePaymentServlet" style="display:inline;">
                        <input type="hidden" name="reqId" value="<%=rs.getInt("REQ_ID")%>">
                        <input type="hidden" name="billId" value="<%=rs.getInt("BILL_ID")%>">
                        <input type="hidden" name="amount" value="<%=rs.getDouble("AMOUNT")%>">
                        <input type="hidden" name="method" value="<%=rs.getString("METHOD")%>">
                        <button type="submit" class="btn-approve">Approve</button>
                    </form>
                    <a href="RejectPaymentServlet?reqId=<%=rs.getInt("REQ_ID")%>" class="btn-reject" onclick="return confirm('Are you sure you want to reject this payment?')">Reject</a>
                </td>
            </tr>
        <% } if(!hasData) { %><tr><td colspan="7" style="text-align:center; color:#999; padding:20px;">No pending requests found.</td></tr><% } 
        } catch(Exception e) { out.print("<tr><td colspan='7' style='color:red;'>Error: " + e.getMessage() + "</td></tr>"); } %>
        </tbody>
    </table>
</div>
</body></html>