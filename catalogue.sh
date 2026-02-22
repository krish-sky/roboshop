#!/bin/bash


USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPTDIR=$PWD
MONGODBIP="mongodb.krishsky.online"

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

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disable Nodejs"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "enable Nodejs"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "install Nodejs"

id roboshop

if [ $? -ne 0 ]; then   
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "System User created"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "app created"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Catalogue download"

cd /app 
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "removing existing code"

unzip /tmp/catalogue.zip
VALIDATE $? "Unzip code"


npm install  &>>$LOGS_FILE
VALIDATE $? "npm install"

cp $SCRIPTDIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue.service file"

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "reload enable Start catalogue"

cp $SCRIPTDIR/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "mongodb-org install"

INDEX=$(mongosh --host $MONGODBIP --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -ne 0 ]; then
    mongosh --host $MONGODBIP </app/db/master-data.js
else
    echo -e "Product already exist... $Y skipping $N"
fi

systemctl restart catalogue
VALIDATE $? "Restarting catalogue"