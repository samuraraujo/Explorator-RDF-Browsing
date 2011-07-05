# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
#
# config.action_controller.session = {
#    :session_key => '_SemanticNavigation_session',
#    :secret      => '9d4c0d38e0089727c092801103c9880ccfb20c07d64e86f30b4fd51a23af387648a7887c6b20234f41348fd7a074ceabfb9c70867ac4611ae8af4dade33de76d'
#  }

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
   config.frameworks -= [ :active_record]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'
 

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end
require 'libs.rb'

require "will_paginate" 
WillPaginate::ViewHelpers.pagination_options[:previous_label] ='<'
WillPaginate::ViewHelpers.pagination_options[:next_label] = '>' 
WillPaginate::ViewHelpers.pagination_options[:inner_window] = 2

$WILL_PAGINATE_PER_PAGE=30  #number of resourcer per page
#Setting this $QUERY_RETRIEVE_LABEL_AND_TYPE to true will force Explorator's queries to retrieve resources's label and type , of course, if they exist.
#This increase the Explorator's response time because only 1 query will be executed at all. 
#If $QUERY_RETRIEVE_LABEL_AND_TYPE=false then Explorator will execute one query for each resource rendered on the interface.
#We MUST set $LABEL_PROPERTIES as ['rdfs::label'], otherwise the heuristic above will not behave as described.
$QUERY_RETRIEVE_LABEL_AND_TYPE=false

#RENDER HEURISTIC CONFIGURATION
# if $USE_EXPLORATOR_VIEW=true explorator's render will try to get the Resource'label from an expression defined in a property explorator:view
$USE_EXPLORATOR_VIEW=false 
#The $LABEL_PROPERTIES is used to defined which properties Explorator should look for human readable label. The first one found will be used on the interface.
#If you are using $QUERY_RETRIEVE_LABEL_AND_TYPE=true the you must set $LABEL_PROPERTIES=['rdfs::label']
$LABEL_PROPERTIES=['rdfs::label','name','title'] 
#$LABEL_PROPERTIES=['rdfs::label']
 