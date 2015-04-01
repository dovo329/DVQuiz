import sqlite3;
from datetime import datetime, date;

conn = sqlite3.connect('QandA.sqlite3')
c = conn.cursor()
c.execute('drop table if exists QandA')
c.execute('create table QandA(id integer primary key autoincrement, question text, answerA text, answerB text, answerC text, answerD text, correctIndex integer)')

def mysplit (string):
    quote = False
    retval = []
    current = ""
    for char in string:
        if char == '"':
            quote = not quote
        elif char == ',' and not quote:
            retval.append(current)
            current = ""
        else:
            current += char
    retval.append(current)
    return retval

#Read lines from file, skipping first line
data = open("QandA.csv", "r").readlines()[1:]
for entry in data:
    # Parse values
    vals = mysplit(entry.strip())
    # Convert dates to sqlite3 standard format
    # Insert the row!
    print "Inserting %s..." % (vals[0])
    sql = "insert into QandA values(NULL, ?, ?, ?, ?, ?, ?)"
    c.execute(sql, vals)

# Done !
conn.commit()


