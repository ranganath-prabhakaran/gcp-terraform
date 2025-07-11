#!/bin/bash
# scripts/setup_mcp_server.sh

# This script is executed by Terraform as the startup script on the MCP GCE instance.

# --- Install Dependencies ---
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv git mysql-client mydumper

# --- Install Google Cloud CLI ---
sudo apt-get install -y apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install -y google-cloud-cli

# --- Setup MCP Server Application ---
cd /opt
sudo git clone https://github.com/microsoft/autogen.git
cd autogen
sudo python3 -m venv venv
source venv/bin/activate

# Install MCP dependencies
pip install "autogen[mcp]" uvicorn

# Fetch secrets and set as environment variables for the MCP server process
export PROJECT_ID="${project_id}"
export SOURCE_DB_IP="${source_db_ip}"
export SOURCE_DB_USER="${source_db_user}"
export SOURCE_DB_NAME="${source_db_name}"
export SOURCE_DB_PASSWORD=$(gcloud secrets versions access latest --secret="${source_db_pass_secret_id}")

# The myloader command will need the target password. We'll write it to a file
# that the command in mcp_migrate_data.py can reference.
# Note: This is a simplification. A more secure method would be to have the myloader
# process itself fetch the secret at runtime.
# export CLOUD_SQL_PASSWORD=$(gcloud secrets versions access latest --secret="<cloud_sql_password_secret_id>")
# The cloud_sql_password_secret_id is not available at startup script templating time.
# The tool itself will need to fetch it.

# --- Create and run MCP server as a service ---
sudo tee /etc/systemd/system/mcp_server.service > /dev/null <<EOF
[Unit]
Description=Model Context Protocol Server
After=network.target


User=root
Group=root
WorkingDirectory=/opt/autogen
ExecStart=/opt/autogen/venv/bin/python -m autogen_ext.tools.mcp.server --host 0.0.0.0 --port 8000 --db-type mysql --db-host ${source_db_ip} --db-user ${source_db_user} --db-name ${source_db_name} --db-password "$SOURCE_DB_PASSWORD"
Restart=always
Environment="PROJECT_ID=${project_id}"
Environment="SOURCE_DB_IP=${source_db_ip}"
Environment="SOURCE_DB_USER=${source_db_user}"
Environment="SOURCE_DB_NAME=${source_db_name}"
Environment="SOURCE_DB_PASSWORD=$SOURCE_DB_PASSWORD"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable mcp_server.service
sudo systemctl start mcp_server.service

echo "MCP Server setup complete and service started."