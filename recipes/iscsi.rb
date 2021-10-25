ontap_svm 'dept-svm' do
  comment 'iSCSI'

  iscsi true

  action [:configure, :start]
end

ontap_dns 'dept-svm' do
  domains 'lab.local'
  servers '192.168.240.2'
end

ontap_ip_interface 'dept-svm' do
  svm       'dept-svm'
  home_node 'ontap-1-01'
  home_port 'e0c'

  ip_address '192.168.240.223'
  ip_netmask '255.255.255.0'
end

ontap_ip_interface 'dept-svm-iscsi' do
  svm       'dept-svm'
  home_node 'ontap-1-01'
  home_port 'e0c'
  service_policy 'default-data-blocks'

  ip_address '192.168.240.224'
  ip_netmask '255.255.255.0'
end

ontap_iscsi_server 'dept-svm' do
  target_alias 'dept-svm'
end

ontap_volume 'dept_vol' do
  svm 'dept-svm'
  aggregates 'aggr1'

  comment 'Department Volume'
  size '100MB'

  action [:configure, :online]
end

ontap_lun '/vol/dept_vol/lun1' do
  svm 'dept-svm'
  os_type :linux

  size '50MB'
  comment 'ISCSI'
end

ontap_igroup 'linux_clients' do
  svm 'dept-svm'
  os_type :linux
  protocol :iscsi
end

ontap_lun_map 'dept-svm' do
  svm 'dept-svm'
  igroup 'linux_clients'
  lun '/vol/dept_vol/lun1'

  logical_unit_number 1
end
