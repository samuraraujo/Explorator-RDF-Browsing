require 'open-uri'  
require 'cgi'
require 'rexml/document'  
class FinderUtil
  @@alreadyfound = Hash.new   
  #require 'rubygems'
  #require 'hpricot'
  #puts open('http://dbpedia.org/robots.txt' ).read
  #
  #doc = Hpricot.XML(open("http://dbpedia.org/sitemap.xml"))
  #puts doc
  ##(doc/'urlset/sc:dataset/sc:sparqlEndpointLocation').each do |item|
  #puts   doc.search("changefreq").innerHTML
  #puts '###'
  #doc.search("//sc:sparqlEndpointLocation/").each do |item|
  ##  puts 'XX'
  ##   puts item
  #
  # end
  class << self
    attr_accessor :alreadyfound
    # try to locate a sparql endpoint in the robots.xml domain file
    def find_endpoint_for(uri)
      
      root =  get_root_uri(uri)
      
      return if root == nil
      return @@alreadyfound[root] if @@alreadyfound[root] != nil
      
      default = root + 'sparql/'
      if is_endpoint(default,uri)   
        a = Array.new 
        a << default 
      elsif is_endpoint(get_root_uri(uri,1) + 'sparql/',uri)   
        a = Array.new 
        a << default        
      else 
        a = find_by_robot(root)
        if a.size == 0 
          a= find_by_sitemap(root)
        end    
      end  
      #it populates a hash with all sparql endpoints that were found
      a.each do |x|
        list = Array.new
        list << x
        list.uniq!
        @@alreadyfound[root]=list
      end
      a
    end
    def get_root_uri(uri,level=0)
      root = nil
      begin 
        if level == 0
          root = uri[0,uri.index('/',7)] + '/'
        else
          root = uri[0,uri.index('/',uri.index('/',7)+1)] + '/'
        end
      rescue
        puts 'URI does not have a root or it is a root uri: ' + uri
      end
    end
    def is_endpoint(endpoint_uri, uri=nil)   
      puts 'Checking default endpoint for: ' + endpoint_uri
      begin 
        if uri == nil      
          query = open(endpoint_uri+ "?query="+ CGI.escape("ask {?s a ?o} ")).read          
        else
          query= open(endpoint_uri+ "?query="+ CGI.escape("ask {<"+uri+"> a ?o} ")).read      
        end
        doc = REXML::Document.new(query)    
        doc.elements.each('//sparql/boolean') do |isit|
          return     isit.text == 'true'
        end
      rescue
      end  
      return false
    end
    
    # try to locate a sparql endpoint in the robots.xml domain file
    def find_by_robot(uri)   
      puts 'Looking for enpoint on robot: ' + uri
      founds = Array.new 
      begin 
        doc = (open(uri.to_s + "/robots.txt").read)    
        doc.split(/\n/).each do |line|
          
          if line.match('sparql$')
            endpointuri = line
            if endpointuri.index('http://') == nil
              endpointuri = uri + endpointuri
            end
            founds |= line  
          end
        end    
      rescue
        puts 'Not robots.txt for the domain: ' + uri
      end 
      founds
    end
    # try to locate a sparql endpoint in the sitemap.xml domain file
    def find_by_sitemap(uri)   
      puts 'Looking for enpoint on sitemap: ' + uri
      founds = Array.new 
      begin 
        doc = REXML::Document.new(open(uri.to_s + "/sitemap.xml").read)    
        doc.elements.each('//*/sc:sparqlEndpointLocation') do |endpoint|
          endpointuri = endpoint.text
          if endpointuri.index('http://') == nil
            endpointuri = uri + endpointuri
          end
          founds |= endpoint.text
        end    
      rescue
        puts 'Not sitemap.xml for the domain: ' + uri
      end 
      founds
    end
    
    def find_and_add(uri)
      if Thread.current[:autodiscovery] != 'true'
        return
      end
      #it verifies whether exist in the pool an adapter to answer this domain(root)     
      root = get_root_uri(uri)
      if ConnectionPool.void.keys.include?(root)
        adapter = ConnectionPool.void[root]
        Thread.current[:addrepositories]<< adapter
        Thread.current[:enablerepositories]<< adapter.title
        Thread.current[:enablerepositories].uniq!            
        return   
      end
      founds = find_endpoint_for(uri)
      founds.each do |x|        
        adapter = ConnectionPool.find_by_uri(x)
        if adapter == nil
          adapter = ConnectionPool.add_data_source :type => :sparql, :url => x, :results => :sparql_xml, :caching =>true   
          adapter.title= get_root_uri(uri)         
          adapter.limit=50
        end
        Thread.current[:addrepositories]<< adapter
        Thread.current[:enablerepositories]<< adapter.title
        Thread.current[:enablerepositories].uniq!        
      end
    end
  end
end 