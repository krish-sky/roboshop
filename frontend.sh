#!/bin/bash


USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPTDIR=$PWD
MONGOBDIP="mongodb.krishsky.online"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo "Please run this script with root"
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){

    if [ $1 -ne 0 ]; then
        echo -e "$2 ...is $R failure $N" | tee $LOGS_FILE
        exit 1
    else
        echo -e "$2 ...is $G Success $N" | tee $LOGS_FILE
    fi
}

dnf module disable nginx -y
VALIDATE $? "Disable Nginx"

dnf module enable nginx:1.24 -y
VALIDATE $? "Enable Nginx"

dnf install nginx -y
VALIDATE $? "Installed Nginx"

systemctl enable nginx 
systemctl start nginx 
VALIDATE $? "start and enabled Nginx"


mkdir -p /app 
VALIDATE $? "app created"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing code"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip 
VALIDATE $? "frontend download"

cd /usr/share/nginx/html  
VALIDATE $? "Moving to HTML directory"

unzip /tmp/frontend.zip
VALIDATE $? "Unzip code"

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "removing old conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copied our nginx conf file"

systemctl restart nginx 
VALIDATE $? "Restarted Nginx"