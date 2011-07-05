require 'uuidtools'

require 'dataload.rb'
require 'query_builder.rb'
require 'query_factory.rb'
require 'explorator_application.rb'
require 'endpointfinder.rb'

 

#this adapter must be the last one added to the pool because It will be used as an write adapter by the activerdf
#adapter = ConnectionPool.add(:type => :rdflite, :location => 'db/explorator.db', :reasoning => false,:keyword => true)
$work = ConnectionPool.add_data_source :type => :sparql_sesame_api , :title=> 'INTERNAL',  :repository => 'INTERNAL', :dir => $sesamedir.path ,:caching => true


#maximum number of facets display on the interface
$VIEW_FACET_NUMBER=10
 
