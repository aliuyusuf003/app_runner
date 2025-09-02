import java.io.*;
import java.sql.*;
import java.util.Scanner;

public class GenerateIntReport {
    // Database connection details
    private static final String JDBC_URL = "jdbc:mariadb://localhost:3306/mydb";
    private static final String JDBC_USER = "testuser";
    private static final String JDBC_PASSWORD = "testpass";

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        try {
            // Ask for dates
            System.out.print("Enter start_date (YYYY-MM-DD): ");
            String startDate = scanner.nextLine().trim();

            System.out.print("Enter end_date (YYYY-MM-DD): ");
            String endDate = scanner.nextLine().trim();
            long startTime = System.currentTimeMillis();
            // Connect to DB
            Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);

            // Build your query (replace table_name & date_column)
           
           String sql = "SELECT * FROM table WHERE createdAt >= ? AND createdAt < ?";  // any complext query
            PreparedStatement pstmt = conn.prepareStatement(sql, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_READ_ONLY);
            pstmt.setString(1, startDate);
            pstmt.setString(2, endDate);

            // Stream rows
            ResultSet rs = pstmt.executeQuery();

            // Output file
            String fileName = "a_report" + startDate + "_to_" + endDate + ".csv";
            try (PrintWriter writer = new PrintWriter(new FileWriter(fileName))) {
                ResultSetMetaData meta = rs.getMetaData();
                int columnCount = meta.getColumnCount();

                // Write header
                for (int i = 1; i <= columnCount; i++) {
                    writer.print(meta.getColumnName(i));
                    if (i < columnCount) writer.print(",");
                }
                writer.println();

                // Write rows
                while (rs.next()) {
                    for (int i = 1; i <= columnCount; i++) {
                        String value = rs.getString(i);
                        if (value != null) {
                            value = value.replace("\"", "\"\""); // escape quotes
                            if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
                                value = "\"" + value + "\"";
                            }
                        }
                        writer.print(value);
                        if (i < columnCount) writer.print(",");
                    }
                    writer.println();
                }
            }

            rs.close();
            pstmt.close();
            conn.close();

            long endTime = System.currentTimeMillis();
            long duration = (endTime - startTime) / 1000;
            String successMsg = "✅ Report generated successfully: " + fileName +
                    " (Time taken: " + duration + " seconds)";

            System.out.println(successMsg);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
