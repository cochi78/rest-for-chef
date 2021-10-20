Ohai.plugin(:NetappOntapStorage) do
  depends "ontap"
  provides "ontap/disks", "ontap/volumes"

  def storage_disks
    raw = transport_connection.get("/api/storage/disks?fields=*").data

    raw["records"].to_h { |entry| [entry["name"], entry] }
  end

  def storage_volumes
    raw = transport_connection.get("/api/storage/volumes?fields=*").data

    raw["records"].to_h { |entry| [entry["name"], entry] }
  end

  collect_data(:ontap) do
    ontap["disks"] = storage_disks
    ontap["volumes"] = storage_volumes
  end
end
