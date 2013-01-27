desc "load initial church"
task :setup_church, [:urn,:name] => :environment do |t, args|
  urn = args.urn
  name = args.name
  
  church = Church.find_by_urn(urn)
  if church.nil?
    church = Church.create(:urn => urn, :name => name)
  end
end