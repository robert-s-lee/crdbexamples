import java.sql.*;

/*
You can compile and run this example with a command like:
  javac BasicSample.java && java -cp .:~/path/to/postgresql-9.4.1208.jar BasicSample
You can download the postgres JDBC driver jar from https://jdbc.postgresql.org.
*/
public class serial {
    public static void main(String[] args) throws ClassNotFoundException, SQLException {
        // Load the postgres JDBC driver.
        Class.forName("org.postgresql.Driver");

        // Connect to the "bank" database.
        Connection db = DriverManager.getConnection("jdbc:postgresql://127.0.0.1:26257/test?sslmode=disable", "root", "");

        try {
            // Create the "accounts" table.
            db.createStatement().execute("CREATE TABLE IF NOT EXISTS accounts (id serial PRIMARY KEY, balance INT)");

            // Insert two rows into the "accounts" table.
            ResultSet res = db.createStatement().executeQuery("INSERT INTO accounts (balance) VALUES (1000), (250) returning id, balance");

            while (res.next()) {
                System.out.printf("\taccount %s: %s\n", res.getInt("id"), res.getInt("balance"));
            }
        } finally {
            // Close the database connection.
            db.close();
        }
    }
}

