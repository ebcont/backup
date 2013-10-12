#install backup

apt-get install git
mkdir -p /root/bin/git/backup
cd /root/bin/git/backup
git init
git --work-tree=/root/bin/git/backup/ --git-dir=/root/bin/git/backup/.git/ pull https://github.com/ebcont/backup.git

cp /root/bin/git/backup/credentials /root/bin/
chmod 700 /root/bin/credentials


