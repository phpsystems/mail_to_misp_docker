#!/bin/sh
cd /app/mail_to_misp

while [ 1 ]; do
    sleep 5
    python3 fake_smtp.py --host 0.0.0.0 --port 2525
done;
