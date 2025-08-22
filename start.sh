#! /bin/bash


# Change arguments here
export NEOFORGE_VERSION=21.1.201
export JAVA=/usr/lib/jvm/java-21-openjdk-amd64/bin/java


export LOCKFILE=minecraft.pid

if [ -f $LOCKFILE ]
then
echo 'it looks like minecraft is already running'
echo 'if you think that is wrong and theres a stale lockfile, here is the process:'
ps `cat $LOCKFILE`
echo '====='
echo "if there is no process, delete $LOCKFILE and run this script again"
exit
fi

# remove the lock file if control-c
trap "rm -f $LOCKFILE; exit" INT TERM EXIT

echo $$ > $LOCKFILE

while true;
do

ulimit -a

$JAVA @user_jvm_args.txt @libraries/net/neoforged/neoforge/$NEOFORGE_VERSION/unix_args.txt nogui

#rm world/minecolonies/*.zip

~/bin/backup-minecraft-full.sh

cd mods/
ls -lh *.jar > mods.txt
cd ..

git add .
git commit -m "Sync from Server."
git push

echo restarting in 5 seconds...
sleep 1
echo restarting in 4 seconds...
sleep 1
echo restarting in 3 seconds...
sleep 1
echo restarting in 2 seconds...
sleep 1
echo restarting in 1 second...
sleep 1

done

rm -f $LOCKFILE
