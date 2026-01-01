#!/bin/sh
echo "QA Labs Are Great!" > index.html
nohup busybox httpd -f -p 8080 &