<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Forgot Password</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head><body class="bg-light">
<div class="container d-flex justify-content-center align-items-center" style="min-height:100vh;">
  <div class="card shadow p-4" style="width:450px;">
    <h4 class="text-center mb-3">Reset Password</h4>
    <p class="text-muted text-center" style="font-size: 14px;">Enter your registered Phone Number or Email address.</p>
    
    <% if (request.getParameter("msg") != null) { %>
        <div class="alert alert-info"><%= request.getParameter("msg") %></div>
    <% } %>
    
    <form method="post" action="forgot">
      <div class="mb-3"><label>Phone or Email</label>
        <input name="contact" class="form-control" required autofocus placeholder="01XXXXXXXXX or example@mail.com"></div>
      <button class="btn btn-warning w-100">Reset Password</button>
    </form>
    <hr>
    <div class="text-center"><a href="login.jsp">Back to Login</a></div>
  </div>
</div></body></html>