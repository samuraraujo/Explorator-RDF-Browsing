package br.tecweb.explorator;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import org.openrdf.OpenRDFException;
import org.openrdf.model.Graph;
import org.openrdf.model.Statement;
import org.openrdf.model.URI;
import org.openrdf.model.Value;
import org.openrdf.model.ValueFactory;
import org.openrdf.model.impl.GraphImpl;
import org.openrdf.query.BooleanQuery;
import org.openrdf.query.Query;
import org.openrdf.query.QueryLanguage;
import org.openrdf.query.TupleQuery;
import org.openrdf.query.resultio.sparqlxml.SPARQLResultsXMLWriter;
import org.openrdf.repository.Repository;
import org.openrdf.repository.RepositoryConnection;
import org.openrdf.repository.RepositoryException;
import org.openrdf.repository.config.RepositoryConfig;
import org.openrdf.repository.config.RepositoryConfigException;
import org.openrdf.repository.sail.SailRepository;
import org.openrdf.repository.sail.config.SailRepositoryConfig;
import org.openrdf.rio.RDFFormat;
import org.openrdf.rio.RDFHandlerException;
import org.openrdf.rio.RDFParser;
import org.openrdf.rio.helpers.RDFHandlerBase;
import org.openrdf.rio.rdfxml.RDFXMLParser;
import org.openrdf.sail.inferencer.fc.ForwardChainingRDFSInferencer;
import org.openrdf.sail.nativerdf.NativeStore;
import org.openrdf.sail.nativerdf.config.NativeStoreConfig;

/**
 * Classe respons�vel por fazer o parser do URI e persistir os dados gerados no
 * reposit�rio de dados
 * 
 * @author Danielle Loyola Santos
 * @version 1.0
 * 
 */
public class SesameApiRubyAdapter {
	static Set uris = Collections.synchronizedSet(new HashSet());

	Repository rep;

	String name;

	public SesameApiRubyAdapter(String repository_name) {

		name = repository_name;
		createSesameNativeRepository();
	}

