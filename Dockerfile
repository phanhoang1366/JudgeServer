FROM debian:bullseye-slim

COPY build/java_policy /etc
RUN export DEBIAN_FRONTEND=noninteractive && \
    buildDeps='git libtool cmake python-dev python3-pip libseccomp-dev wget curl' && \
    apt-get update && apt-get install -y gnupg ca-certificates tzdata python python3 python-pkg-resources python3-pkg-resources $buildDeps && \
    apt-get install -y gcc-9 g++-9 && \
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y golang-1.15 openjdk-11-jdk nodejs mono-mcs fp-compiler fp-units-base fp-units-fcl fp-units-misc fp-units-math fp-units-rtl --no-install-recommends && \
#    wget https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20amd64%20DEB/Lazarus%202.2.2/fpc-laz_3.2.2-210709_amd64.deb && \
#    apt install -y ./fpc-laz_3.2.2-210709_amd64.deb && rm -rf fpc-laz_3.2.2-210709_amd64.deb && \
    ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    pip3 install -I --no-cache-dir psutil gunicorn flask requests idna && \
    cd /tmp && git clone -b newnew  --depth 1 https://github.com/QingdaoU/Judger.git && cd Judger && \
    wget https://raw.githubusercontent.com/phanhoang1366/JudgeServer/bullseye-slim/0001-patch.patch && \
    git config  user.email "johndoe@example.com" && git config user.name "John Doe" && git am 0001-patch.patch && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 10 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 10 && \
    mkdir build && cd build && cmake .. && make && make install && cd ../bindings/Python && python3 setup.py install && \
    apt-get purge -y --auto-remove $buildDeps && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/Judger/ && \
    mkdir -p /code && \
    useradd -u 12001 compiler && useradd -u 12002 code && useradd -u 12003 spj && usermod -a -G code spj
HEALTHCHECK --interval=5s --retries=3 CMD python3 /code/service.py
ADD server /code
WORKDIR /code
RUN gcc -shared -fPIC -o unbuffer.so unbuffer.c
EXPOSE 8080
ENTRYPOINT /code/entrypoint.sh
