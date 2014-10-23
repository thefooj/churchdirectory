
desc "table_sizes"
task :table_sizes => :environment do
  [Church,ChurchUser,CsvUpload,CsvUploadRow,GeocodeCache,Person,User].each do |klass|
    puts "#{klass.name} => #{klass.count}"
  end
end