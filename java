package com.madyan.erp;

import java.util.Scanner;

public class CLI {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        boolean running = true;

        System.out.println("=== Madyan ERP CLI ===");
        System.out.println("Available commands: login, invoice, report, exit");

        while (running) {
            System.out.print("> ");
            String command = scanner.nextLine().trim().toLowerCase();

            switch (command) {
                case "login":
                    System.out.println("Enter username:");
                    String user = scanner.nextLine();
                    System.out.println("Enter password:");
                    String pass = scanner.nextLine();
                    // هنا تضع التحقق من قاعدة البيانات
                    System.out.println("Login successful for user: " + user);
                    break;

                case "invoice":
                    System.out.println("Creating new invoice...");
                    // استدعاء كود إدارة الفواتير
                    System.out.println("Invoice created successfully.");
                    break;

                case "report":
                    System.out.println("Generating report...");
                    // استدعاء كود التقارير
                    System.out.println("Report generated.");
                    break;

                case "exit":
                    running = false;
                    System.out.println("Exiting Madyan ERP CLI. Goodbye!");
                    break;

                default:
                    System.out.println("Unknown command. Try again.");
            }
        }

        scanner.close();
    }
}
