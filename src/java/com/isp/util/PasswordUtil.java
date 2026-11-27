package com.isp.util;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;

public class PasswordUtil {
    private static final String SALT = "ISP_SALT_2026";
    public static String hash(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] h = md.digest((password + SALT).getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : h) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) { throw new RuntimeException(e); }
    }
    public static boolean verify(String plain, String hashed) {
        return hash(plain).equals(hashed);
    }
}