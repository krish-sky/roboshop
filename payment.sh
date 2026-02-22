#!/bin/bash


USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPTDIR=$PWD


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

dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
VALIDATE $? "Installing Python"


id roboshop

if [ $? -ne 0 ]; then   
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "System User created"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "app created"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "payment download"

cd /app 
VALIDATE $? "Moving to app directory"

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "removing existing code"

unzip /tmp/payment.zip &>>$LOGS_FILE
VALIDATE $? "Unzip code"


pip3 install -r requirements.txt  &>>$LOGS_FILE
VALIDATE $? "npm install"

cp $SCRIPTDIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Copying payment.service file"

systemctl daemon-reload
systemctl enable payment &>>$LOGS_FILE
systemctl start payment
VALIDATE $? "reload enable Start payment"
