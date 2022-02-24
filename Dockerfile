# Start from the code-server Debian base image
FROM codercom/code-server:latest

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension KevinRose.vsc-python-indent
RUN code-server --install-extension cweijan.vscode-database-client2



# Install apt packages:
# RUN sudo apt-get install -y ubuntu-make
RUN sudo apt-get install -y python3-pip python3-venv sqlite3

# Create venv
RUN python3 -m venv virt
RUN source virt/bin/activate && pip install ipykernel pandas && deactivate

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool

# -----------
RUN sudo curl -fsSL https://deb.nodesource.com/setup_14.x | sudo bash -
RUN sudo apt-get install -y nodejs

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
