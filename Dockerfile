FROM ubuntu:18.04

COPY build/java_policy /etc
RUN export DEBIAN_FRONTEND=noninteractive
    buildDeps='software-properties-common git libtool cmake python-dev python3-pip python-pip libseccomp-dev wget curl' && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get update && apt-get install -y python python3 python-pkg-resources python3-pkg-resources $buildDeps && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && apt-get update && apt-get install -y gcc-9 g++-9 && \
    rm /usr/bin/gcc /usr/bin/g++ && ln -s /usr/bin/gcc-9 /usr/bin/gcc && ln -s /usr/bin/g++-9 /usr/bin/g++ && \
    add-apt-repository ppa:openjdk-r/ppa && add-apt-repository ppa:longsleep/golang-backports && add-apt-repository ppa:ondrej/php && \
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get update && apt-get install -y golang-go openjdk-8-jdk php-cli nodejs && \
    wget -O pypy3.7-v7.3.5-linux64.tar.bz2 https://downloads.python.org/pypy/pypy3.7-v7.3.5-linux64.tar.bz2 && tar -jxvf pypy3.7-v7.3.5-linux64.tar.bz2 && rm pypy3.7-v7.3.5-linux64.tar.bz2 && mv pypy3.7-v7.3.5-linux64 /usr/lib/pypy3.7 && ln -s /usr/lib/pypy3.7/bin/pypy3 /usr/bin/pypy3  && \
    wget -O pypy2.7-v7.3.5-linux64.tar.bz2 https://downloads.python.org/pypy/pypy2.7-v7.3.5-linux64.tar.bz2 && tar -jxvf pypy2.7-v7.3.5-linux64.tar.bz2 && rm pypy2.7-v7.3.5-linux64.tar.bz2 && mv pypy2.7-v7.3.5-linux64 /usr/lib/pypy2.7 && ln -s /usr/lib/pypy2.7/bin/pypy /usr/bin/pypy  && \
    phpJitOption='opcache.enable=1\nopcache.enable_cli=1\nopcache.jit=1205\nopcache.jit_buffer_size=64M' && \
    echo $phpJitOption > /etc/php/8.0/cli/conf.d/10-opcache-jit.ini && \
    pip3 install -I --no-cache-dir psutil gunicorn flask requests idna && \
    cd /tmp && git clone -b newnew  --depth 1 https://github.com/Harry-zklcdc/Judger.git && cd Judger && \
    mkdir build && cd build && cmake .. && make && make install && cd ../bindings/Python && python3 setup.py install && \
    apt-get purge -y --auto-remove $buildDeps && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /code && \
    useradd -u 12001 compiler && useradd -u 12002 code && useradd -u 12003 spj && usermod -a -G code spj
HEALTHCHECK --interval=5s --retries=3 CMD python3 /code/service.py
ADD server /code
WORKDIR /code
RUN gcc -shared -fPIC -o unbuffer.so unbuffer.c
EXPOSE 8080
ENTRYPOINT /code/entrypoint.sh
