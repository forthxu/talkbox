talkbox
====

a talkbox build with skynet

download flash client src http://pan.baidu.com/s/1sjscngT

实例
http://forthxu.com/c/

云风skynet服务端框架研究
http://forthxu.com/blog/skynet.html

安装
git clone git@github.com:forthxu/talkbox.git talkbox

wget https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz
tar zxf protobuf-2.5.0.tar.gz 
cd protobuf-2.5.0
./configure --prefix=/opt/local/protobuf-2.5.0
make
make install
ln -s /opt/local/protobuf-2.5.0/bin/protoc /usr/bin/protoc

cd ../talkbox
bash start.sh
