<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<% if (session.getAttribute("role")==null || !"ADMIN".equals(session.getAttribute("role"))) { response.sendRedirect("login.jsp"); return; } %>

<%
    String msg = "";
    // ফর্ম সাবমিট হলে ডাটাবেস আপডেট হবে
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String bkash = request.getParameter("bkash");
        String nagad = request.getParameter("nagad");
        try (Connection c = DBConnection.getConnection()) {
            PreparedStatement ps1 = c.prepareStatement("UPDATE SYSTEM_SETTINGS SET SETTING_VALUE=? WHERE SETTING_KEY='BKASH_NUMBER'");
            ps1.setString(1, bkash); ps1.executeUpdate();
            PreparedStatement ps2 = c.prepareStatement("UPDATE SYSTEM_SETTINGS SET SETTING_VALUE=? WHERE SETTING_KEY='NAGAD_NUMBER'");
            ps2.setString(1, nagad); ps2.executeUpdate();
            c.commit();
            msg = "Payment numbers updated successfully!";
        } catch (Exception e) { msg = "Error: " + e.getMessage(); }
    }

    // বর্তমান নাম্বারগুলো ডাটাবেস থেকে রিড করা
    String currentBkash = "", currentNagad = "";
    try (Connection c = DBConnection.getConnection(); Statement st = c.createStatement()) {
        ResultSet rs = st.executeQuery("SELECT SETTING_KEY, SETTING_VALUE FROM SYSTEM_SETTINGS WHERE SETTING_KEY IN ('BKASH_NUMBER', 'NAGAD_NUMBER')");
        while (rs.next()) {
            if ("BKASH_NUMBER".equals(rs.getString(1))) currentBkash = rs.getString(2);
            if ("NAGAD_NUMBER".equals(rs.getString(1))) currentNagad = rs.getString(2);
        }
    } catch (Exception e) {}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Payment Settings</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
        body { background-color: #f4f7f6; color: #333; }
        .navbar { display: flex; align-items: center; justify-content: space-between; padding: 15px 30px; background-color: #0d6efd; color: white; }
        .navbar a { color: white; text-decoration: none; margin-right: 20px; font-size: 15px; }
        .nav-brand { font-size: 20px; font-weight: bold; margin-right: 30px; }
        .container { max-width: 600px; margin: 50px auto; padding: 0 20px; }
        .card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: bold; color: #555; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 15px; }
        .btn { padding: 12px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; width: 100%; font-weight: bold; background: #198754; color: white;}
        .alert { padding: 15px; border-radius: 4px; margin-bottom: 20px; background-color: #d1e7dd; color: #0f5132; }
    </style>
</head>
<body>
<nav class="navbar">
    <div>
        <a class="nav-brand" href="admin_dashboard.jsp">ISP Admin</a>
        <a href="admin_dashboard.jsp">Dashboard</a>
    </div>
    <div><a href="logout" style="background:white; color:#0d6efd; padding:5px 10px; border-radius:4px; font-weight:bold;">Logout</a></div>
</nav>
<div class="container">
    <div class="card">
        <h2 style="margin-bottom: 20px;">Payment Numbers Settings</h2>
        <% if (!msg.isEmpty()) { %><div class="alert"><%= msg %></div><% } %>
        <form method="POST">
            <div class="form-group">
                <label>bKash Number (Personal/Agent):</label>
                <input type="text" name="bkash" class="form-control" value="<%= currentBkash %>" required>
            </div>
            <div class="form-group">
                <label>Nagad Number (Personal/Agent):</label>
                <input type="text" name="nagad" class="form-control" value="<%= currentNagad %>" required>
            </div>
            <button type="submit" class="btn">Update Numbers</button>
        </form>
    </div>
</div>
</body>
</html>