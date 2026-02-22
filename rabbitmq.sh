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
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Added RabbitMQ repo"

dnf install rabbitmq-server -y &>>$LOGS_FILE
VALIDATE $? "Rabbitmq server"

systemctl enable rabbitmq-server &>>$LOGS_FILE
systemctl start rabbitmq-server
VALIDATE $? "Enable and Start Rabbit" 

rabbitmqctl list_users | grep -q "^roboshop\b" &>>$LOGS_FILE

if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123
else 
    echo "already user exist .... $Y SKIPPING $N"
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGS_FILE
VALIDATE $? "Permission set"