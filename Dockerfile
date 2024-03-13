FROM osrf/ros:noetic-desktop-full

COPY sources.list /etc/apt/sources.list

RUN apt-get update \
  && apt-get install -y \
  vim \
  curl \
  wget \
  git \
  sudo \
  tar

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
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
  && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

USER root
RUN apt-get update \
  && apt-get install -y \
  zsh \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  tmux \
  unzip \
  ranger \
  software-properties-common \
  && rm -rf /var/lib/apt/lists/*

USER root
COPY ./.zshrc /home/ros/.zshrc

COPY .p10k.zsh /home/ros/.p10k.zsh

USER ros
RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

ENTRYPOINT [ "zsh" ]
