/*

batchwrite version of https://www.cockroachlabs.com/docs/stable/build-a-go-app-with-cockroachdb.html


- create database md;

- see the effects of batch size and performance

basic-batchwrite -cols 10 -rows 9000 -batch 1
basic-batchwrite -cols 10 -rows 9000 -batch 2
basic-batchwrite -cols 10 -rows 9000 -batch 4
basic-batchwrite -cols 10 -rows 9000 -batch 8
basic-batchwrite -cols 10 -rows 9000 -batch 16
basic-batchwrite -cols 10 -rows 9000 -batch 32
basic-batchwrite -cols 10 -rows 9000 -batch 64
basic-batchwrite -cols 10 -rows 9000 -batch 128
basic-batchwrite -cols 10 -rows 9000 -batch 256
basic-batchwrite -cols 10 -rows 9000 -batch 512
basic-batchwrite -cols 10 -rows 9000 -batch 1024

*/

package main

import (
	"database/sql"
	"fmt"
	"log"
  "flag"
  "bytes"
  "math/rand"
  "time"
	_ "github.com/lib/pq"
)

func main() {

  var stmtPrefix, stmtSuffix, linePrefix, linePrefix2, valueDelim, lineSuffix string
  var bs bytes.Buffer

  r := rand.New(rand.NewSource(99))

  maxcolsPtr := flag.Int("cols", 2, "number of integer columns in schema")
  maxrowsPtr := flag.Int("rows", 10000000, "numbner of rows to generate")
  batchsizePtr := flag.Int("batch", 100000, "commit after this many rows at a time")
  flag.Parse()


  stmtPrefix = "insert into accounts values "
  stmtSuffix = ";"
  linePrefix = "("      // first line prefix
  linePrefix2 = ",("    // 2nd and after lines prefix
  valueDelim = ","
  lineSuffix = ")"

	// Connect to the "bank" database.
	db, err := sql.Open("postgres", "postgresql://root@localhost:26257/md?sslmode=disable")
	if err != nil {
		log.Fatal("error connecting to the database: ", err)
	}

  // Create DDL -- create table (id int primary key, id2 int, id3 int ...)
	bs.WriteString(fmt.Sprintf("CREATE TABLE IF NOT EXISTS accounts (id INT PRIMARY KEY"))
  for j := 1; j < *maxcolsPtr; j++ {                  // rest of the columns
      bs.WriteString(fmt.Sprintf(",id%d int",j ))
  }
  bs.WriteString(fmt.Sprintf(")"))

  // Create the "accounts" table.
	if _, err := db.Exec(bs.String()); err != nil {
		log.Fatal(err)
	}
  log.Print(bs.String())
  bs.Reset()

  // assume empty table
  i := 0

  // get the max value of primay key if exists
	rows, err := db.Query("SELECT max(id) from accounts")
	if err != nil {
		log.Fatal(err)
	}
	for rows.Next() {
		if err := rows.Scan(&i); err == nil {
      i++
    }
    log.Print(fmt.Sprintf("starting insert from %d\n", i))
  }
  *maxrowsPtr += i
	
  for ; i < *maxrowsPtr; {
    // frist row of the data
    bs.WriteString(fmt.Sprintf("%s\n",stmtPrefix))
    bs.WriteString(fmt.Sprintf("%s%d", linePrefix,i))   // first column
    for j := 1; j < *maxcolsPtr; j++ {                  // rest of the columns
      bs.WriteString(fmt.Sprintf("%s%d", valueDelim, r.Intn(100)))
    }
    bs.WriteString(fmt.Sprintf("%s\n", lineSuffix))
    i++

    // rest of the rows
    for k := 1; k < *batchsizePtr; k++ {
      bs.WriteString(fmt.Sprintf("%s%d", linePrefix2,i))   // first column
      for j := 1; j < *maxcolsPtr; j++ {                  // rest of the columns
        bs.WriteString(fmt.Sprintf("%s%d", valueDelim, r.Intn(100)))
      }
      bs.WriteString(fmt.Sprintf("%s\n", lineSuffix))
      i++
    }
    bs.WriteString(fmt.Sprintf("%s\n",stmtSuffix))

    time1 := time.Now()
    _, err = db.Exec(bs.String())
    elapsed := time.Since(time1)
    fmt.Printf("rows %d batch %d cols %d duration %s row/s %.2f\n", i, *batchsizePtr, *maxcolsPtr, elapsed.String(), float64(*batchsizePtr) / elapsed.Seconds() )
    if err != nil {
      log.Fatal(err)
    }
    bs.Reset()
  }

	// Print out the balances.
	rows, err = db.Query("SELECT count(*) from accounts")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	log.Print("Number of rows:")
	for rows.Next() {
		var count int
		if err := rows.Scan(&count); err != nil {
			log.Fatal(err)
		}
		log.Print(fmt.Sprintf("%d\n", count))
	}
}
