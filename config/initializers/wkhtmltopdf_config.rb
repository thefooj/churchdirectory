
wkhtmltopdf_path_options = [
  '/Applications/wkhtmltopdf.app/Contents/MacOS/wkhtmltopdf',
  '/usr/local/bin/wkhtmltopdf',
  '/usr/bin/wkhtmltopdf'
  ]

wkhtmltopdf_found_path = nil
wkhtmltopdf_path_options.each do |f|
  if File.exists?(f)
    wkhtmltopdf_found_path = f
    break
  end
end

if wkhtmltopdf_found_path.nil?  
  raise StandardError, "Cannot find wkhtmltopdf path" 
end

WickedPdf.config = {
  :exe_path => wkhtmltopdf_found_path 
}