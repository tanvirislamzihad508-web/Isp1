<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<%
    if (session.getAttribute("role")==null || (!"ADMIN".equals(session.getAttribute("role")) && !"STAFF".equals(session.getAttribute("role")))) { 
        response.sendRedirect("login.jsp"); return; 
    }
    
    String action = request.getParameter("action");
    
    try (Connection c = DBConnection.getConnection()) {
        if ("add".equals(action)) {
            // এখানে ZONE_ID এর জন্য SEQ_ZONE.NEXTVAL ব্যবহার করা হয়েছে
            PreparedStatement ps = c.prepareStatement("INSERT INTO ZONE_STATUS (ZONE_ID, AREA_NAME, STATUS, REASON) VALUES (SEQ_ZONE.NEXTVAL, ?, ?, ?)");
            ps.setString(1, request.getParameter("areaName"));
            ps.setString(2, request.getParameter("status"));
            ps.setString(3, request.getParameter("reason"));
            ps.executeUpdate();
            c.commit();
            response.sendRedirect("zone_management.jsp?msg=added");
            
        } else if ("update".equals(action)) {
            PreparedStatement ps = c.prepareStatement("UPDATE ZONE_STATUS SET STATUS=?, REASON=?, UPDATED_AT=SYSDATE WHERE ZONE_ID=?");
            ps.setString(1, request.getParameter("status"));
            ps.setString(2, request.getParameter("reason"));
            ps.setInt(3, Integer.parseInt(request.getParameter("zoneId")));
            ps.executeUpdate();
            c.commit();
            response.sendRedirect("zone_management.jsp?msg=updated");
        }
    } catch (Exception e) {
        throw new ServletException(e);
    }
%>