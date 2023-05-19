FROM georgestagg/webr-flang:latest

ARG NVM_VERSION=v0.39.3
ARG WEBR_VERSION=v0.1.1

ENV NVM_DIR /opt/nvm

# Install NVM and Node
RUN mkdir -p ${NVM_DIR} \
  && curl https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash \
  && . ${NVM_DIR}/nvm.sh \
  && nvm install --lts \
  && nvm use --lts

# Download webR
RUN git clone --depth 1 --branch ${WEBR_VERSION} \
  https://github.com/r-wasm/webr.git /opt/webr

# Setup LLVM flang
RUN cd /opt/webr \
  && ./configure \
  && ln -s /opt/flang/wasm wasm \
  && ln -s /opt/flang/host host \
  && cp /opt/flang/emfc ./host/bin/emfc

# Setup Emscripten
ENV PATH /opt/emsdk:/opt/emsdk/upstream/emscripten:$PATH
ENV EMSDK /opt/emsdk

# Build required and optional wasm libs
RUN apt update && apt install -y sqlite3
RUN . ${NVM_DIR}/nvm.sh \
  && export EM_NODE_JS=${NVM_BIN}/node \
  && cd /opt/webr/libs \
  && make all

# Build webr
RUN . ${NVM_DIR}/nvm.sh \
  && export EM_NODE_JS=${NVM_BIN}/node \
  && cd /opt/webr \
  && make
