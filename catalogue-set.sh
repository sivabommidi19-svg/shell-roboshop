#!/bin/bash

set -euo pipefail

trap 'cho "There is an error in $LINENO, command is $BASH_COMMAND"' ERR 

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.daws86b.fun
LOG_FILE="$LOGS_FOLDER/$SCRIPT_Name.log"  #/var/log/shell-scipt/16log.log

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: please run this script with root privelege"
    exit 1 # failure is other than 0
fi
 
}
##########Node JS####
dnf module disable nodejs -y &>>$LOG_FILE
dnf module enable nodejs:20 -y &>>$LOG_FILE
dnf install nodejs -y &>>$LOG_FILE

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else
    echo -e "user already exit ...$Y SKIPPING $N"
fi
echo "Installing nodejs 20 ..$G SUCCESS $N"
mkdir -p /app 
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
cd /app 
rm -rf /app/*
unzip /tmp/catalogue.zip &>>$LOG_FILE
npm install &>>$LOG_FILE
cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
systemctl daemon-reload
systemctl enable catalogue &>>$LOG_FILE
echo -e "catalogue application setup... $G SUCCESS $N" 

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongoshd -y &>>$LOG_FILE

INDEX=$(mongosh mongodb.daws86b.fun --quiet --eval "db.getMongo().getDBNames().indexOf('admin')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
else
    echo -e "Catalogue product aleady loaded ...$Y SKIPPING $N"
fi

systemctl restart catalogue
echo -e "Loading products and restarting catalogue ... $G SUCCESS $N"


