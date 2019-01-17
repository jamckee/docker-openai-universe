FROM ubuntu:16.04


ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/.mujoco/mjpro150/bin

RUN apt-get update \
    && apt-get install -y libav-tools \
    python3-numpy \
    python3-scipy \
    python3-setuptools \
    python3-pip \
    libpq-dev \
    libjpeg-dev \
    curl \
    cmake \
    swig \
    python3-opengl \
    libboost-all-dev \
    libsdl2-dev \
    wget \
    unzip \
    git \
    golang \
    net-tools \
    iptables \
    libvncserver-dev \
    software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/pip3 /usr/local/bin/pip \
    && ln -sf /usr/bin/python3 /usr/local/bin/python \
    && pip install -U pip

# Get the faster VNC driver
RUN pip install go-vncdriver>=0.4.0

# Install pytest (for running test cases)
RUN pip install pytest

# Force the container to use the go vnc driver
ENV UNIVERSE_VNCDRIVER='go'

WORKDIR /usr/local/universe/

# Cachebusting
COPY ./setup.py ./
COPY ./tox.ini ./

# Upload our actual code
COPY . ./
COPY /home/jon/.mujoco /root/.mujoco

# Installed gym without MoJoCo
# RUN pip install gym
# RUN pip install gym[box2d]

# Next section will only work if MuJoCo was installed on the host/building machine
# LIBRARY_PATH /root/.mujoco/mjpro150/bin:${LD_LIBRARY_PATH}
# Install gym
RUN pip install gym[all]

# Run installer
RUN pip install -e .

# Just in case any python cache files were carried over from the source directory, remove them
RUN py3clean .

# Additional cleanup
RUN rm -rf \
/tmp/* \
/var/lib/apt/lists/* \
/var/tmp/*

EXPOSE 12345

VOLUME /root
