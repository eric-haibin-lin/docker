FROM nvidia/cuda:10.0-devel

ENV DEBIAN_FRONTEND="noninteractive"

# update apt
RUN apt-get update

# install general dependencies
RUN apt-get install -y python3-pip wget git autoconf libtool nvidia-modprobe \
    software-properties-common cmake openssh-server openssh-client numactl

# install awscli
RUN pip3 install awscli h5py

# setup cluster user and SSH access to container
ENV USER cluster
RUN useradd -ms /bin/bash $USER && usermod -p '*' $USER
ENV HOME /home/$USER
ENV SSHDIR $HOME/.ssh
RUN mkdir -p ${SSHDIR} \
    && touch ${SSHDIR}/sshd_config \
    && ssh-keygen -t rsa -f ${SSHDIR}/ssh_host_rsa_key -N '' \
    && cp ${SSHDIR}/ssh_host_rsa_key.pub ${SSHDIR}/authorized_keys \
    && cp ${SSHDIR}/ssh_host_rsa_key ${SSHDIR}/id_rsa \
    && echo "    IdentityFile ${SSHDIR}/id_rsa" >> ${SSHDIR}/config \
    && echo "    StrictHostKeyChecking no" >> ${SSHDIR}/config \
    && echo "    UserKnownHostsFile /dev/null" >> ${SSHDIR}/config \
    && echo "    Port 2022" >> ${SSHDIR}/config \
    && echo 'Port 2022' >> ${SSHDIR}/sshd_config \
    && echo "HostKey ${SSHDIR}/ssh_host_rsa_key" >> ${SSHDIR}/sshd_config \
    && echo "PidFile ${SSHDIR}/sshd.pid" >> ${SSHDIR}/sshd_config \
    && echo "PasswordAuthentication no" >> ${SSHDIR}/sshd_config \
    && chmod -R 600 ${SSHDIR}/* \
    && chown -R ${USER}:${USER} ${SSHDIR}/

# set path for ssh user
RUN echo "export PATH=\"/usr/local/cuda/bin:/opt/amazon/openmpi/bin:\$PATH\"" > $HOME/.bashrc

WORKDIR /opt/build

# Run EFA installer
RUN wget -q https://s3-us-west-2.amazonaws.com/aws-efa-installer/aws-efa-installer-latest.tar.gz && \
    tar -xzf aws-efa-installer-latest.tar.gz && \
    cd aws-efa-installer && \
    ./efa_installer.sh -y --skip-kmod --skip-limit-conf --debug-packages

ENV PATH="/usr/local/cuda/bin:/opt/amazon/openmpi/bin:$PATH"

# Build NCCL library
RUN git clone https://github.com/NVIDIA/nccl.git && cd nccl && /bin/bash && \
    make -j src.build CUDA_HOME=/usr/local/cuda && \
    make install

# Build AWS OFI NCCL plugin
RUN git clone https://github.com/aws/aws-ofi-nccl.git -b aws && \
    cd aws-ofi-nccl && \
    ./autogen.sh && \
    ./configure --with-libfabric=/opt/amazon/efa --with-cuda=/usr/local/cuda \
        --with-nccl=/usr/local --with-mpi=/opt/amazon/openmpi && \
    PATH=/opt/amazon/openmpi/bin:$PATH make && \
    make install

# Install nccl-tests
RUN git clone https://github.com/NVIDIA/nccl-tests.git && \
    cd nccl-tests && \
    make MPI=1 MPI_HOME=/opt/amazon/openmpi \
    CUDA_HOME=/usr/local/cuda \
    NCCL_HOME=/usr/local

RUN apt-get install -y pandoc

RUN pip3 install --no-cache-dir gpustat portalocker torch==1.1.0

# Install MXNet 
# this pip wheel is built based on https://github.com/apache/incubator-mxnet/tree/benchmark COMMIT cc0c356
#ENV MXNETVERSION https://lnyuan-mxnet.s3-us-west-2.amazonaws.com/mxnet-benchmark/mxnet_cu100-1.6.0b20191129-py2.py3-none-manylinux1_x86_64.whl
ENV MXNETVERSION mxnet_cu100-1.6.0b20200224-py2.py3-none-manylinux1_x86_64.whl
COPY $MXNETVERSION .
RUN pip3 install $MXNETVERSION numpy==1.16

# Install horovod
RUN HOROVOD_GPU_ALLREDUCE=NCCL \
    HOROVOD_WITH_MPI=1 \
    HOROVOD_CUDA_HOME=/usr/local/cuda \
    HOROVOD_WITHOUT_TENSORFLOW=1 HOROVOD_WITHOUT_PYTORCH=1 HOROVOD_WITH_MXNET=1 \
    LD_LIBRARY_PATH=/usr/local/cuda/compat \
    pip3 install --no-cache-dir horovod

RUN git clone -b nvidia https://github.com/eric-haibin-lin/gluon-nlp && cd gluon-nlp && pip3 install . --user

# Copy benchmarking scripts
COPY benchmarks/* /opt/benchmarks/
WORKDIR /opt/benchmarks

# Set environment variables so nvidia-docker will expose GPUs
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=430,driver<431"
ENV PATH /usr/local/cuda/bin:/opt/amazon/openmpi/bin:$PATH

COPY container_entrypoint.sh /etc/
ENTRYPOINT /etc/container_entrypoint.sh

EXPOSE 2022
