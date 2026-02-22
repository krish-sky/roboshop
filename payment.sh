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
