log("It's an ONTAP " + node['platform_version']) if netapp_ontap?

ontap_cluster "ontap1" do
  location "Hannover"
  contact "admin@example.com"
  timezone "Etc/UTC"
end

ontap_svm 'svm1' do
  comment 'Fileservices'

  action [:configure, :start]
end

ontap_ip_interface 'svm1-1' do
  svm       'svm1'
  home_node 'ontap-1-01'

  ip_address '192.168.240.222'
  ip_netmask '255.255.255.0'
end

ontap_ip_interface 'svm1-files' do
  svm       'svm1'
  home_node 'ontap-1-01'

  service_policy "default-data-files"

  ip_address '192.168.240.225'
  ip_netmask '255.255.255.0'
end

ontap_nfs_server 'svm1' do
  protocol_v3 true
  protocol_v40 true
  protocol_v41 true

  protocol_v4_id_domain 'lab.local'
end

=begin
ontap_cifs_server 'svm1' do
  servername 'cifsserver'
  comment 'A CIFS test server'
  enabled true

  ad_domain_fqdn 'ad.lab.local'
  ad_domain_user 'Administrator'
  ad_domain_password 'Passw0rd'

  netbios true
  netbios_aliases %w[LAB]
  wins_servers %w[192.168.240.50]

  restrict_anonymous :no_access
end
=end

ontap_aggregate 'aggr1' do
  node_name 'ontap-1-01'

  disk_count 3#
  raid_type :raid4

  disk_class :performance#
  checksum_style :block#
end

ontap_volume 'vol1' do
  svm 'svm1'
  aggregates "aggr1"

  comment "Test volume"
  size "40MB"

  # export_policy "manual_test"
  # path "/vol01"

  # guarantee :none
  # dedupe :background
  # compression :inline
  # compaction :inline

  action [:configure, :online]
end

ontap_ntp_server 'de.pool.ntp.org'

ontap_broadcast_domain 'bd1' do
  mtu 1500
end

ontap_autosupport 'Activate' do
  enabled true

  is_minimal true
  from 'noreply@example.com'
  to 'admin@example.com'
  contact_support false
end

###

ontap_svm 'svm2' do
  comment 'iSCSI'

  iscsi true

  action [:configure, :start]
end

ontap_ip_interface 'svm2-1' do
  svm       'svm2'
  home_node 'ontap-1-01'
  home_port 'e0c'

  ip_address '192.168.240.223'
  ip_netmask '255.255.255.0'
end

ontap_ip_interface 'svm2-iscsi' do
  svm       'svm2'
  home_node 'ontap-1-01'
  home_port 'e0c'
  service_policy "default-data-blocks"

  ip_address '192.168.240.224'
  ip_netmask '255.255.255.0'
end

ontap_iscsi_server 'svm2' do
  target_alias 'svm2'
end

ontap_volume 'vol2' do
  svm 'svm2'
  aggregates "aggr1"

  comment "Test volume 2"
  size "100MB"

  action [:configure, :online]
end

ontap_lun '/vol/vol2/lun1' do
  svm 'svm2'
  os_type :linux

  size "50MB"

  comment "LUN for iSCSI"
end

ontap_igroup 'linux_clients' do
  svm "svm2"
  os_type :linux
  protocol :iscsi
end
