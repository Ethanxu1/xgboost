import smtplib
from os.path import basename
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.message import EmailMessage
import os
import sys

procid = sys.argv[1]
email = sys.argv[2]

os.system(f"R < xgboost.R --vanilla --slave --args {procid}1.csv {procid}2.csv {procid} > ./tmp/{procid}.out")

info = []
with open('pass.txt', 'r') as f:
    info = f.read().split('\n')

EMAIL_ADDR = info[0]
EMAIL_PASS = info[1]
#os.system('echo "hello" > abc.txt')
msg = MIMEMultipart()
msg['from'] = 'ethanxu1@gmail.com'
msg['to'] = email
msg.attach(MIMEText('Your results are in the attachment'))

#"pred-", procid, ".txt"
file = f'./tmp/pred{procid}.txt'
with open(file, 'r') as f:
    attachment = MIMEApplication(f.read(), Name=basename(file))
    attachment['Content-Disposition'] = 'attachment; filename="{}"'.format(basename(file))

msg.attach(attachment)

server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
server.login(EMAIL_ADDR, EMAIL_PASS)
server.send_message(msg, from_addr='ethanxu1@gmail.com', to_addrs=email)

os.system(f'rm ./tmp/*{procid}*.*')
