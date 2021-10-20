Ohai.plugin(:NetappOntapNetwork) do
  depends "ontap"
  provides "ontap/broadcast_domains", "ontap/interfaces", "ontap/ipspaces", "ontap/ports"

  def network_ethernet_broadcastdomains
    raw = transport_connection.get("/api/network/ethernet/broadcast-domains?fields=*").data

    raw["records"].to_h { |entry| [entry["name"], entry] }
  end

  def network_ethernet_ports
    raw = transport_connection.get("/api/network/ethernet/ports?fields=*").data

    raw["records"].to_h { |entry| [entry["name"], entry] }
  end

  def network_fc_ports
    raw = transport_connection.get("/api/network/fc/ports?fields=*").data

    raw["records"].to_h { |entry| [entry["name"], entry] }
  end

  def network_ip_interfaces
    raw = transport_connection.get("/api/network/ip/interfaces?fields=*").data

    raw["records"].to_h { |entry| [entry["name"], entry] }
  end

  def network_ipspaces
    raw = transport_connection.get("/api/network/ipspaces?fields=*").data

    raw["records"].to_h { |entry| [entry["name"], entry] }
  end

  collect_data(:ontap) do
    ontap["broadcast_domains"] = network_ethernet_broadcastdomains
    ontap["interfaces"]        = network_ip_interfaces
    ontap["ipspaces"]          = network_ipspaces
    ontap["ports"]             = network_ethernet_ports + network_fc_ports
  end
end
