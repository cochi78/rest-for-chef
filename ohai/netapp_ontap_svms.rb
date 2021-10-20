Ohai.plugin(:NetappOntapSvms) do
  depends "ontap"
  provides "ontap/svms"

  def svms
    raw = transport_connection.get("/api/svm/svms?fields=*").data
    raw["records"].to_h { |entry| [entry["name"], entry] }
  end

  collect_data(:ontap) do
    ontap["svms"] = svms
  end
end
