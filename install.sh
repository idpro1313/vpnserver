#!/bin/bash
echo " "
echo "Update and upgrade OS"
echo " "

sudo apt update
sudo apt upgrade -y

echo " "
echo "Install Ansible"
echo " "

sudo apt install software-properties-common -y
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y

echo " "
echo "Create base playbook"
echo " "

cat <<EOF > base.yml
- name: Install base components
  hosts: "localhost"
  tasks:
    - name: Ensure net-tools, mc, nano, htop, cron, curl are installed
      become: true
      apt:
        name: "{{ item }}"
        state: latest
      with_items:
        - net-tools
        - mc
        - nano
        - htop
        - cron
#        - curl
EOF

echo " "
echo "Create docker playbook"
echo " "

cat <<EOF > docker.yml
- name: Install Docker, Docker-compose, and Portainer
  hosts: "localhost"
  tasks:
    - name: Install Docker dependencies
      become: true
      apt:
        name: "{{ item }}"
        state: latest
      with_items:
        - apt-transport-https
#        - ca-certificates
#        - gnupg
#        - lsb-release

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

#    - name: Install Docker Compose
#      become: true
#      shell: sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

    - name: Install Portainer
      become: true
      docker_container:
        name: portainer
        image: portainer/portainer-ce
        state: started
        pull: true
        restart_policy: always
        ports:
          - "8000:8000"
          - "9443:9443"
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
          - portainer_data:/data
EOF

echo " "
echo "Create vpn playbook"
echo " "

cat <<EOF > vpn.yml
- name: Install Wireguard and necessary components
  hosts: "localhost"
  tasks:
    - name: Install Wireguard and necessary packages
      become: true
      apt:
        name: "{{ item }}"
        state: latest
      with_items:
        - wireguard
#        - resolvconf
        - iptables-persistent

    - name: Configure kernel parameters
      become: true
      blockinfile:
        path: /etc/sysctl.conf
        block: |
          net.ipv4.conf.all.rp_filter=0
          net.ipv4.ip_forward=1
          net.ipv4.conf.all.forwarding=1
      notify: Reload sysctl

    - name: Create the WireGuard Dashboard container
      become: true
      docker_container:
        name: wgdashboard
        image: donaldzou/wgdashboard
        state: started
        pull: true
        restart_policy: unless-stopped
        env:
          enable: wg0
          isolate: wg0
        volumes:
          - /etc/wireguard:/etc/wireguard
          - /opt/wgdata:/data
        ports:
          - "10086:10086"
          - "51820:51820/udp"
        capabilities:
          - NET_ADMIN

  handlers:
    - name: Reload sysctl
      become: true
      command: sysctl -p /etc/sysctl.conf
EOF

echo " "
echo "Run Ansible playbooks"
echo " "

ansible-playbook  base.yml
ansible-playbook  docker.yml
ansible-playbook  vpn.yml
