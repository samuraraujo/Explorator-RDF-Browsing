package br.tecweb.explorator;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;

import org.semanticweb.yars.nx.Node;
import org.semanticweb.yars.nx.parser.NxParser;

public class Converter {
public static void main (String []a) throws Exception{
	
	 File file = new File ("c:\\temp\\timbl01.nq");
	 NxParser nxp = new NxParser(new FileInputStream(file),false);
	 
	 File result = new File (file.getAbsolutePath() + ".n3");
     
     BufferedWriter out = new BufferedWriter(new FileWriter(result));
     
	 while (nxp.hasNext()) {
	    Node[] ns = nxp.next();
				
	    for (Node n: ns) {
	      out.write(n.toN3());
	      out.write(" ");
	    }
	    out.write(". \n");
	  }

	System.out.print("Arquivo convertido! - " + result.getAbsolutePath()  );
}
}