	/**
	 * Load a rdf file into the sesame repository.
	 * 
	 * @param url -
	 *            rdf file uri
	 * @param ahead -
	 *            load all uri within the rdf file
	 * @param format -
	 *            rdf file format (n3, nt, rdfxml)
	 */
	public void loaduri(String url, boolean ahead, String format) {
		try {
			addStatementInContext(url, format);

		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		if (ahead) {
			Graph graphs = new GraphImpl();
			graphs = parserURI(url);
			prepareParser(graphs, format);
		}
	}

	/**
	 * M�todo que cria o reposit�rio Sesame do tipo NativeStore
	 * 
	 * @return
	 * @throws RepositoryConfigException
	 */
	public void createSesameNativeRepository() {
		try {

			// Chapter 5. Application directory configuration
			// http://www.openrdf.org/doc/sesame2/2.2.4/users/ch05.html
			String dir = System
					.getProperty("info.aduna.platform.appdata.basedir");
			File dataDir = null;
			if (dir == null) {
				dataDir = new File(System.getProperty("user.home")
						+ System.getProperty("file.separator")
						+ "sesameadapter"
						+ System.getProperty("file.separator") + name);
			} else {
				if (System.getProperty("info.aduna.platform.appdata.basedir")
						.endsWith(System.getProperty("file.separator")))
					dataDir = new File(System
							.getProperty("info.aduna.platform.appdata.basedir")
							+ name);
				else
					dataDir = new File(System
							.getProperty("info.aduna.platform.appdata.basedir")
							+ System.getProperty("file.separator") + name);
			}
			System.out.println("SESAME Repository Diretory: "
					+ dataDir.getAbsolutePath());

			// Defini��o de quais indexes ser�o criados pelo reposit�rio
			String indexes = "spoc,posc";
			// Instancia��o do reposit�rio Nativo

			NativeStoreConfig natStoreConfig = new NativeStoreConfig();
			// Tipo do repositorio.
			natStoreConfig.setType("native-rdfs-dt");
			// Passando os indexes para o reposit�rio
			natStoreConfig.setTripleIndexes(indexes);
			// Criando o construtor Sail e passando como par�mentro o
			// reposit�rio Nativo
			SailRepositoryConfig sailRepConfig = new SailRepositoryConfig(
					natStoreConfig);

			sailRepConfig.setType("native-rdfs-dt");
			RepositoryConfig repConfig = new RepositoryConfig(name,
					sailRepConfig);

			// Configurando o t�tulo do reposit�rio
			repConfig.setTitle(name);
			repConfig.setID(name);
			// Criando a inst�ncia do reposit�rio
			rep = new SailRepository(new ForwardChainingRDFSInferencer(
					new NativeStore(dataDir, indexes)));
			rep.setDataDir(dataDir);

			// Inicializando a inst�ncia do reposit�rio
			rep.initialize();

			// RepositoryConfigUtil.updateRepositoryConfigs(rep, repConfig);

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * M�todo que adiciona o arquivo URI no reposit�rio Sesame, sendo que cada
	 * tripla adicionada ter� um quarto campo, o contexto
	 * 
	 * @param rep
	 * @param con
	 * @param uri
	 */
	public void addStatementInContext(String uri, String format) {
		RepositoryConnection con = null;
		try {

			// Criar os valores dos quais as senten�as s�o consistidas
			ValueFactory f = rep.getValueFactory();
			// O identificador de contexto ser� igual ao localizador da Web do
			// arquivo que est� sendo passado como par�mentro (URI)
			String location = uri;
			String baseURI = location;
			URL url = new URL(location);

			URI context = f.createURI(location);
			con = rep.getConnection();

			URLConnection urlcon = url.openConnection();

			RDFFormat sesameformat = null;
			if (format.equalsIgnoreCase("n3")) {
				sesameformat = RDFFormat.N3;
				urlcon.setRequestProperty("Accept", "text/rdf+n3");
			} else if (format.equalsIgnoreCase("nt")) {
				sesameformat = RDFFormat.NTRIPLES;
				urlcon.setRequestProperty("Accept", "text/rdf+ntriples");
			} else { // if (format.equalsIgnoreCase("rdf")){
				sesameformat = RDFFormat.RDFXML;
				urlcon.setRequestProperty("Accept", "application/rdf+xml");
			}

			urlcon.setConnectTimeout(7000);
			urlcon.setReadTimeout(7000);
			URI[] contexts = new URI[1];
			contexts[0] = context;
			con.add(urlcon.getInputStream(), baseURI, sesameformat, contexts);
			// con.add(url, baseURI, sesameformat, contexts);

			// Adi��o ao reposit�rio do arquivo no formato desejado juntamento
			// com o contexto identificador

			// Abre a conex�o com o reposit�rio criado

			System.out.println("Added File: " + baseURI);
		} catch (Exception e) {
			System.out.println("Erro File: " + uri);
			System.out.println(e.toString());
		} finally {
			try {
				con.close();
			} catch (RepositoryException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}

	public boolean insert(String s, String p, String o, String c) {
		RepositoryConnection con = null;
		String result = null;
		try {
			con = rep.getConnection();
			con.setAutoCommit(true);
			ValueFactory f = rep.getValueFactory();

			// create some resources and literals to make statements out of
			URI sub = f.createURI(s.replaceAll("<", "").replaceAll(">", ""));
			URI pred = f.createURI(p.replaceAll("<", "").replaceAll(">", ""));

			// Literal alicesName = f.createLiteral("Alice");

			Value obj;
			try {
				if (o.startsWith("<") || o.startsWith("http://"))
					obj = f
							.createURI(o.replaceAll("<", "")
									.replaceAll(">", ""));
				else
					obj = f.createLiteral(o);
			} catch (Exception e) {
				obj = f.createLiteral(o);
			}

			URI context = null;
			if (c != null)
				context = f
						.createURI(c.replaceAll("<", "").replaceAll(">", ""));

			if (context != null) {
				con.add(sub, pred, obj, context);
			} else {
				con.add(sub, pred, obj);
			}

			return true;
		} catch (OpenRDFException e) {
			e.printStackTrace();
			// handle exception
		} catch (Exception e) {
			e.printStackTrace();
			// handle exception
		} finally {
			try {
				con.close();
			} catch (RepositoryException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return false;
	}

	public boolean delete(String s, String p, String o, String c) {

		RepositoryConnection con = null;
		String result = null;
		try {
			con = rep.getConnection();
			con.setAutoCommit(true);
			ValueFactory f = rep.getValueFactory();
			URI sub = null, pred = null;
			if (s != null)
				// create some resources and literals to make statements out of
				sub = f.createURI(s.replaceAll("<", "").replaceAll(">", ""));
			if (p != null)
				pred = f.createURI(p.replaceAll("<", "").replaceAll(">", ""));

			// Literal alicesName = f.createLiteral("Alice");

			Value obj = null;
			try {
				if (o != null)
					obj = f
							.createURI(o.replaceAll("<", "")
									.replaceAll(">", ""));
			} catch (Exception e) {
				if (o != null)
					obj = f.createLiteral(o);
			}

			URI context = null;
			if (c != null)
				context = f
						.createURI(c.replaceAll("<", "").replaceAll(">", ""));

			if (context != null) {
				con.remove(sub, pred, obj, context);
			} else {
				con.remove(sub, pred, obj);
			}

			return true;
		} catch (OpenRDFException e) {
			e.printStackTrace();
			// handle exception
		} catch (Exception e) {
			e.printStackTrace();
			// handle exception
		} finally {
			try {
				con.close();
			} catch (RepositoryException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return false;
	}

	public String query(String queryString) {
		RepositoryConnection con = null;
		String result = null;
		try {
			con = rep.getConnection();
			ByteArrayOutputStream out = new ByteArrayOutputStream();
			SPARQLResultsXMLWriter sparqlWriter = new SPARQLResultsXMLWriter(
					out);
			if (!queryString.startsWith("ASK")) {
				TupleQuery sparqlquery = con.prepareTupleQuery(
						QueryLanguage.SPARQL, queryString);
				sparqlquery.evaluate(sparqlWriter);
				result = out.toString();
			} else {
				BooleanQuery sparqlquery = con.prepareBooleanQuery(
						QueryLanguage.SPARQL, queryString);

				boolean value = sparqlquery.evaluate();
				result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><sparql xmlns=\"http://www.w3.org/2005/sparql-results#\"><head/><boolean>"+value+"</boolean></sparql>";
			}

			

		} catch (Exception e) {

		} finally {
			try {
				con.close();
			} catch (RepositoryException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return result;
	}

	/**
	 * M�todo que faz o parser do URI recebido como entrada e adiciona todas as
	 * triplas parseadas em um grafo
	 * 
	 * @param uri
	 * @return
	 */
	public Graph parserURI(String uri) {
		try {
			final Graph graph = new GraphImpl();
			String baseURI = uri;
			URL url = new URL(baseURI);
			InputStream is = url.openStream();
			RDFParser parser = new RDFXMLParser();
			// Fun��o para lidar com as partes da senten�a que est� sendo
			// parseada
			parser.setRDFHandler(new RDFHandlerBase() {
				public void startRDF() throws RDFHandlerException {
				}

				public void handleStatement(Statement s)
						throws RDFHandlerException {
					try {
						// Um grafo recebe as triplas parseadas de arquivo
						// recebido (URI)
						System.out.println("Parsing First File: "
								+ s.getSubject() + " " + s.getPredicate() + " "
								+ s.getObject());
						graph.add(s.getSubject(), s.getPredicate(), s
								.getObject());
					} catch (Exception e) {
						throw new RDFHandlerException(e);
					}
				}

				public void handleNamespace(String prefix, String name)
						throws RDFHandlerException {
				}

				public void handleComment(String arg0)
						throws RDFHandlerException {
				}

				public void endRDF() throws RDFHandlerException {
				}
			});
			// Verifica os dados que est�o sendo parseados
			parser.setVerifyData(true);
			// O parser n�o p�ra se encontra algum erro
			parser.setStopAtFirstError(false);
			// Parseia o URI recebido a partir do meio de entrada
			parser.parse(is, uri);

			return graph;
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	/**
	 * M�todo que pega cada tripla do grafo passado como par�metro e separa os
	 * URIs, passando um por vez para ser adicionado no reposit�rio de dados
	 * 
	 * @param rep
	 * @param con
	 * @param graph
	 */
	public void prepareParser(Graph graph, final String format) {
		// Itera sobre os dados do grafo
		Iterator it = graph.iterator();
		while (it.hasNext()) {
			Statement st = (Statement) it.next();
			try {
				uris.add(new URL(st.getSubject().stringValue()));
			} catch (Exception e) {

			}
			try {
				uris.add(new URL(st.getPredicate().stringValue()));
			} catch (Exception e) {
			}
			try {
				uris.add(new URL(st.getObject().stringValue()));
			} catch (Exception e) {

			}
		}
		it = uris.iterator();
		while (it.hasNext()) {
			URL st = (URL) it.next();
			final String uri = st.toString();
			// Passa para o m�todo addStatementInContext todos os sujeitos que
			// est�o no grafo passado como par�metro
			try {
				new Thread() {
					public void run() {
						addStatementInContext(uri, format);
					}
				}.start();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
}
