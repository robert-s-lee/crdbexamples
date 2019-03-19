import java.sql.*;

/*
You can compile and run this example with a command like:
  javac AutoIncrementPreparedStatement.java
  javac serialscroll.java && java -cp ~/bin/postgresql-42.0.0.jar:./ serialscroll
You can download the postgres JDBC driver jar from https://jdbc.postgresql.org.
*/
public class serialscroll {
    public static void main(String[] args) throws ClassNotFoundException, SQLException {
        // Load the postgres JDBC driver.
        Class.forName("org.postgresql.Driver");

        // Connect to the "bank" database.
        Connection conn = DriverManager.getConnection("jdbc:postgresql://127.0.0.1:26257/?reWriteBatchedInserts=true&applicationanme=123&sslmode=disable", "root", "");
        conn.setAutoCommit(false); // true and false do not make the difference
        // rewrite batch does not make the difference

        try {
            // Create the "accounts" table.
            conn.createStatement().execute("CREATE TABLE IF NOT EXISTS accounts (id serial PRIMARY KEY, balance INT)");

            // Insert two rows into the "accounts" table.
            PreparedStatement st = conn.prepareStatement("INSERT INTO accounts (balance) VALUES (?), (?) returning id, balance", 
                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                    ResultSet.CONCUR_UPDATABLE);
        st.setInt(1, 100);          
        st.setInt(2, 200);          

            ResultSet rs = st.executeQuery();

            st = conn.prepareStatement("select id1, id2, link_type, visibility, data, time, version from  linkbench.linktable where id1 = 9307741 and link_type = 123456790 and time >= 0 and time <= 9223372036854775807 and visibility = 1 order by time desc limit 0 offset 10000",
                    ResultSet.TYPE_SCROLL_INSENSITIVE,
                    ResultSet.CONCUR_UPDATABLE);
            rs = st.executeQuery();
        rs.last();
        int count = rs.getRow();
        rs.beforeFirst();
                System.out.printf("# of row in return set is %d\n", count);

            while (rs.next()) {
                System.out.printf("\taccount %s: %s\n", rs.getLong("id"), rs.getInt("balance"));
            }
        } finally {
            // Close the database connection.
            conn.close();
        }
    }
}

