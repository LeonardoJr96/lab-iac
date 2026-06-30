[control_plane]
%{ for k, v in nodes ~}
%{ if v.role == "control-plane" }${k} ansible_host=${v.public_ip} private_ip=${v.private_ip}%{ endif }
%{ endfor ~}

[frontend_workers]
%{ for k, v in nodes ~}
%{ if v.role == "frontend" }${k} ansible_host=${v.public_ip} private_ip=${v.private_ip}%{ endif }
%{ endfor ~}

[backend_workers]
%{ for k, v in nodes ~}
%{ if v.role == "backend" }${k} ansible_host=${v.public_ip} private_ip=${v.private_ip}%{ endif }
%{ endfor ~}