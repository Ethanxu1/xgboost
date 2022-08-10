#!/usr/bin/python3
import cgi, cgitb

import cgitb; cgitb.enable()

import os

form = cgi.FieldStorage()
file1 = form['file1']
file2 = form['file2']
email = form.getvalue('email')
procid = os.getpid()

print()

with open('header.html') as f:
    lines = f.readlines()
    for i in lines:
        print(i, end='')
    f.close()

print('Data submitted and results will be emailed to ethanxu1@gmail.com')

if file1.file:
    with open(f'./tmp/{procid}1.csv', 'wb') as f:
        f.write(file1.file.read())
        f.close()

if file2.file:
    with open(f'./tmp/{procid}2.csv', 'wb') as f:
        f.write(file2.file.read())
        f.close()

os.system(f"python3 send_email.py {procid} {email} &")

with open('footer.html') as f:
    lines = f.readlines()
    for line in lines:
        print(line, end='')
