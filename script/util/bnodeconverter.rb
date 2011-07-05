require 'rubygems'
require 'uuidtools'
filename = 'timbl012.nt'


f = File.new( File.dirname(__FILE__)  + '/../../public/data/' + filename)
rawfile =  f.read

 
# rawfile.gsub!(/_:\w*/, "<http://bnode.org/" + UUID.random_create.to_s + ">")  
 
  while (m = rawfile.match('_:[\w-]*\s')) != nil do
    uri = "<http://bnode.org/" + UUID.random_create.to_s + "> "
    puts m.to_s
    rawfile.gsub!(m.to_s,uri)
    m=nil
  end
  
 File.open(File.dirname(__FILE__)  + '/../../public/data/' + filename + ".2", 'w') {|f| f.write(rawfile) }
