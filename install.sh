#!/bin/bash

# Update and upgrade OS
sudo apt update
sudo apt upgrade -y

# Install Ansible
sudo apt install software-properties-common -y
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y

# Create base playbook
cat <<EOF > base.yml
- name: Install base components
  hosts: localhost
  tasks:
    - name: Ensure net-tools, mc, nano, htop, git, cron, curl are installed
      become: true
      apt:
        name: "{{ item }}"
        state: latest
      with_items:
        - net-tools
        - mc
        - nano
        - htop
        - git
        - cron
        - curl
EOF

# Create docker playbook
cat <<EOF > docker.yml
- name: Install Docker, Docker-compose, and Portainer
  hosts: localhost
  tasks:
    - name: Install Docker dependencies
      become: true
      apt:
        name: "{{ item }}"
        state: latest
      with_items:
        - apt-transport-https
        - ca-certificates
        - curl
        - gnupg
        - lsb-release
        - software-properties-common

    - name: Add Docker GPG key
      become: true
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present

    - name: Add Docker repository
      become: true
      apt_repository:
        repo: deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable

    - name: Install Docker CE
      become: true
      apt:
        name: docker-ce
        state: latest

    - name: Install Docker Compose
      become: true
      shell: sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

    - name: Install Portainer
      become: true
      docker_container:
        name: portainer
        image: portainer/portainer
        state: started
        restart_policy: always
        ports:
          - "9000:9000"
EOF

# Create vpn playbook
cat <<EOF > vpn.yml
- name: Install Wireguard and necessary components
  hosts: localhost
  tasks:
    - name: Install Wireguard and necessary packages
      become: true
      apt:
        name: "{{ item }}"
        state: latest
      with_items:
        - wireguard
        - resolvconf
        - iptables-persistent
EOF

# Run Ansible playbooks
ansible-playbook base.yml
ansible-playbook docker.yml
ansible-playbook vpn.yml
