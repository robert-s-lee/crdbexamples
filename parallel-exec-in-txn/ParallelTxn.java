import java.sql.*;
import java.math.BigDecimal;

/*
java -cp ~/bin/postgresql-42.0.0.jar:./ SelectStar | wc -l
*/

class InsufficientBalanceException extends Exception {}
class AccountNotFoundException extends Exception {
    public int account;
    public AccountNotFoundException(int account) {
        this.account = account;
    }
}

public class ParallelTxn {
  public static void main(String[] args) throws ClassNotFoundException, SQLException {

  Class.forName("org.postgresql.Driver");
  Connection conn = DriverManager.getConnection("jdbc:postgresql://127.0.0.1:26257/md?sslmode=disable", "root", "");

  int from = 1;
  int to = 2;
  int amount = 1;
  int txnid = 1;

  String suffix = " returning nothing";

  try {

    ResultSet res;
    res = conn.createStatement().executeQuery(
      "BEGIN;" +
      "insert into txn (source,target,amount) values " +
        "(" + from + "," + to + "," + amount + ") returning (txnid);"
    );

    res.next();
    txnid= res.getInt(1);

    res = conn.createStatement().executeQuery(  		
      "insert into account (id,balance) values " +
        "(" + from + "," + (-amount)  + ")," + 
        "(" + to   + "," + (+amount) + ") " + 
        "on conflict (id) do update set balance = account.balance + excluded.balance" + suffix + ";" +
      "insert into journal (txnid,source,target,amount) values " +
        "(" + txnid + "," + from + "," + to   + "," + (+amount) + ")," + 
        "(" + txnid + "," + to   + "," + from + "," + (-amount) + ")" + suffix + ";" +
      "COMMIT;"
      );
    
  } finally {
   conn.close();
  }

}
}
