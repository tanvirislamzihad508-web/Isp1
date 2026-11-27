<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<% if (session.getAttribute("role")==null) { response.sendRedirect("login.jsp"); return; }
   String id=request.getParameter("id");
   String name="",phone="",address="",area="",email="";
   if (id!=null) {
     try(Connection c=DBConnection.getConnection();
         PreparedStatement ps=c.prepareStatement("SELECT * FROM CUSTOMER WHERE CUSTOMER_ID=?")){
       ps.setInt(1,Integer.parseInt(id));
       ResultSet r=ps.executeQuery();
       if(r.next()){ name=r.getString("NAME"); phone=r.getString("PHONE");
                     address=r.getString("ADDRESS"); area=r.getString("AREA"); email=r.getString("EMAIL"); }
     } catch(Exception e){}
   }
%>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Customer Form</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head><body><div class="container mt-4" style="max-width:600px">
<h3><%=id==null?"New":"Edit"%> Customer</h3>
<form method="post" action="customers">
  <input type="hidden" name="action" value="save">
  <input type="hidden" name="customerId" value="<%=id==null?"":id%>">
  <div class="mb-2"><label>Name</label><input name="name" class="form-control" required value="<%=name%>"></div>
  <div class="mb-2"><label>Phone (Will be username)</label><input name="phone" class="form-control" required value="<%=phone%>"></div>
  <div class="mb-2"><label>Address</label><input name="address" class="form-control" value="<%=address%>"></div>
  <div class="mb-2"><label>Area</label><input name="area" class="form-control" value="<%=area%>"></div>
  <div class="mb-2"><label>Email</label><input name="email" type="email" class="form-control" value="<%=email%>"></div>
  <% if (id==null) { %>
  <div class="mb-2"><label>Assign Package (optional)</label>
    <select name="packageId" class="form-control">
      <option value="">-- none --</option>
      <%
        try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement()){
          ResultSet r=st.executeQuery("SELECT PACKAGE_ID,PACKAGE_NAME FROM PACKAGE WHERE STATUS='ACTIVE'");
          while(r.next()){ %><option value="<%=r.getInt(1)%>"><%=r.getString(2)%></option><% }
        } catch(Exception e){}
      %>
    </select></div>
  <% } %>
  <button class="btn btn-primary">Save</button>
  <a href="customers.jsp" class="btn btn-secondary">Cancel</a>
</form></div></body></html>