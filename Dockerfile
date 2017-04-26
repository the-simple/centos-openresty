FROM centos:7

MAINTAINER Aleksandr Lykhouzov <lykhouzov@gmail.com>
ENV LUA_VERSION 5.3.4
RUN echo $'[nginx]\n\
name=nginx repo\n\
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/\n\
gpgcheck=0\n\
enabled=1\n\
' | tee /etc/yum.repos.d/nginx.repo;\
echo $'[openresty]\n\
name=Official OpenResty Repository\n\
baseurl=https://copr-be.cloud.fedoraproject.org/results/openresty/openresty/epel-$releasever-$basearch/\n\
skip_if_unavailable=True\n\
gpgcheck=1\n\
gpgkey=https://copr-be.cloud.fedoraproject.org/results/openresty/openresty/pubkey.gpg\n\
enabled=1\n\
enabled_metadata=1\n\
' | tee /etc/yum.repos.d/openresty.repo;\
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
# Install OpenResty
&& yum -y update && yum -y install make gcc readline-devel ;\
curl -L http://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz | tar xzf - && \
cd /lua-${LUA_VERSION} && \
make linux test && \
make install && \
cd .. && rm -rf /lua-${LUA_VERSION} &&\
yum install -y \
nginx luajit luajit-fun inotify-tools openresty \
openresty-{openssl,opm,pcre,resty,zlib,valgrind} \
lua-{fun,json,lpeg,ldap,lunit,md5} source-highlight \
&& yum clean all

EXPOSE 80 443
CMD ["openresty","-g","daemon off;"]
