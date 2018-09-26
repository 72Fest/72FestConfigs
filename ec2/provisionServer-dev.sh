# set up firewall
#!/bin/bash
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 3000

# install mongo
echo "[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc" |
sudo tee -a /etc/yum.repos.d/mongodb-org-3.2.repo
sudo yum update -y
sudo yum install -y gcc64-c++.x86_64 gcc48.x86_64 git.x86_64 ImageMagick.x86_64 mongodb-org-server mongodb-org-shell mongodb-org-tools
sudo service mongod start

# set timezone
sudo cp /usr/share/zoneinfo/America/New_York /etc/localtime

# import mongo data
mkdir ~ec2-user/db/ && cd ~ec2-user/db/
aws s3 cp s3://72fest-backups/prod/mongo/2017/latest-72fest-backup.zip .
unzip latest-72fest-backup.zip
mongorestore --db 72Fest backup/72Fest/

# install node
curl https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
. ~ec2-user/.nvm/nvm.sh
nvm install 8.1.4
npm install -g pm2

# provision services
mkdir -p ~ec2-user/code && cd ~ec2-user/code
git clone https://github.com/72Fest/72FestWebApp.git
cd ~ec2-user/code/72FestWebApp/server/
npm install
aws s3 cp s3://72fest-configs/server/config.json config.json
pm2 start app.config.js


cd ~ec2-user/code
git clone https://github.com/72Fest/72Server.git
cd 72Server
aws s3 cp s3://72fest-configs/server/config.json config.json
npm install
pm2 start app.config.js
