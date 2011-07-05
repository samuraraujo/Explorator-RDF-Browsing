#Explorator - a tool browser for exploring RDF data and Sparql Enpoints

Explorator is a tool for exploring RDF data by direct manipulation. Explorator’s web interface allows users to explore a semi-structured RDF database to both gain knowledge and answer specific questions about a domain, through browsing, search, and exploration mechanisms.

You can access a demo of Explorator here: http://www.tecweb.inf.puc-rio.br/explorator/demo (doesn't work properly in IE). 

#Explorator Instalation

This page describes how to install Explorator - Semantic Exploration of RDF Data. Explorator is semantic browser for RDF data set. It is built on Ruby, Ruby-on-Rails and ActiveRDF.

All the steps below were tested in Windows XP and Mac OS X, but they should work for others platforms such as Linux.

#Prerequisite

You must have Java installed, and the JAVA_HOME environment variable MUST be defined.
If you fail to do this, the Sesame database will not load!

You MUST install all the tools below to run Explorator. Follow the exactly order defined below.

* Install Ruby

* Install Ruby-on-Rails (Follow the steps below.)

* Download Explorator from Git

Follow the steps below to achieve this task.

Execute each command below in a command window in this exact order for install Rails and ActiveRDF.

	gem install  rails -v=2.3.2 --include-dependencies -y
	gem install -v=1.0.7 uuidtools --include-dependencies -y
	gem install activemerchant
	gem install mime-types
	gem install rjb -v 1.1.2

On Windows platform, if prompted, always select the mswin32 option.
Configuration

As Explorator is based on ActiveRDF, you can work with a local rdf base or a remote rdf base (sparql endpoint). You can find a sample of how do configure both of them in the file EXPLORATOR_DIR\lib\dataload.rb.

This installation of Explorator comes with several repositories pre-configured, to be accessed locally. If you wish to add or change repositories locally, please refer to Sesame Installation and Configuration.

#Running Explorator

To run Explorator, open a command window in the EXPLORATOR_DIRECTORY and execute the command: 

	ruby script/server

You can run Explorator inside the AptanaStudio as well.

#Accessing Explorator

Open the FIREFOX browser and access  http://localhost:3000/. It will also be accessible from an external url if your server is visible on the Web; substitute "localhost" by your server's address, e.g.,  http://example.org:3000/.

Note: Explorator does not work in Microsoft Internet Explorer.
