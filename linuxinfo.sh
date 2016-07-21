#!/usr/bin/ksh
sep()
{
   echo -e "\n\n"                         
   echo -e "--------------------------------------------------------------------------------------------------"
   echo -e "\n\n"                         
}

catfile()
{
        i=$1
	if [ -f $i ]
        then
             echo -e 'File ====> ' $i ' <==== Beginning ======================================================'
             cat $i
             echo -e 'File ====> ' $i ' <==== End       ======================================================'
        else
             echo -e 'File ====> ' $i ' <==== ' "does not exist =============================================="
        fi
}
            

#
# MAIN
#
tar xPzf /var/task/env.tgz
source /tmp/env/bin/activate
aws
/tmp/env/bin/aws
aws s3 ls
aws s3 ls  s3://lambdatestbucket123
echo Starting.....
(
echo -e "Beginnig of Linuxinfo output:\n\n"
echo `hostname`; date; cat /etc/redhat-release /etc/issue 2>/dev/null; sep

sep 'System info:'
ec2=`wget -q -O /dev/null http://169.254.169.254/latest/meta-data && echo "EC2 instance" || echo "Non EC2 instance"`
if [ "$ec2" == "EC2 instance" ]
then
   EC2_instancetype="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-type || die \"wget nstance-type has failed: $?\"`"
   echo "AWS instance type: " $EC2_instancetype
   echo
fi
cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo )
tram=$( free -m | awk 'NR==2 {print $2}' )
swap=$( free -m | awk 'NR==4 {print $2}' )
up=$(uptime|awk '{ $1=$2=$(NF-6)=$(NF-5)=$(NF-4)=$(NF-3)=$(NF-2)=$(NF-1)=$NF=""; print }')
version=$(cat /etc/issue)
kernel=$(uname -a)
echo "CPU model : $cname"
echo "Number of cores : $cores"
echo "CPU frequency : $freq MHz"
echo "Total amount of ram : $tram MB"
echo "Total amount of swap : $swap MB"
echo "System uptime : $up"
echo "System version: $version"
echo "System kernel: $kernel"
echo
lscpu
echo
free -tm
echo
df -h
echo
fdisk -l
echo
netstat -in
echo
ifconfig -a
echo
cat /etc/*-release
echo
lsb_release -a
sep

uname -a; sep

echo -e "Hardware:"
grep processor /proc/cpuinfo; sep
cat /proc/cpuinfo; sep
cat /proc/meminfo; sep
cat /proc/scsi/scsi; sep
cat /proc/slabinfo; sep
/sbin/lspci -v;sep
dmesg;sep


echo -e "Disks:"
df -k; sep
fdisk -l 2>/dev/null | grep Disk; sep
#/sbin/sfdisk -s; sep
#/sbin/sfdisk -l /dev/hda; sep


echo -e "Installed packages:"
uname -a;echo
rpm -qa;sep
yum check-update; sep

echo -e "Number of users in passwd file :" `wc -l /etc/passwd`; sep

echo -e "Current logged on users:\n\n"
w
echo -e "\n\nNumber of users in currently logged in: " `w | sed -n -e '3,$p' | wc -l`; sep

ps -e -o "pid,ppid,user,group,cpu,time,etime,pcpu,vsz,thcount,args" | head -1 ps -e -o "pid,ppid,user,group,cpu,time,etime,pcpu,vsz,thcount,args" | sort +7nr
echo -e "\n\n\n"                         
p=`ps -ef | wc | awk ' { print $1 } ' `
echo -e "Current number of processes:" `expr $p - 1 ` sep

echo -e "ipcs:\n\n"
ipcs -ma
sep

echo -e "Paging information:\n\n"
free -m
sep

echo -e "Total filesystem size\n\n"
df  | grep -v Filesystem | awk ' { a+=$2; b+=$3; c+=$4; print "Total             " a "   " b "    " c } ' | tail -1
df  | grep -v 'Filesystem' | grep '^/dev' | awk ' { a+=$2; b+=$3; c+=$4; print "Total without NFS " a "   " b "    " c } ' | tail -1
sep

echo -e "Disk & Filesystem information\n\n"
catfile /etc/fstab; sep
df -g; sep
vgdisplay -v; sep
vgs
lvs
pvs
sep

echo -e "Container?:\n\n"
cat /proc/1/cgroup

echo -e "Services\n\n"
chkconfig --list; sep
who -r;
ls -l /etc/rc.d/rc5.d; sep

echo -e "Networking information:\n\n"
/sbin/ifconfig -a
echo -e "\n\n\n"                         
netstat -i
echo -e "\n\n\n"                         
netstat -in
echo -e "\n\n\n"                         
netstat -nr
echo -e "\n\n\n"                         
netstat -v
echo -e "\n\n\n"                         
netstat -an
echo -e "\n\n\n"                         
sep

catfile /etc/hosts; sep

vmstat 5 5; sep 

sar -u 5 5; sep

sar -P ALL 5 5; sep

iostat -xd 5 5; sep 

echo -e "Today's CPU performance statistics:\n\n"
uptime
sar -u
sep

sep 'Global network bandwidth:'
ping -c 5 cachefly.cachefly.net
echo
echo
traceroute cachefly.cachefly.net
echo
cachefly=$( wget -O /dev/null http://cachefly.cachefly.net/100mb.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from CacheFly: $cachefly "


echo -e "Quick & Dirt benchmark:"
time bc > /dev/null <<!
sqrt(1234^1234)^12
!
sep


echo -e "Cron:\n\n"
crontab -l
sep


echo -e "Environment variables:\n\n"
set
echo
echo -e '$PATH:'  "$PATH \n\n\n"       
echo -e '$MANPATH:'  "$MANPATH \n\n\n"       
sep

echo -e "Security:\n\n"
chage -l root; echo


echo -e "All Cron entries:\n\n"
ls -laR /var/spool/cron
echo "\n\n"
for i in `echo /var/spool/cron/*`
do
    catfile $i
done



echo -e "Important files:\n\n"
for i in /etc/motd /etc/hosts /etc/fstab /etc/profile /etc/nsswitch.conf /etc/resolv.conf /.rhosts /etc/bootptab /etc/exports /etc/passwd /etc/group /etc/syslog.conf /etc/ssh/sshd.conf /etc/mail/sendmail.cf /etc/sysconfig/network `echo /etc/sysconfig/network-scripts/if*eth*` `echo /etc/sysconfig/network-scripts/if*bond*` /sys/class/net/bond0/bonding/mode /etc/inittab /etc/ntp.conf /etc/multipath.conf /etc/selinux/config /etc/sysconfig/ip6tables /etc/hosts.allow /etc/hosts.deny /etc/sysctl.conf /etc/modprobe.conf /boot/grub/grub.conf /etc/kdump.conf /etc/sudoers /etc/pam.d/system-auth /etc/security/limits.conf /etc/yum.conf
do
     catfile $i
     sep
done


echo -e "\n\nEnd of Linuxinfo output"
aws s3 ls
aws s3 ls  s3://lambdatestbucket123
) > lambda.out 2>&1

aws s3 cp  lambda.out s3://lambdatestbucket123/lambda.out
exit 0
