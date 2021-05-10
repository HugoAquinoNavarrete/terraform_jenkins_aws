[servers]
%{ for index, dns in public-dns ~}
${public-id[index]} ansible_host=${public-ip[index]} 
%{ endfor ~}
