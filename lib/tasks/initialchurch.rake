desc "load initial church"
task :setup_church, [:urn,:name] => :environment do |t, args|
  urn = args.urn
  name = args.name
  
  church = Church.find_by_urn(urn)
  if church.nil?
    church = Church.new
    church.urn = urn
    church.name = name
    church.save!
  end
end

desc "church user"
task :add_church_user, [:church_urn, :email] => :environment do |t, args|
  urn = args.church_urn
  email = args.email
  
  church = Church.find_by_urn(urn)
  if church.present?
    church.add_user_by_email(email)
  end
end