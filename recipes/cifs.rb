ontap_svm 'svm1' do
  comment 'Fileservices'

  dns_servers %w(192.168.240.50)
  dns_domains %w(lab.local)

  action [:configure, :start]
end

ontap_ip_interface 'svm1-mgmt' do
  svm       'svm1'
  home_node 'ontap-1-01'

  ip_address '192.168.240.222'
  ip_netmask '255.255.255.0'
end

ontap_ip_interface 'svm1-files' do
  svm       'svm1'
  home_node 'ontap-1-01'

  service_policy 'default-data-files'

  ip_address '192.168.240.225'
  ip_netmask '255.255.255.0'
end

ontap_nfs_server 'svm1' do
  protocol_v3 true
  protocol_v40 true
  protocol_v41 true

  protocol_v4_id_domain 'lab.local'
end

ontap_cifs_server 'svm1' do
  servername 'cifsserver'
  comment 'A CIFS test server'
  enabled true

  ad_domain_fqdn 'ad.lab.local'
  ad_domain_user 'Administrator'
  ad_domain_password 'Passw0rd'

  netbios true
  netbios_aliases %w(LAB)
  wins_servers %w(192.168.240.50)

  restrict_anonymous :no_access
  smb_signing true
  smb_encryption true
  kdc_encryption true
end

ontap_qtree 'qt1' do
  svm 'svm1'
  volume 'vol1'

  security_style :unix
  unix_permissions 0755
end
