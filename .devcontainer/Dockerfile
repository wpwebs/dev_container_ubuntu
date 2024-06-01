# Use Ubuntu 22.04.1 LTS as the base image
FROM ubuntu:22.04 AS base

# Set timezone to New_York
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y sudo git wget curl gnupg lsb-release software-properties-common 

# # Install Docker
# RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
#     echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
#     apt-get update && \
#     apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Python 3.11
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.11 python3.11-venv python3.11-dev python3-pip 
    
# Set Python 3.11 as the default python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Clean up
RUN apt-get upgrade -y && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user
ARG USERNAME=appuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Allow non-root user execute sudo without password
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set WORKDIR
ARG WORKDIR_PATH=/code
RUN mkdir -p $WORKDIR_PATH && \
    chown -R $USERNAME:$USERNAME $WORKDIR_PATH
WORKDIR $WORKDIR_PATH

COPY --chown=$USERNAME:$USER_GID ./src ./src
RUN python -m pip install --upgrade pip \
    && pip install --no-cache-dir --upgrade --disable-pip-version-check -r src/requirements.txt 

# Change the permissions of the script to make it executable.
RUN chmod +x $WORKDIR_PATH/src/entrypoint.sh

# Use the entrypoint script to start the main application and keep the container running
ENTRYPOINT ["$WORKDIR_PATH/src/entrypoint.sh"]

# Development stage
FROM base AS development

# Set Zsh as the default shell for the user by modifying /etc/passwd
RUN sed -i "s|/home/${USERNAME}:/bin/sh|/home/${USERNAME}:/usr/bin/zsh|" /etc/passwd

# Switch to non-root user
USER $USERNAME

# Install Zsh and Oh My Zsh
RUN sudo apt-get update && \
    sudo apt-get install -y zsh fonts-powerline iputils-ping && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    # Install Zsh plugins and theme
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/home/${USERNAME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-/home/${USERNAME}/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-/home/${USERNAME}/.oh-my-zsh/custom}/plugins/zsh-completions && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-/home/${USERNAME}/.oh-my-zsh/custom}/themes/powerlevel10k && \
    # Customize Zsh prompt
    echo 'if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then' >> /home/${USERNAME}/.zshrc \
    && echo '  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"' >> /home/${USERNAME}/.zshrc \
    && echo 'fi' >> /home/${USERNAME}/.zshrc \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /home/${USERNAME}/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' /home/${USERNAME}/.zshrc \
    && echo "source \${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> /home/${USERNAME}/.zshrc \
    && echo "source $HOME/.p10k.zsh" >> /home/${USERNAME}/.zshrc

# Install Jupyter
RUN pip install jupyter

# Conditionally copy Powerlevel10k configuration file for development environment
COPY --chown=$USERNAME:$USER_GID .dot_files/.p10k.zsh /home/${USERNAME}/.p10k.zsh

# Copy the SSH keys (Ensure .ssh directory exists in the build context)
COPY --chown=$USERNAME:$USER_GID .ssh/ssh_key* /home/${USERNAME}/.ssh/
RUN chmod 700 /home/${USERNAME}/.ssh && chmod 600 /home/${USERNAME}/.ssh/* && chmod 644 /home/${USERNAME}/.ssh/*.pub

# Add SSH key to the SSH agent
RUN echo "eval \$(ssh-agent -s) && ssh-add /home/${USERNAME}/.ssh/ssh_key" >> /home/${USERNAME}/.zshrc
RUN sudo chsh -s $(which zsh) $USERNAME

# Clean up
RUN sudo apt-get upgrade -y && \
    sudo apt-get autoremove -y && \
    sudo apt-get clean -y && \
    sudo rm -rf /var/lib/apt/lists/*

# Production stage
FROM base AS production

# Default user shell is bash
RUN chsh -s /bin/bash $USERNAME

# Switch to non-root user
USER $USERNAME
