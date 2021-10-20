Ohai.plugin(:NetappOntapCluster) do
  depends "ontap"
  provides "ontap/contact", "ontap/dns_domains", "ontap/location", "ontap/name", "ontap/name_servers", "ontap/nodes", "ontap/ntp_servers", "ontap/timezone", "ontap/version"

  def cluster_nodes
    raw = transport_connection.get("/api/cluster/nodes?fields=*").data

    raw["records"]
  end

  def cluster
    raw = transport_connection.get("/api/cluster").data

    raw.slice(*%w[contact dns_domains location name name_servers ntp_servers timezone version])
  end

  collect_data(:ontap) do
    ontap.merge!(cluster)

    ontap["nodes"] = cluster_nodes
  end
end
