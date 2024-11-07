#!/usr/bin/env bash

# Update package lists and install Ansible
echo ""
echo "Checking to see updates"
sudo apt update
echo "install software-properties-common"
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt update
sudo apt install -y ansible

# Update/upgrade the system
sudo apt update
sudo apt upgrade -y

# Create and run Playbooks to install components
cat <<EOF > base.yml
---
- name: Setup base components
  hosts: localhost
  tasks:
    - name: Install required base components
      apt:
        name: "{{ item }}"
        state: present
      with_items:
        - net-tools
        - mc
        - nano
        - htop
        - git
        - cron
        - curl
EOF

cat <<EOF > docker.yml
---
- name: Setup Docker components
  hosts: localhost
  tasks:
    - name: Install Docker
      apt:
        name: docker-ce
        update_cache: yes

    - name: Install Docker Compose
      shell: curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

    - name: Install Portainer
      docker_container:
        name: portainer
        image: portainer/portainer
        restart_policy: unless-stopped
        ports:
          - "9000:9000"
EOF

cat <<EOF > vpn.yml
---
- name: Setup Wireguard VPN
  hosts: localhost
  tasks:
    - name: Install Wireguard and related components
      apt:
        name: "{{ item }}"
        state: present
      with_items:
        - wireguard
        - wireguard-tools
EOF

# Run Playbooks using Ansible
ansible-playbook base.yml
ansible-playbook docker.yml
ansible-playbook vpn.yml
