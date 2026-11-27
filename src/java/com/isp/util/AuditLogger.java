package com.isp.util;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class AuditLogger {
    public static void log(Connection conn, int userId, String username, String action, String details) {
        try {
            PreparedStatement ps = conn.prepareStatement("INSERT INTO ACTIVITY_LOG (USER_ID, USERNAME, ACTION_TYPE, DETAILS) VALUES (?, ?, ?, ?)");
            ps.setInt(1, userId);
            ps.setString(2, username);
            ps.setString(3, action);
            ps.setString(4, details);
            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("Log Error: " + e.getMessage());
        }
    }
}