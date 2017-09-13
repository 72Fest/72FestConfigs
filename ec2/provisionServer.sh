# set up firewall
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
sudo yum install -y git.x86_64 mongodb-org-server mongodb-org-shell mongodb-org-tools
sudo service mongod start

# install node
https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install 8.1.4
npm install -g forever

# provision service
mkdir code && cd code
git clone https://github.com/72Fest/72FestWebApp.git
cd 72FestWebApp/server/
npm install
aws s3 cp s3://72fest-configs/server/config.json config.json
forever start forever.json
