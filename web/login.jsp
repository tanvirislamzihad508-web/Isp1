<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ISP Management System - Login</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        * {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            background-color: #f4f7f6;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .login-container {
            display: flex;
            width: 100%;
            max-width: 1000px;
            height: 85vh;
            background: #fff;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        /* Left Side - Form Area */
        .login-left {
            flex: 1;
            padding: 50px 40px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .login-title {
            font-size: 32px;
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }
        .login-subtitle {
            font-size: 14px;
            color: #777;
            margin-bottom: 30px;
        }
        .form-label {
            font-size: 13px;
            font-weight: 500;
            color: #555;
        }
        .form-control {
            border-radius: 8px;
            padding: 12px 15px;
            border: 1px solid #ddd;
            font-size: 14px;
            transition: all 0.3s;
        }
        .form-control:focus {
            box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.1);
            border-color: #0d6efd;
        }
        .form-check-label {
            font-size: 13px;
            color: #555;
        }
        .forgot-link {
            font-size: 13px;
            text-decoration: none;
            color: #0d6efd;
            font-weight: 500;
        }
        .forgot-link:hover {
            text-decoration: underline;
        }
        .btn-login {
            background: linear-gradient(135deg, #4b6cb7 0%, #182848 100%);
            color: white;
            border: none;
            border-radius: 8px;
            padding: 12px;
            font-size: 15px;
            font-weight: 600;
            width: 100%;
            transition: all 0.3s;
            margin-top: 10px;
        }
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(75, 108, 183, 0.4);
        }
        .divider {
            display: flex;
            align-items: center;
            text-align: center;
            margin: 25px 0;
            color: #999;
            font-size: 12px;
        }
        .divider::before, .divider::after {
            content: '';
            flex: 1;
            border-bottom: 1px solid #eee;
        }
        .divider:not(:empty)::before { margin-right: .25em; }
        .divider:not(:empty)::after { margin-left: .25em; }

        /* Right Side - Marketing & Policy Area */
        .login-right {
            flex: 1;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 50px;
            color: white;
            overflow: hidden;
        }
        /* ব্যাকগ্রাউন্ডে সুন্দর মডার্ন বাবল (Bubble) ইফেক্ট */
        .login-right::before, .login-right::after {
            content: '';
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
        }
        .login-right::before {
            width: 300px; height: 300px;
            top: -100px; right: -50px;
        }
        .login-right::after {
            width: 200px; height: 200px;
            bottom: -50px; left: -50px;
        }
        .right-content {
            position: relative;
            z-index: 10;
        }
        .right-content h2 {
            font-size: 36px;
            font-weight: 700;
            line-height: 1.3;
            margin-bottom: 20px;
        }
        .right-content p {
            font-size: 15px;
            line-height: 1.6;
            opacity: 0.9;
            margin-bottom: 30px;
        }
        .policy-list {
            list-style: none;
            padding: 0;
        }
        .policy-list li {
            font-size: 14px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .policy-list li i {
            font-size: 18px;
            color: #ffd700; /* গোল্ডেন কালার আইকন */
        }
        .company-footer {
            position: absolute;
            bottom: 30px;
            left: 50px;
            width: calc(100% - 100px);
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 12px;
            opacity: 0.7;
            z-index: 10;
        }

        /* Alert Messages Style */
        .alert-custom {
            border-radius: 8px;
            font-size: 13px;
            padding: 10px 15px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .login-container { flex-direction: column; height: auto; }
            .login-right { display: none; } /* মোবাইলে ডান দিকের অংশ হাইড থাকবে */
            .login-left { padding: 30px 20px; }
        }
    </style>
</head>
<body>

    <div class="login-container">
        
        <!-- Left Side: Login Form -->
        <div class="login-left">
            <div class="mb-4">
                <a href="login.jsp" class="text-decoration-none">
                    <h4 class="text-primary fw-bold"><i class="bi bi-wifi"></i> ISP System</h4>
                </a>
            </div>

            <h2 class="login-title">Login</h2>
            <p class="login-subtitle">Login to access your account</p>

            <!-- JSP Alert Messages -->
            <% if ("invalid".equals(request.getParameter("msg"))) { %>
                <div class="alert alert-danger alert-custom">
                    <i class="bi bi-exclamation-triangle-fill"></i> Invalid username or password.
                </div>
            <% } else if ("login-required".equals(request.getParameter("msg"))) { %>
                <div class="alert alert-warning alert-custom">
                    <i class="bi bi-shield-lock-fill"></i> Please login to access.
                </div>
            <% } else if ("loggedout".equals(request.getParameter("msg"))) { %>
                <div class="alert alert-success alert-custom">
                    <i class="bi bi-check-circle-fill"></i> Logged out successfully.
                </div>
            <% } else if ("invalid-session".equals(request.getParameter("msg"))) { %>
                <div class="alert alert-danger alert-custom">
                    <i class="bi bi-x-circle-fill"></i> Session expired. Someone else logged in.
                </div>
            <% } %>

            <!-- Login Form -->
            <form method="post" action="login">
                <div class="mb-3">
                    <label class="form-label">Username (Phone)</label>
                    <input name="username" type="text" class="form-control" placeholder="e.g. 017XXXXXXXX" required autofocus>
                </div>

                <div class="mb-3">
                    <label class="form-label">Password</label>
                    <div class="position-relative">
                        <input name="password" type="password" class="form-control" placeholder="••••••••" required>
                    </div>
                </div>

                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="rememberMe">
                        <label class="form-check-label" for="rememberMe">Remember me</label>
                    </div>
                    <a href="forgot_password.jsp" class="forgot-link">Forgot Password?</a>
                </div>

                <button type="submit" class="btn btn-login">Login</button>
                
                <div class="divider">Or Contact Support</div>
                
                <div class="text-center text-muted" style="font-size: 13px;">
                    <i class="bi bi-telephone-fill me-1"></i> Hotline: 16247
                </div>
            </form>
        </div>

        <!-- Right Side: Company Policy & Attractive Design -->
        <div class="login-right">
            <div class="right-content">
                <h2>Start Your Journey <br> With Us</h2>
                <p>Experience uninterrupted, high-speed internet connectivity tailored for your needs. We are committed to delivering the best.</p>
                
                <ul class="policy-list">
                    <li><i class="bi bi-check-circle-fill"></i> 99.9% Guaranteed Network Uptime</li>
                    <li><i class="bi bi-check-circle-fill"></i> 24/7 Dedicated Customer Support</li>
                    <li><i class="bi bi-check-circle-fill"></i> Secure & Encrypted Connection</li>
                    <li><i class="bi bi-check-circle-fill"></i> Transparent Billing Policy</li>
                </ul>
            </div>
            
            <div class="company-footer">
                <span>© 2026 ISP Management System</span>
                <span>Privacy Policy | Terms of Service</span>
            </div>
        </div>

    </div>

</body>
</html>