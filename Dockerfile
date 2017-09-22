FROM imlzw/centos-jdk8

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
ADD ffmpeg-release-64bit-static.tar.xz /home/download/
#RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-64bit-static.tar.xz
#RUN tar -xvf ffmpeg-release-64bit-static.tar.xz
WORKDIR /home/download/ffmpeg-3.2.4-64bit-static
RUN cp {ffmpeg,ffmpeg-10bit,ffprobe} /usr/bin

#5.安装libreoffice
WORKDIR /home/download
ADD LibreOffice_5.2.5_Linux_x86-64_rpm.tar.gz /home/download/
WORKDIR /home/download/LibreOffice_5.2.5.1_Linux_x86-64_rpm
RUN yum localinstall -y RPMS/*.rpm
RUN yum install -y cairo cups-libs libSM
ENV DISPLAY :0.0
#6.安装xpdf,swftools
WORKDIR /home/download
ADD xpdfbin-linux-3.04.tar.gz /home/download/
ADD swftools-2013-04-09-1007.tar.gz /home/download/
WORKDIR /home/download/xpdfbin-linux-3.04
RUN cp bin64/* /usr/bin
WORKDIR /home/download/swftools-2013-04-09-1007
RUN ./configure --prefix=/usr/swftools && \
    make && make install

#7.设置环境变量
ENV PATH /usr/swftools/bin/:$PATH
ENV OFFICE_ROOT /opt/libreoffice5.2

#8.安装字体，避免转换中文乱码
ADD simsun.ttc /usr/share/fonts/
RUN chmod 644 /usr/share/fonts/simsun.ttc & fc-cache -fv