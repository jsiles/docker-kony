FROM centos:7
RUN yum -y install epel-release
RUN yum -y update
RUN yum -y install nginx
ADD index.html /usr/share/nginx/html/index.html
COPY  QuantumFabric_Installer_Linux/* /tmp/
EXPOSE 80/tcp
CMD ["nginx", "-g daemon off;"]