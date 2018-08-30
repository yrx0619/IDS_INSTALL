#!/bin/bash
set -e

main_dir="/ids/"
pf_ring_tar="PF_RING-7.0.0-stable-CrackedVer1.tar.gz" 
suricata_tar="suricata-4.0.3.tar.gz"
pf_ring_dir="PF_RING-7.0.0-stable"
suricata_dir="suricata-4.0.3"

sudo yum install gcc cmake -y

cd $main_dir
echo "############################################"
echo "#                                          #"
echo "#          install PF_RING                 #"
echo "#                                          #"
echo "############################################"
if [ ! -d "$pf_ring_dir" ]
then 
    tar -xzvf $pf_ring_tar
fi 

if [ ! -d "$suricata_dir" ]
then
    tar -xzvf $suricata_tar
fi

sudo rmmod ixgbe

cd $pf_ring_dir/kernel

make

sudo make install

cd ../userland/lib

./configure

make

sudo make install

cd ../libpcap-1.8.1/

./configure

make

sudo make install

cd ../../drivers/intel/ixgbe/ixgbe-5.0.4-zc/src/

make

sudo make install

ret=`echo $?`

if [ "$ret" -eq 0 ]
then
    echo -e "\e[0;32m##############PF_RING install sucessfully###################\e[0m"
fi

sudo ./load_driver.sh

cd $main_dir


echo "############################################"
echo "#                                          #"
echo "#          install hiredis                 #"
echo "#                                          #"
echo "############################################"

if [ ! -d "hiredis" ]
then
    git clone https://github.com/redis/hiredis.git  
fi

cd hiredis/  

make

sudo make install  

ret=`echo $?`

if [ "$ret" -eq 0 ]
then
    echo -e "\e[0;32m##############hiredis install sucessfully###################\e[0m"
fi

sudo yum install python-devel -y

sudo yum install libquadmath -y

sudo yum install libquadmath-devel -y

sudo yum install bzip2-devel -y

sudo yum install cmake ragel -y

sudo yum install boost-devel -y

cd $main_dir


echo "############################################"
echo "#                                          #"
echo "#          install boost.1.60              #"
echo "#                                          #"
echo "############################################"

if [ ! -f "boost_1_60_0.tar.gz" ]
then
    wget http://downloads.sourceforge.net/project/boost/boost/1.60.0/boost_1_60_0.tar.gz
fi

tar xvzf boost_1_60_0.tar.gz

cd boost_1_60_0

boost_dir="~/tmp/boost-1.60"

if [ ! -d "$boost_dir" ]
then
    mkdir -p $boost_dir
fi

./bootstrap.sh --prefix=~/tmp/boost-1.60

./b2 install

ret=`echo $?`

if [ "$ret" -eq 0 ]
then
    echo -e "\e[0;32m##############boost install sucessfully###################\e[0m"
fi


cd $main_dir

echo "############################################"
echo "#                                          #"
echo "#          install hyperscan               #"
echo "#                                          #"
echo "############################################"

if [ ! -d "hyperscan" ]
then
git clone https://github.com/01org/hyperscan
fi

cd hyperscan

if [ ! -d "build" ]
then
    mkdir build
fi

cd build

cmake -DBUILD_STATIC_AND_SHARED=1 -DBOOST_ROOT=/home/yeruoxi/tmp/boost-1.60 ../

make

sudo make install

ret=`echo $?`

if [ "$ret" -eq 0 ]
then
    echo -e "\e[0;32m##############hyperscan install sucessfully###################\e[0m"
fi


sudo yum install wget libpcap-devel libnet-devel pcre-devel gcc-c++ automake autoconf libtool make libyaml-devel zlib-devel file-devel jansson-devel nss-devel  libevent-devel lua-devel GeoIP-devel gperftools-libs -y

cd $main_dir/$suricata_dir/


echo "############################################"
echo "#                                          #"
echo "#          install suricata                #"
echo "#                                          #"
echo "############################################"

./configure --enable-lua --enable-pfring --enable-old-barnyard2 --enable-hiredis --enable-unix-socket --enable-profiling --enable-geoip --with-libnss-libraries=/usr/lib64 --with-libnss-includes=/usr/include/nss3 --with-libnspr-libraries=/usr/lib64 --with-libnspr-includes=/usr/include/nspr4 --enable-pfring --with-libpfring-includes=/usr/local/include --with-libpfring-libraries=/usr/local/lib --with-libhs-includes=/usr/local/include/hs/ --with-libhs-libraries=/usr/local/lib/

make

sudo make install

ret=`echo $?`

if [ "$ret" -eq 0 ]
then
    echo -e "\e[0;32m##############suricata install sucessfully###################\e[0m"
fi


echo "/usr/local/lib64" | sudo tee --append /etc/ld.so.conf.d/usrlocal.conf


sudo ldconfig


echo "##############install finished###################"
echo -e "\e[0;32myou have installed IDS successfully!!!\e[0m"
echo "################################################"

