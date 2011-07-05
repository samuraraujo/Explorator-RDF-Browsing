# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_explorator_session3',
  :secret      => '5d242ad0bb45d319b25af36f47acaaff9629eb596333e7d96d118b3aa4483d0662f2592feee03a16db0b7084b22adc8cd685b2cf47a93f83adb1a69f118aa2d6',
   
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
 
#ActionController::Base.session_options[:cache] = CACHE 
#ActionController::Session::MemCacheStore.new('explorator',ActionController::Base.session_options )
ActionController::Base.session_store = :memory_store
 
 
#ActionController::Base.session_store = ActionController::Session::MemoryStore.new(nil)
#ActionController::Session::MemCacheStore.destroy_all
#ActionController::Base.cache_store = :synchronized_memory_store 
#ActionController::Base.session_store = :synchronized_memory_store
#ActionController::Base.cache_store = :spandex_mem_cache_store, '139.82.71.43', {:namespace => 'explorator-#{RAILS_ENV}'}

