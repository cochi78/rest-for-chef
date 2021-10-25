ontap_cluster 'ontap1' do
  location 'Hannover'
  contact 'example@gmail.com'
  name_servers '192.168.240.2'
  dns_domains 'lab.local'
  timezone 'Etc/UTC'
end

ontap_aggregate 'aggr1' do
  node_name 'ontap-1-01'

  disk_count 3
  raid_type :raid4

  disk_class :performance
  checksum_style :block
end

ontap_ntp_server 'ptbtime1.ptb.de'
ontap_ntp_server 'ptbtime2.ptb.de'
ontap_ntp_server 'ptbtime3.ptb.de'

ontap_autosupport 'Activate' do
  enabled true

  is_minimal true
  from 'info@example.com'
  to 'example@gmail.com'
  contact_support false
end

ontap_ems_destination 'Admin_Email' do
  type :email
  destination 'admin@lab.local'
end

ontap_snmp 'Enable SNMP' do
  auth_traps_enabled true

  action :enable
end

ontap_snmp_traphost '192.168.240.70'
ontap_snmp_traphost '192.168.240.71'

ontap_security_audit 'Enable auditing' do
  ontapi true
  cli    true
  http   false
end

ontap_security_audit_destination '192.168.240.72' do
  port     514
  facility :local7
  protocol :udp_unencrypted
end
