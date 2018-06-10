#### generate ssh key-pair for ansible to use on all ansible hosts
- run: `ssh-keygen.exe -t ed25519 -C "ansible key" -f volumes/default/ansible-ssh-keys/id_rsa -N ""` 
  if you need new keys
