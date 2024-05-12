FROM osrf/ros:noetic-desktop-full

COPY sources.list /etc/apt/sources.list

RUN apt-get update \
  && apt-get install -y \
  vim \
  curl \
  wget \
  git \
  sudo \
  tar \
  ripgrep

ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && mkdir /home/$USERNAME/.config && chown $USER_UID:$USER_GID /home/$USERNAME/.config

RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME

USER ros
RUN cd \
  && mkdir bin && cd bin \
  && wget https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz \
  && tar -xf nvim-linux64.tar.gz \
  && ln -s nvim-linux64/bin/nvim nvim

RUN cd && cd .config\
  && git clone https://github.com/miraculin1/nvim_config.git \
  && mv nvim_config nvim \
  && curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

USER root
RUN apt-get update \
  && apt-get install -y \
  tmux \
  unzip \
  ranger \
  software-properties-common \
  tar \
  && rm -rf /var/lib/apt/lists/*

USER ros
RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

USER root
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
COPY ./.tmux.conf /home/ros/.tmux.conf
RUN apt-get update \
  && apt-get install -y \
  libsdl-image1.2-dev \
  libsdl-dev \
  && rm -rf /var/lib/apt/lists/*

COPY .bashrc /home/ros
