#The QueryFactory class was created because sometimes is necessary access the attributes from ActiveRdf Query class in writen mode. 
#Author: Samur Araujo
#Date: 25 jun 2008.
class QueryFactory < Query 
  #override the following attributes. 
  attr_writer :select_clauses, :where_clauses, :sort_clauses, :keywords, :limits, :offsets, :reverse_sort_clauses, :filter_clauses
 end 