FROM ubuntu:20.04
RUN apt-get update -y
COPY . /app
WORKDIR /app
RUN set -xe \
    && apt-get update -y \
    && apt-get install -y python3-pip \
    && apt-get install -y mysql-client 
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
EXPOSE 8080
# Wait for MySQL to be ready before running the app
CMD ["sh", "-c", "echo 'Waiting for MySQL...' && sleep 40 && python3 app.py"]
