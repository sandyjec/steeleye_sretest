#!/bin/bash
web=`terraform output -json ip |sed 's/[][]//g'|sed -e 's/^"//' -e 's/"$//'`
app1=`terraform output -json ips |sed 's/[][]//g'|cut -d',' -f1|sed -e 's/^"//' -e 's/"$//'`
app2=`terraform output -json ips |sed 's/[][]//g'|cut -d',' -f2|sed -e 's/^"//' -e 's/"$//'`
echo "$web , $app1 , $app2"

cat <<EOF > route.conf
upstream backend {
        server $app1:8484;
        server $app2:8484;
    }
	
    server {
        listen      80;
        listen      [::]:80;
        server_name $web;

        location / {
	        proxy_redirect      off;
	        proxy_set_header    X-Real-IP \$remote_addr;
	        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
	        proxy_set_header    Host \$http_host;
		proxy_pass http://backend;
	}
}

EOF

#install go lang on app1 

ssh -i id_rsa ubuntu@$app1 "sudo apt-get update && sudo apt-get -y install golang-go"

sleep 10s

#copy app.go to appserver

scp -i id_rsa app.go ubuntu@$app1:/home/ubuntu

sleep 5s

#start app on app1 

ssh -i id_rsa ubuntu@$app1 "cd /home/ubuntu && (nohup go run app.go > /dev/null 2>&1 &)"


#install go lang on app2

ssh -i id_rsa ubuntu@$app2 "sudo apt-get update && sudo apt-get -y install golang-go"

sleep 10s

#copy app.go to appserver2

scp -i id_rsa app.go ubuntu@$app2:/home/ubuntu

sleep 5s

#start app on app2

ssh -i id_rsa ubuntu@$app2 "cd /home/ubuntu && (nohup go run app.go > /dev/null 2>&1 &)"


#copy load balance config on nginx server 
scp -i id_rsa route.conf ubuntu@$web:/home/ubuntu

sleep 5s

#reload nginx and due to sudo user issue had to copy first on local user and then to target folder
ssh -i id_rsa ubuntu@$web "sudo cp /home/ubuntu/route.conf /etc/nginx/conf.d/. && sudo service nginx reload"


echo "open $web in your browser to check app load balancing"
                                                                                      
