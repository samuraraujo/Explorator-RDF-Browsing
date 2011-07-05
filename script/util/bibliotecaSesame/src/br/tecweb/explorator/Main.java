package br.tecweb.explorator;

import java.io.File;
import java.util.Iterator;

/**
 * Classe responsável por passar o URI de entrada e chamar os métodos da
 * Biblioteca
 * 
 * @author Danielle Loyola Santos, Samur Araujo
 * @version 1.1
 */
public class Main {
	/**
	 * Método que chama os métodos da Biblioteca e passa o URI de entrada
	 * 
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		try {

			System.setProperty("info.aduna.platform.appdata.basedir",
							"C:\\Desenvolvimento\\workspace\\Explorator\\db\\Sesame\\repositories\\");
			SesameApiRubyAdapter saver = new SesameApiRubyAdapter("TIMBL");
//			File			file = new File ("");
//			File[] files = file.listFiles();
//			for (int i = 0; i < files.length; i++) {
//				
//				saver.loaduri("http://139.82.71.43:3000/data/" + files[i].getName() , false, "n3");				
//			}
 			saver.loaduri("http://139.82.71.43:3000/data/teste.nt"   , false, "nt");
			//saver.loaduri("file://C:\\Desenvolvimento\\workspace\\Explorator\\public\\data\\timbl012.nt.2"   , false, "nt");
			
		
			//saver.delete(null,   null,null,null);
//			saver.loaduri("http://data.semanticweb.org/dumps/conferences/eswc-2007-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/conferences/eswc-2008-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/conferences/iswc-2006-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/conferences/iswc-2008-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/conferences/iswc-aswc-2007-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/conferences/www-2008-complete.rdf", false, "rdf");
//			
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/LDOW-2008-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/esoe-2007-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/fews-2007-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/first-2007-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/insemtive-2008-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/iwod-2008-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/natures-2008-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/obi-2008-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/om-2007-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/om-2008-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/owled-2007-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/peas-2007-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/pickme-2008-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/scripting-2008-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/sdow-2008-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/semwebdesign-2007-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/ssws-2008-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/swsc-2008-complete.rdf", false, "rdf");
//			saver.loaduri("http://data.semanticweb.org/dumps/workshops/terra_cognita-2008-complete.rdf", false, "rdf");
			
			
//			saver
//					.delete(
//							"http://www.tecweb.inf.puc-rio.br/application/id/62a76a59d568e0b464925e623c117e8c/default",
//							"http://www.w3.org/2000/01/rdf-schema#label", null,
//							null);
			// saver.insert("http://www.tecweb.inf.puc-rio.br/application/id/62a76a59d568e0b464925e623c117e8c/default",
			// "http://www.w3.org/2000/01/rdf-schema#label", "20", null);
//			System.out.println(saver
//					.query("SELECT ?s ?p ?o WHERE { ?s ?p ?o . }  "));
//
//			System.out.println(saver
//					.query("ASK { ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?p. } "));

		} catch (Exception e) {
			e.printStackTrace();
			System.out.println(e.toString());
		}
	}
}
