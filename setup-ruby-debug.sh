#!/bin/bash

# Getting Ruby-debug set up is a royal pain
# Thanks to these people: http://blog.wyeworks.com/2011/11/1/ruby-1-9-3-and-ruby-debug

wget http://rubyforge.org/frs/download.php/75414/linecache19-0.5.13.gem
wget http://rubyforge.org/frs/download.php/75415/ruby-debug-base19-0.11.26.gem
wget http://rubyforge.org/frs/download.php/63094/ruby-debug19-0.11.6.gem

gem install ./linecache19-0.5.13.gem
gem install ./ruby-debug-base19-0.11.26.gem -- --with-ruby-include=$rvm_path/rubies/ruby-1.9.3-p0/include/ruby-1.9.1/ruby-1.9.3-p0/
gem install ./ruby-debug19-0.11.6.gem -- --with-ruby-include=$rvm_path/rubies/ruby-1.9.3-p0/include/ruby-1.9.1/ruby-1.9.3-p0/

rm -f ./linecache19-0.5.13.gem
rm -f ./ruby-debug-base19-0.11.26.gem 
rm -f ./ruby-debug19-0.11.6.gem 


