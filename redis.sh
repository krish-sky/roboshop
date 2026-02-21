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