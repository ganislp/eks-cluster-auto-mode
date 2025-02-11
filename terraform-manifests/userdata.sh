#!/bin/bash
   yum install -y aws-cli
    yum install -y curl jq
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    echo "export PATH=/usr/local/bin:$PATH" >> /etc/profile