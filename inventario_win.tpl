[servers_win]
%{ for index, dns in public-dns ~}
${public-id[index]} ansible_host=${public-ip[index]} ansible_connection=winrm ansible_winrm_server_cert_validation=ignore ansible_user=ansible ansible_password=${password}
%{ endfor ~}
