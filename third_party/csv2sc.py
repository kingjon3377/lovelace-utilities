#!/usr/bin/python
# From http://www.linuxjournal.com/article/10699

import sys
import string

if len(sys.argv) < 2:
    print("Usage:", sys.argv[0], "infile [outfile] [delimiter_char]")
    sys.exit(1)

filename_in = sys.argv[1]

if len(sys.argv) > 2:
    filename_out = sys.argv[2]
    outfile = open(filename_out, 'w')
else:
    outfile = sys.stdout

delimiter = ':'
if len(sys.argv) == 4:
    delimiter = sys.argv[3][0]
    print('using delimiter', delimiter)

infile = open(filename_in, 'r')

letters = string.ascii_uppercase
text = ["# Produced by convert_csv_to_sc.py" ]
row=0
for line in infile.readlines():
    allp = line.rstrip().split(delimiter)
    if len(allp) > 25:
        print("i'm too simple to handle more than 26 many columns")
        sys.exit(2)
    column = 0
    for p in allp:
        col = letters[column]
        if len(p) != 0:
            try:
                n = string.atof(p)
                text.append('let %c%d = %g' % (col, row, n))
            except:
                if p[0] == '"':
                    text.append('label %c%d = %s' % (col, row, p))
                else:
                    text.append('label %c%d = "%s"' % (col, row, p))
        column += 1
    row += 1

infile.close()
outfile.write("\n".join(text))
outfile.write("\n")
if outfile != sys.stdout:
    outfile.close()
