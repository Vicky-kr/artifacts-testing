FROM databricksruntime/python:14.3-LTS

RUN apt-get update && apt-get install -y \
    # these needed for subsequent downloads/installs
    curl \
    unzip \
    wget \
    # java is needed to run the browsermob-proxy
    openjdk-11-jre \
    # libgeos is a prerequisite of pip module "shapely"
    libgeos-c1v5 \
    # mapping tools
    # osmctools provides ogr2ogr
    gdal-bin \
    # osmctools provides osmconvert and osmfilter
    osmctools

RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt install -y ./google-chrome-stable_current_amd64.deb \
    && rm ./google-chrome-stable_current_amd64.deb

# needed for chrome browser automation
RUN wget -q https://storage.googleapis.com/chrome-for-testing-public/$(curl https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE)/linux64/chromedriver-linux64.zip -O /usr/local/bin/chromedriver_linux64.zip \
    && cd /usr/local/bin \
    && unzip -oj chromedriver_linux64.zip \
    && rm chromedriver_linux64.zip

# needed for spying on HTTP traffic during browser automation
RUN wget -q https://github.com/lightbody/browsermob-proxy/releases/download/browsermob-proxy-2.1.4/browsermob-proxy-2.1.4-bin.zip -O /usr/local/bmp.zip \
    && cd /usr/local/ \
    && unzip -o bmp.zip \
    && rm /usr/local/bmp.zip

### DATABRICKS DOCKERFILE
WORKDIR /test-datalake-databricks

COPY requirements.txt .

RUN /databricks/python3/bin/pip install -r ./requirements.txt
