FROM centos
MAINTAINER xdays <easedays@gmail.com>

ENV OPENRESTY_ROOT="/usr/local/openresty"
ENV OPENRESTY_VERSION="1.9.15.1"
ENV LUAROCKS_VERSION="2.3.0"
ENV PATH=$OPENRESTY_ROOT/luajit/bin:$PATH 

ADD openresty.repo /etc/yum.repos.d/

RUN yum install -y openresty-${OPENRESTY_VERSION} epel-release gcc make wget \
    unzip git perl cmake pcre-devel python-devel libffi-devel openssl-devel pam-devel && yum clean all
RUN mkdir -p /src && cd /src && \
    wget http://keplerproject.github.io/luarocks/releases/luarocks-$LUAROCKS_VERSION.tar.gz && \
    tar xzf luarocks-$LUAROCKS_VERSION.tar.gz && \
    ln -snf $OPENRESTY_ROOT/nginx/conf /etc/nginx && \
    ln -snf $OPENRESTY_ROOT/nginx/sbin/nginx /usr/local/sbin && \
    ln -s $OPENRESTY_ROOT/luajit/bin/luajit $OPENRESTY_ROOT/luajit/bin/lua && \
    cd luarocks-$LUAROCKS_VERSION && \
    ./configure --prefix=$OPENRESTY_ROOT/luajit --with-lua=$OPENRESTY_ROOT/luajit \
    --with-lua-include=$OPENRESTY_ROOT/luajit/include/luajit-2.1/ && make install && \
    for i in luasec luacrypto basexx lua-resty-http;do luarocks install $i;done && \
    rm -rf /src

ADD app ${OPENRESTY_ROOT}/nginx/app
ADD nginx.conf /etc/nginx/

WORKDIR $OPENRESTY_ROOT
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
