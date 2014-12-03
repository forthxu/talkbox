talkbox
====

a talkbox build with skynet

download flash client src http://pan.baidu.com/s/1sjscngT

### 实例
http://forthxu.com/skynet/
### 云风skynet服务端框架研究
http://forthxu.com/blog/skynet.html
### 服务端安装
    # clone
    git clone git@github.com:forthxu/talkbox.git talkbox
    
    # 安装protobuf
    wget https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz
    tar zxf protobuf-2.5.0.tar.gz 
    cd protobuf-2.5.0
    ./configure --prefix=/opt/local/protobuf-2.5.0
    make
    make install
    ln -s /opt/local/protobuf-2.5.0/bin/protoc /usr/bin/protoc
    
    # 启动
    cd ../talkbox
    bash start.sh
### 客户端
https://github.com/forthxu/talkbox_client


