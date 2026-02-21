#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m" #red
G="\e[32m" #green
Y="\e[33m" #yellow
N="\e[0m" #normal


if [ $USERID -ne 0 ]; then
    echo "Please run this script with root access"
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ..... is $R Failure $N" | tee $LOGS_FILE
        exit 1
    else
        echo -e "$2 ..... is $G Success $N" | tee $LOGS_FILE
    fi
}

dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? "Disable redis"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "Enable redis"


dnf install redis -y &>>$LOGS_FILE
VALIDATE $?  "Install redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e 'protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"


systemctl enable redis 
systemctl start redis 
VALIDATE $?  "Enable and Start redis"
