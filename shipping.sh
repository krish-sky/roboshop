#!/bin/bash


USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPTDIR=$PWD
MYSQL_HOST=mysql.daws88s.online



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


dnf install maven -y
VALIDATE $? "Installing maven"

id roboshop

if [ $? -ne 0 ]; then   
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "System User created"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi


mkdir -p /app 
VALIDATE $? "app created"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATE $? "shipping download"

cd /app 
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "removing existing code"

unzip /tmp/shipping.zip
VALIDATE $? "Unzip code"


mvn clean package 
VALIDATE $? "package installation"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "shipping jar"


cp $SCRIPTDIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Copying shipping.service file"

systemctl daemon-reload
systemctl enable shipping
systemctl start shipping
VALIDATE $? "reload enable Start shipping"

dnf install mysql -y 
VALIDATE $? "install mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'

if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql 
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
else  
    echo -e "Database already exist....$Y SKIPPING $N"
fi

systemctl restart shipping
VALIDATE $? "Shipping Restart"