#base on docker centos 
FROM centos:7

#AUTHOR
MAINTAINER imlzw <imlzw@imlzw.com>

#安装wget
RUN yum install -y wget

#更换yum源 
RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
	&& wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
	&& yum clean all \
	&& yum makecache 
	
#安装工具集
RUN yum install -y zlib zlib-devel pcre pcre-devel gcc gcc-c++ openssl openssl-devel libevent libevent-devel perl unzip net-tools git

#环境变量
ENV JAVA_VERSION 8u144
ENV JAVA_BUILD b01
ENV JAVA_HOME /usr/java/jdk1.8.0_144

# http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.rpm
# 安装jdk
RUN curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}-${JAVA_BUILD}/090f390dda5b47b9b721c7dfaa008135/jdk-${JAVA_VERSION}-linux-x64.rpm > /tmp/jdk-linux-x64.rpm && \
    yum -y install /tmp/jdk-linux-x64.rpm && \
    rm /tmp/jdk-linux-x64.rpm && \
    yum clean all

#安装 graphicsImagick
#1.创建目录
RUN mkdir -p /home/download

#2.安装libjpeg,libpng...
RUN yum install -y libpng-devel libjpeg-devel libtiff-devel jasper-devel freetype-devel

#3.安装graphicsImagick
WORKDIR /home/download
RUN wget http://ftp.icm.edu.pl/pub/unix/graphics/GraphicsMagick/1.3/GraphicsMagick-1.3.25.tar.gz
RUN tar -xvf GraphicsMagick-1.3.25.tar.gz
WORKDIR /home/download/GraphicsMagick-1.3.25
RUN ./configure \
    && make && make install

#4.安装ffmpeg
WORKDIR /home/download
#ADD ffmpeg-release-64bit-static.tar.xz /home/download/
# https://www.ffmpeg.org/releases/ffmpeg-3.2.8.tar.gz
# ffmpeg-static下载的版本可能和配置的不对应
RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz
RUN tar -xvf ffmpeg-release-64bit-static.tar.xz
WORKDIR /home/download/ffmpeg-3.3.4-64bit-static
RUN cp {ffmpeg,ffmpeg-10bit,ffprobe} /usr/bin

#5.安装libreoffice
WORKDIR /home/download
# ADD LibreOffice_5.2.5_Linux_x86-64_rpm.tar.gz /home/download/
# RUN wget http://download.documentfoundation.org/libreoffice/stable/5.3.6/rpm/x86_64/LibreOffice_5.3.6_Linux_x86-64_rpm.tar.gz
RUN wget http://ftp.rz.tu-bs.de/pub/mirror/tdf/tdf-pub/libreoffice/stable/5.2.5/rpm/x86_64/LibreOffice_5.2.5_Linux_x86-64_rpm.tar.gz
RUN tar -xvf LibreOffice_5.2.5_Linux_x86-64_rpm.tar.gz
WORKDIR /home/download/LibreOffice_5.2.5.1_Linux_x86-64_rpm
RUN yum localinstall -y RPMS/*.rpm
RUN yum install -y cairo cups-libs libSM
ENV DISPLAY :0.0

#6.安装xpdf,swftools
WORKDIR /home/download

# RUN wget ftp://ftp.foolabs.com/pub/xpdf/xpdfbin-linux-3.04.tar.gz
# RUN tar -xvf xpdfbin-linux-3.04.tar.gz
ADD xpdfbin-linux-3.04.tar.gz /home/download/
WORKDIR /home/download/xpdfbin-linux-3.04
RUN cp bin64/* /usr/bin
# RUN wget http://www.swftools.org/swftools-2013-04-09-1007.tar.gz
# RUN tar -xvf swftools-2013-04-09-1007.tar.gz
ADD swftools-2013-04-09-1007.tar.gz /home/download/
WORKDIR /home/download/swftools-2013-04-09-1007
RUN ./configure --prefix=/usr/swftools && \
    make && make install

#7.设置环境变量
ENV PATH /usr/swftools/bin/:$PATH
ENV OFFICE_ROOT /opt/libreoffice5.2

#8.安装字体，避免转换中文乱码
ADD simsun.ttc /usr/share/fonts/
RUN chmod 644 /usr/share/fonts/simsun.ttc & fc-cache -fv