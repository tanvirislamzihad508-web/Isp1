<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*,com.isp.db.DBConnection"%>
<% if (session.getAttribute("role")==null) { response.sendRedirect("login.jsp"); return; }
   String id=request.getParameter("id"); String name="",phone="",address="",area="",email="";
   if (id!=null) { try(Connection c=DBConnection.getConnection(); PreparedStatement ps=c.prepareStatement("SELECT * FROM CUSTOMER WHERE CUSTOMER_ID=?")){
       ps.setInt(1,Integer.parseInt(id)); ResultSet r=ps.executeQuery();
       if(r.next()){ name=r.getString("NAME"); phone=r.getString("PHONE"); address=r.getString("ADDRESS"); area=r.getString("AREA"); email=r.getString("EMAIL"); }
     } catch(Exception e){} } %>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Customer Form</title>
<style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', sans-serif; }
    body { background-color: #f4f7f6; color: #333; }
    .container { max-width: 600px; margin: 50px auto; padding: 0 20px; }
    .card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
    .form-group { margin-bottom: 20px; }
    .form-group label { display: block; margin-bottom: 8px; font-weight: bold; color: #555; }
    .form-control { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; font-size: 15px; }
    .form-control:focus { border-color: #0d6efd; outline: none; }
    .text-muted { font-size: 12px; color: #777; margin-top: 5px; display: block;}
    .btn { padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
    .btn-primary { background-color: #0d6efd; color: white; width: 100%; font-weight: bold;}
    .btn-secondary { background-color: #6c757d; color: white; width: 100%; margin-top: 10px; text-align: center; text-decoration: none; display: inline-block; box-sizing: border-box;}
</style>
</head><body>
<div class="container">
<div class="card">
<h2 style="margin-bottom: 25px;"><%=id==null?"Add New":"Edit"%> Customer</h2>
<form method="post" action="customers">
  <input type="hidden" name="action" value="save"><input type="hidden" name="customerId" value="<%=id==null?"":id%>">
  
  <div class="form-group">
    <label>Customer Name</label>
    <input name="name" class="form-control" required value="<%=name!=null?name:""%>">
  </div>
  
  <div class="form-group">
    <label>Phone Number (Unique Username) <span style="color:red;">*</span></label>
    <input name="phone" class="form-control" required pattern="[0-9]{11}" title="Phone number must be exactly 11 digits" value="<%=phone!=null?phone:""%>" <%=id!=null?"readonly":""%>>
    <% if(id==null) { %>
        <small class="text-muted">Must be 11 digits. This will be the customer's login Username and cannot be duplicated.</small>
    <% } else { %>
        <small class="text-muted">Phone number cannot be changed (it is the login username).</small>
    <% } %>
  </div>
  
  <div class="form-group">
    <label>Address</label>
    <input name="address" class="form-control" value="<%=address!=null?address:""%>">
  </div>
  
  <div class="form-group">
    <label>Area (WiFi Zone)</label>
    <input name="area" class="form-control" value="<%=area!=null?area:""%>">
  </div>
  
  <div class="form-group">
    <label>Email (Optional)</label>
    <input name="email" type="email" class="form-control" value="<%=email!=null?email:""%>">
  </div>
  
  <% if (id==null) { %>
  <div class="form-group">
    <label>Assign First Package</label>
    <select name="packageId" class="form-control">
      <option value="">-- Select Package --</option>
      <% try(Connection c=DBConnection.getConnection(); Statement st=c.createStatement(); ResultSet r=st.executeQuery("SELECT PACKAGE_ID,PACKAGE_NAME FROM PACKAGE WHERE STATUS='ACTIVE'")){
          while(r.next()){ %><option value="<%=r.getInt(1)%>"><%=r.getString(2)%></option><% } } catch(Exception e){} %>
    </select>
  </div>
  <% } %>
  
  <button class="btn btn-primary" style="margin-top: 15px;">Save Customer</button>
  <a href="customers.jsp" class="btn btn-secondary">Cancel</a>
</form>
</div>
</div>
</body></html>