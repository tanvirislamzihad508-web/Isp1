package com.isp.servlet;

import com.isp.db.DBConnection;
import com.isp.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.net.URLEncoder;
import java.util.Random;

@WebServlet("/customers")
public class CustomerServlet extends HttpServlet {
    private String generateRandomPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        StringBuilder sb = new StringBuilder(8); Random random = new Random();
        for (int i = 0; i < 8; i++) { sb.append(chars.charAt(random.nextInt(chars.length()))); }
        return sb.toString();
    }
    
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        try (Connection c = DBConnection.getConnection()) {
            if ("save".equals(action)) {
                // ... (আগের কোডটাই থাকবে, আমি শুধু delete অংশটা ঠিক করেছি) ...
                String id = req.getParameter("customerId"); String name = req.getParameter("name"); String phone = req.getParameter("phone");
                String address = req.getParameter("address"); String area = req.getParameter("area"); String email = req.getParameter("email"); String packageId = req.getParameter("packageId");
                if (phone == null || phone.length() != 11 || !phone.matches("\\d+")) {
                    resp.sendRedirect("customers.jsp?msg=" + URLEncoder.encode("Error: Phone must be 11 digits!", "UTF-8") + "&type=danger"); return;
                }
                if (address != null && address.trim().isEmpty()) address = null; if (area != null && area.trim().isEmpty()) area = null; if (email != null && email.trim().isEmpty()) email = null;
                if (id == null || id.isEmpty()) {
                    PreparedStatement check = c.prepareStatement("SELECT CUSTOMER_ID FROM CUSTOMER WHERE PHONE=? OR (EMAIL IS NOT NULL AND EMAIL=?)");
                    check.setString(1, phone); check.setString(2, email);
                    if(check.executeQuery().next()) { resp.sendRedirect("customers.jsp?msg=" + URLEncoder.encode("Error: Phone or Email already exists!", "UTF-8") + "&type=danger"); return; }
                    String uniquePass = generateRandomPassword();
                    PreparedStatement u = c.prepareStatement("INSERT INTO USERS (USERNAME,PASSWORD_HASH,PLAIN_PASSWORD,ROLE,STATUS) VALUES (?,?,?,'CUSTOMER','ACTIVE')");
                    u.setString(1, phone); u.setString(2, PasswordUtil.hash(uniquePass)); u.setString(3, uniquePass); u.executeUpdate();
                    PreparedStatement getUid = c.prepareStatement("SELECT SEQ_USERS.CURRVAL FROM DUAL"); ResultSet ru = getUid.executeQuery(); int userId = 0; if(ru.next()) userId = ru.getInt(1);
                    PreparedStatement ps = c.prepareStatement("INSERT INTO CUSTOMER (NAME,PHONE,ADDRESS,AREA,EMAIL,USER_ID) VALUES (?,?,?,?,?,?)");
                    ps.setString(1, name); ps.setString(2, phone); ps.setString(3, address); ps.setString(4, area); ps.setString(5, email); ps.setInt(6, userId); ps.executeUpdate();
                    PreparedStatement getCid = c.prepareStatement("SELECT SEQ_CUSTOMER.CURRVAL FROM DUAL"); ResultSet rc = getCid.executeQuery(); int cid = 0; if(rc.next()) cid = rc.getInt(1);
                    if (packageId != null && !packageId.isEmpty() && cid > 0) {
                        PreparedStatement sub = c.prepareStatement("INSERT INTO SUBSCRIPTION (CUSTOMER_ID,PACKAGE_ID,STATUS) VALUES (?,?,'ACTIVE')");
                        sub.setInt(1, cid); sub.setInt(2, Integer.parseInt(packageId)); sub.executeUpdate();
                    }
                    c.commit();
                    String notifMsg = "Success! SMS sent to " + phone + ". Unique Pass: " + uniquePass;
                    resp.sendRedirect("customers.jsp?msg=" + URLEncoder.encode(notifMsg, "UTF-8") + "&type=success");
                } else {
                    PreparedStatement ps = c.prepareStatement("UPDATE CUSTOMER SET NAME=?,ADDRESS=?,AREA=?,EMAIL=? WHERE CUSTOMER_ID=?");
                    ps.setString(1, name); ps.setString(2, address); ps.setString(3, area); ps.setString(4, email); ps.setInt(5, Integer.parseInt(id));
                    ps.executeUpdate(); c.commit(); resp.sendRedirect("customers.jsp?msg=" + URLEncoder.encode("Customer Updated!", "UTF-8") + "&type=success");
                }
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                try {
                    // ১. প্রথমেই USER_ID বের করে নেয়া
                    int userId = 0;
                    PreparedStatement getUid = c.prepareStatement("SELECT USER_ID FROM CUSTOMER WHERE CUSTOMER_ID=?"); 
                    getUid.setInt(1, id); ResultSet ru = getUid.executeQuery(); if(ru.next()) userId = ru.getInt(1);

                    // ২. ACTIVITY_LOG ডিলিট করা (যদি থাকে)
                    if(userId > 0) {
                        PreparedStatement psLog = c.prepareStatement("DELETE FROM ACTIVITY_LOG WHERE USER_ID=?");
                        psLog.setInt(1, userId); psLog.executeUpdate();
                    }

                    // ৩. নতুন PAYMENT_REQUESTS টেবিল থেকে ডাটা ডিলিট করা
                    PreparedStatement psReq = c.prepareStatement("DELETE FROM PAYMENT_REQUESTS WHERE CUSTOMER_ID=?");
                    psReq.setInt(1, id); psReq.executeUpdate();

                    // ৪. Payment Log ডিলিট
                    PreparedStatement ps0 = c.prepareStatement("DELETE FROM PAYMENT_LOG WHERE BILL_ID IN (SELECT BILL_ID FROM BILL WHERE SUBSCRIPTION_ID IN (SELECT SUBSCRIPTION_ID FROM SUBSCRIPTION WHERE CUSTOMER_ID=?))"); 
                    ps0.setInt(1, id); ps0.executeUpdate();
                    
                    // ৫. Payment ডিলিট
                    PreparedStatement ps1 = c.prepareStatement("DELETE FROM PAYMENT WHERE BILL_ID IN (SELECT BILL_ID FROM BILL WHERE SUBSCRIPTION_ID IN (SELECT SUBSCRIPTION_ID FROM SUBSCRIPTION WHERE CUSTOMER_ID=?))"); 
                    ps1.setInt(1, id); ps1.executeUpdate();
                    
                    // ৬. Bill ডিলিট
                    PreparedStatement ps2 = c.prepareStatement("DELETE FROM BILL WHERE SUBSCRIPTION_ID IN (SELECT SUBSCRIPTION_ID FROM SUBSCRIPTION WHERE CUSTOMER_ID=?)"); 
                    ps2.setInt(1, id); ps2.executeUpdate();
                    
                    // ৭. Complaint ডিলিট
                    PreparedStatement ps3 = c.prepareStatement("DELETE FROM COMPLAINT WHERE CUSTOMER_ID=?"); 
                    ps3.setInt(1, id); ps3.executeUpdate();
                    
                    // ৮. Subscription ডিলিট
                    PreparedStatement ps4 = c.prepareStatement("DELETE FROM SUBSCRIPTION WHERE CUSTOMER_ID=?"); 
                    ps4.setInt(1, id); ps4.executeUpdate();
                    
                    // ৯. Customer ডিলিট
                    PreparedStatement ps5 = c.prepareStatement("DELETE FROM CUSTOMER WHERE CUSTOMER_ID=?"); 
                    ps5.setInt(1, id); ps5.executeUpdate();
                    
                    // ১০. Users ডিলিট
                    if(userId > 0) { 
                        PreparedStatement ps6 = c.prepareStatement("DELETE FROM USERS WHERE USER_ID=?"); 
                        ps6.setInt(1, userId); ps6.executeUpdate(); 
                    }
                    
                    c.commit(); 
                    resp.sendRedirect("customers.jsp?msg=" + URLEncoder.encode("Customer Deleted Successfully!", "UTF-8") + "&type=success");
                    
                } catch (Exception ex) { 
                    c.rollback(); 
                    ex.printStackTrace(); // Tomcat কনসোলে আসল এররটি দেখাবে
                    resp.sendRedirect("customers.jsp?msg=" + URLEncoder.encode("Error: " + ex.getMessage(), "UTF-8") + "&type=danger"); 
                }
            }
        } catch (Exception e) { throw new ServletException(e); }
    }
}