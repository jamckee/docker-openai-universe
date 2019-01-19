FROM ubuntu:16.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y \
    python3-setuptools \
    python3-opengl \
    #42.5MB
    libpq-dev \
    #20.4MB
    libjpeg-dev \
    libav-tools \
    libsdl2-dev \
    libvncserver-dev \
    libosmesa6-dev \
    cmake \
    golang \
    git \
    #148MB
    libboost-all-dev \
    #libboost-dev \
    #32.3MB
    && apt-get install -y --no-install-recommends \
    python3-dev \
    python3-pip \
    #software-properties-common \
    vim \
    #30.5MB
    && apt-get install -y --no-install-recommends \
    wget \ 
    curl \
    patchelf \
    net-tools \
    iptables \
    unzip \
    swig \
    sudo \
# Install docker CE (Taken from get-docker.sh script)
    apt-transport-https \
    ca-certificates \
    && curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | apt-key add \
    && echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial edge" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce \
# Clear the apt-cache we don't need anymore
    && apt-get clean \ 
    && rm -rf /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

# Create pip symlinks and update pip
RUN ln -sf /usr/bin/pip3 /usr/local/bin/pip \
    && ln -sf /usr/bin/python3 /usr/local/bin/python \
    && pip install -U pip

# Install VNC Dependency
RUN pip install --no-cache-dir numpy \
    && pip install --no-cache-dir go-vncdriver>=0.40 \
# Base gym/gym[all] dependencies
    && pip install --no-cache-dir setuptools pyglet requests scipy six certifi chardet idna urllib3 \
# Next section will only work if MuJoCo was installed on the host/building machine and copied into image
# RUN pip install gym[all]
# Install gym without MuJoCo
    && pip install --no-cache-dir gym==0.9.5 \
# Get the faster VNC driver
    && pip install --no-cache-dir go-vncdriver>=0.4.0 \
# Pytest Dependecnies
    && pip install --no-cache-dir atomicwrites attrs more-itertools pluggy py funcsigs pathlib2 scandir \
# Install pytest (for running test cases)
    && pip install --no-cache-dir pytest \
# Install MuJoCo dependencies but not MuJoCo
    && pip install --no-cache-dir Cython cffi glfw imageio lockfile pycparser enum34 futures pillow \
# Install remaining gym[all] dependencies
    && pip install --no-cache-dir PyOpenGL atari-py box2d-py

# Needs to run after MuJoCo is installed
# Run installer
# RUN pip install -e .

# Get extra dependencies ahead of setup
RUN pip install autobahn>=0.16.0 \
    docker-py==1.10.3 \
    docker-pycreds==0.2.1 \
    fastzbarlight>=0.0.13 \ 
    PyYAML>=3.12 \
    twisted>=16.5.0 \
    ujson>=1.35 \
    h5py \
    keras-applications \
    pachi-py \
    Box2D-kengz \
    keras \
    Theano 

# Switch back to teletype
ENV DEBIAN_FRONTEND teletype

# Force the container to use the go vnc driver
ENV UNIVERSE_VNCDRIVER='go'

# Just in case any python cache files were carried over from the source directory, remove them
RUN py3clean .

# Create universe user
RUN useradd --create-home --shell /bin/bash universe \
    && usermod -aG sudo universe \
    && usermod -aG docker universe \
    && echo "universe ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/universe/.mujoco/mjpro150/bin" >> /home/universe/.bashrc
USER universe

#set our working directory
WORKDIR /home/universe/

# Cachebusting - upload our actual code
COPY . ./
ENV DGROUP=999
#Run our entry script
ENTRYPOINT ["sh","./entry.sh"]
