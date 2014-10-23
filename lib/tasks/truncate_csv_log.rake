
desc "truncate csv log"
task :truncate_csv_log  => :environment do
  purge_ids = CsvUpload.where(["created_at <= ?", Time.zone.now - 7.days]).map(&:id)
  if purge_ids.any?
    CsvUploadRow.where(:csv_upload_id => purge_ids).delete_all
    CsvUpload.where(:id => purge_ids).delete_all
  end
end