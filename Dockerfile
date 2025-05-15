FROM python:3.8-slim-buster

# pre-empt bug in java install
RUN mkdir -p /usr/share/man/man1

RUN apt-get update && apt-get install -y \
    # these needed for subsequent downloads/installs
    curl \
    unzip \
    wget \
    gnupg \
    # java is needed to run the browsermob-proxy
    openjdk-11-jre \
    # libgeos is a prerequisite of pip module "shapely"
    libgeos-c1v5 \
    # mapping tools
    # osmctools provides ogr2ogr
    gdal-bin \
    # osmctools provides osmconvert and osmfilter
    osmctools \
    # requirements for OpenVPN
    openvpn \
    # requirements for pyodbc
    build-essential \
    unixodbc-dev \
    python-dev

# PETER & AMRICK HACKATHON 2023 REQS
RUN apt-get -y update && apt-get -y upgrade && apt-get install -y --no-install-recommends ffmpeg
RUN DEBIAN_FRONTEND="noninteractive" apt-get install libmagickwand-dev --no-install-recommends -y

RUN curl -o /usr/local/share/ca-certificates/DigiCertTLSRSA4096RootG5.crt https://cacerts.digicert.com/DigiCertTLSRSA4096RootG5.crt.pem && update-ca-certificates

# needed for chrome browser automation
RUN wget -q https://storage.googleapis.com/chrome-for-testing-public/133.0.6943.53/linux64/chromedriver-linux64.zip -O /usr/local/bin/chromedriver_linux64.zip \
    && cd /usr/local/bin \
    && unzip -oj chromedriver_linux64.zip \
    && rm chromedriver_linux64.zip

# Add Google Chrome's repository - needed for browser automation with chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
# Install specific version of Google Chrome
RUN apt-get update && apt-get install -y \
    google-chrome-stable \
    --no-install-recommends
# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# needed for spying on HTTP traffic during browser automation
RUN wget -q https://github.com/lightbody/browsermob-proxy/releases/download/browsermob-proxy-2.1.4/browsermob-proxy-2.1.4-bin.zip -O /usr/local/bmp.zip \
    && cd /usr/local/ \
    && unzip -o bmp.zip \
    && rm /usr/local/bmp.zip

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
