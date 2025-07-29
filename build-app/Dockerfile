FROM eclipse-temurin:11.0.27_6-jdk-noble



RUN apt update
RUN apt install -y git


# Install MAVEN
RUN wget https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz -P /tmp 
RUN tar -xzf /tmp/apache-maven-3.9.11-bin.tar.gz -C /opt
RUN ln -s /opt/apache-maven-3.9.11 /opt/maven
RUN rm /tmp/apache-maven-3.9.11-bin.tar.gz
ENV MAVEN_HOME=/opt/maven
ENV PATH="${MAVEN_HOME}/bin:${PATH}"

RUN mkdir -p /opt/secretariavirtual/app/secretaria-virtual-private
RUN mkdir -p /opt/secretariavirtual/data

# EducaFlowBuildTools: Compilar y publicar en Maven en local
WORKDIR /opt/secretariavirtual/app
RUN git clone https://github.com/educaflow/EducaFlowBuildTools.git
WORKDIR /opt/secretariavirtual/app/EducaFlowBuildTools
RUN ./install.sh

# Axelor Open Platform: Compilar y publicar en Maven en local
WORKDIR /opt/secretariavirtual/app
RUN git clone https://github.com/educaflow/axelor-open-platform.git
WORKDIR /opt/secretariavirtual/app/axelor-open-platform
RUN ./install.sh

EXPOSE 8080

COPY ./deploy.sh /opt/secretariavirtual/app
WORKDIR /opt/secretariavirtual/app
CMD ["./deploy.sh"]
