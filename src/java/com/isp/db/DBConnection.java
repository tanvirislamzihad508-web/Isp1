package com.isp.db;
import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    private static final String URL = "jdbc:oracle:thin:@localhost:1521:XE";
    private static final String USER = "system";
    private static final String PASS = "oracle"; // আপনার পাসওয়ার্ড দিন

    static {
        try { Class.forName("oracle.jdbc.driver.OracleDriver"); }
        catch (Exception e) { e.printStackTrace(); }
    }
    public static Connection getConnection() throws Exception {
        Connection conn = DriverManager.getConnection(URL, USER, PASS);
        conn.setAutoCommit(false); // Auto-commit বন্ধ করা হলো
        return conn;
    }
}