# pip3 install gunicorn boto3 smart-open
# gunicorn app 

from cgi import parse_qs, escape
from smart_open import open
import boto3
import csv
from io import StringIO ## for Python 3

class XformLine():
  def __init__(self, csv_in, csv_out, si, limit=0, nf=0, showerr=0):
    self.csv_in = csv_in
    self.csv_out = csv_out
    self.si = si
    self.nf = nf
    self.limit = limit
    self.cnt = 0  
    self.errcnt = 0  
    self.showerr = showerr
  def __iter__(self):
    return self
  def __next__(self): # stops but is oneshot
    if self.limit == 0 or self.cnt < self.limit: 
      for line in self.csv_in:
        self.cnt = self.cnt + 1
        if self.nf != 0 and len(line) == self.nf: 
          self.csv_out.writerow(line)
          crdbline=self.si.getvalue()
          self.si.seek(0)
          if self.showerr == 0:
            return(bytes(crdbline,'utf-8'))
        else:
          self.errcnt = self.errcnt + 1
          if self.showerr > 0:
            return(bytes(str(self.cnt)+str(line),'utf-8'))
    raise StopIteration

def application(environ, start_response):
    csv_quote = {'QUOTE_ALL':csv.QUOTE_ALL, 'QUOTE_MINIMAL': csv.QUOTE_MINIMAL, 'QUOTE_NONE': csv.QUOTE_NONE, 'QUOTE_NONNUMERIC':csv.QUOTE_NONNUMERIC}

    d = parse_qs(environ['QUERY_STRING'])
    # required
    url = d.get('url', [''])[0] # url of the file
    # optional
    limit = int(d.get('limit',['0'])[0]) # limit numnber of lines to process
    nf = int(d.get('nf',['0'])[0]) # expected number of columns
    showerr = int(d.get('showerr',['0'])[0]) # show error lines only
    # csv input dialect
    in_delimiter = d.get('delimiter',[','])[0] 
    in_doublequote = d.get('doublequote',[False])[0] 
    in_escapechar = d.get('escapechar',['\\'])[0] 
    in_lineterminator = d.get('lineterminator',['\r\n'])[0] 
    in_quotechar = d.get('quotechar',['"'])[0] 
    in_quoting = d.get('quoting',["QUOTE_MINIMAL"])[0] 
    in_skipinitialspace = d.get('skipinitialspace',[False])[0] 
    # csv output dialect
    out_delimiter = d.get('out_ddelimiterelim',[','])[0] 
    out_doublequote = d.get('out_doublequote',[True])[0] 
    out_escapechar = d.get('out_escapechar',['"'])[0] 
    out_lineterminator = d.get('out_lineterminator',['\r\n'])[0] 
    out_quotechar = d.get('out_quotechar',['"'])[0] 
    out_quoting = d.get('out_quoting',["QUOTE_MINIMAL"])[0] 
    out_skipinitialspace = d.get('out_skipinitialspace',[False])[0] 

    url = escape(url)

    # validate params
    if in_quoting in csv_quote:
      in_quoting = csv_quote[in_quoting]
    else:
      in_quoting = csv.QUOTE_MINIMAL 
    if out_quoting in csv_quote:
      out_quoting = csv_quote[out_quoting]
    else:
      out_quoting = csv.QUOTE_MINIMAL 

    status = '200 OK'
    response_headers = [('Content-type', 'text/plain')]
    start_response(status, response_headers)

    #try:
    if url:
      csvfile = open(url, 'r') # file:///Users/rslee/data/cockroach-data/1/extern/quotetestdata.csv
      si = StringIO()  # s.truncate(0) to remove
      csv_in = csv.reader(csvfile, delimiter=in_delimiter, doublequote=in_doublequote, escapechar=in_escapechar, lineterminator=in_lineterminator, quotechar=in_quotechar, quoting=in_quoting, skipinitialspace=in_skipinitialspace)
      csv_out = csv.writer(si,delimiter=out_delimiter, doublequote=out_doublequote, escapechar=out_escapechar, lineterminator=out_lineterminator, quotechar=out_quotechar, quoting=out_quoting, skipinitialspace=out_skipinitialspace)
      xform = XformLine(csv_in, csv_out, si, limit=int(limit),nf=nf,showerr=showerr)
      return iter(xform) 
    else:
      return [bytes("url not specified\n",'utf-8')]

def main():
  environ={"QUERY_STRING":{
    "url":'file:///Users/rslee/data/cockroach-data/1/extern/quotetestdata.csv',
    "delimiter":'|'
    }
  }
  application(environ,None)

if __name__== "__main__":
  main()
  
