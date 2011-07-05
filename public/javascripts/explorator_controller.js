/**
 * This code implements all the user interface behaviour of explorator
 * @author samuraraujo
 */
//This method should be executed when the window load.
//Plug the behaviour to the annoted elements.
var uri = '/explorator/'
var createuri = uri + 'create?exp='
var updateuri = uri + 'update?exp='
var executeuri = uri + 'execute?exp='
var removeuri = uri + 'remove?exp='

var facetsuri = '/facets/execute?exp='

var facetoriginalexpression = null;
//Global controller methods
Element.addMethods({
    //remove an element
    ctr_remove: function(item){
        //Removing a resource from a set. Remove an element from a set is the same
        // than do the difference from the original set and the resource
        if (item.hasClassName('resource')) {
            parameters.set('SET', item.up('._WINDOW'));
            parameters.set('REMOVE', item);
            ajax_update(item.up('._WINDOW').id, updateuri + new SemanticExpression('SET').difference('REMOVE') + '&uri=' + item.up('._WINDOW').id);
        }
        else {
            //Removing a entire set
            ajax_remove('/explorator/execute?exp=remove(\'' + item.id + '\')');
        }
    },
    crt_refresh: function(item, view, filter){
        //reload the set .         		   	  
        ajax_update(item.id, executeuri + 'refresh(\'' + item.id + '\',:' + view + ',\'' + filter + '\')');
    },
    //open a new window where his content will be defined by the item.exp attribute.
    ctr_open: function(item){
        _uri = '/repository/autoadd?uri=' + Element.resource(item);
        new Ajax.Request((_uri), {
            method: 'get'
        });
        parameters.set('O', item);
        ajax_create(new SemanticExpression('O') + '&view=' + item.readAttribute('view'));
    },
    //Create or replace the facet window with a new content.
    crt_facet: function(item, name){
        facetoriginalexpression = null;
        
        
        facetsetmove();
        if ($('facets')) {
            ajax_update('facets', facetsuri + 'facet' + item.exp() + '&name=' + name);
        }
        else {
        
            ajax_request_forfacet(facetsuri + 'facet' + item.exp() + '&name=' + name, item);
        }
    },//Create or replace the facet window with a new content.
    crt_infer: function(item){
        facetoriginalexpression = null;
        
        facetsetmove(item);
        if ($('facets')) {
            ajax_update('facets', facetsuri + 'infer' + item.exp());
        }
        else {
        
            ajax_request_forfacet(facetsuri + 'infer' + item.exp(), item);
        }
    },
    
    crt_dofacet: function(item){
        facetwindow = item.up('._WINDOW').up('._WINDOW');
        if (facetoriginalexpression == null) {
            facetoriginalexpression = facetwindow.readAttribute('exp');
        }
        facetwindow.setAttribute('exp', facetoriginalexpression);
        parameters.set('C', facetwindow);
        expression = new SemanticExpression('C');
        $$(".values").each(function(x){
            allchecked = x.select("._checkboxfacet:checked");
            if (allchecked.size() > 0) {
                parameters.set('A', allchecked);
                expression.intersection('A');
            }
        });
        ajax_update(facetwindow.readAttribute('set'), updateuri + expression + '&uri=' + Element.set(facetwindow));
        item.up('.facetgroupwindow').down('.tranparentpanel').setStyle({
            display: 'block',
            position: 'absolute',
            width: '100%',
            height: '100%'
        });
        
    },
    sum: function(item){
        ajax_update(item.id, uri + "sum?uri=" + item.id);
    },
    set: function(item){
        return encodeURIComponent(item.readAttribute('set'));
    },
    resource: function(item){
        return encodeURIComponent(item.readAttribute('resource'));
    },
    exp: function(item){
        return encodeURIComponent(item.readAttribute('exp'));
    }
});

//Helper functions defined in explorator_helper.js	
///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////SEMANTIC CALCULATOR COMMANDS//////////////////////////
//It used for store the parameters
var parameters = new Hash();
function register_controllers(){
    cmd_set();
    cmd_semantic();
}

/////////////////////////////// SET OPERATIONS //////////////////////////////////////////
function setParameter(item){
    removeCSS(Element.exp(item));
    $$('.SELECTED').invoke('addClassName', Element.exp(item));
    item.addClassName(Element.exp(item));
    parameters.set(item.id, $$('.SELECTED'));
    removeCSS('SELECTED');
}

//These are the operations applyed over sets
function cmd_set(){
    $$('._setparameter').each(function(item){
        item.onclick = function(){
            setParameter(item);
        };
    });
    $$('._union').each(function(item){
        item.onclick = function(){
            setParameter(item);
            parameters.set('operation', 'union');
        };
    });
    $$('._intersection').each(function(item){
        item.onclick = function(){
            setParameter(item);
            parameters.set('operation', 'intersection');
        };
    });
    $$('._difference').each(function(item){
        item.onclick = function(){
            setParameter(item);
            parameters.set('operation', 'difference');
        };
    });
    $$('._delete').each(function(item){
        item.onclick = function(){
            if (validation_spo()) 
                return;
            parameters.set(item.id, Element.exp(item));
            var view = 'subject_view';
            if (parameters.get(':s') != undefined && parameters.get(':p') != undefined && parameters.get(':o') == undefined) {
                view = 'object_view';
            }
            ajax_create(new SemanticExpression().remove(':s', ':p', ':o', ':r') + "&view=" + view);
            clear();
        };
    });
    $$('._equal').each(function(item){
        item.onclick = function(){
            parameters.set('B', $$('.SELECTED'));
            if (parameters.get('operation') == 'union') {
                ajax_create(new SemanticExpression('A').union('B'));
            }
            else 
                if (parameters.get('operation') == 'intersection') 
                    ajax_create(new SemanticExpression('A').intersection('B'));
                else 
                    if (parameters.get('operation') == 'difference') 
                        ajax_create(new SemanticExpression('A').difference('B'));
                    else {//spo
                        if (validation_spo()) 
                            return;
                        parameters.set(item.id, Element.exp(item));
                        var view = 'subject_view';
                        if (parameters.get(':s') != undefined && parameters.get(':p') != undefined && parameters.get(':o') == undefined) {
                            view = 'object_view';
                        }
                        
                        ajax_create(new SemanticExpression().spo(':s', ':p', ':o', ':r') + "&view=" + view);
                        
                    }
            clear();
        };
    });
    $$('._sum').each(function(item){
        item.onclick = function(){
            item.up('._WINDOW').sum();
        };
    });
}

//Validates a set (union, intersection or difference) command. A and B must be defined for this operation be success executed.
function validation_set(){
    if (!(parameters.get('A') && parameters.get('B'))) {
        alert('Parameter A and B must be defined.')
        return true;
    }
    return false;
}

//Validates a spo command. S, P or O must be defined for this operation be success executed.
function validation_spo(){
    if ((!parameters.get(':s') && !parameters.get(':p') && !parameters.get(':o'))) {
        alert('Parameter S, P or O must be defined.')
        return true;
    }
    return false;
}

function clear(){
    //Remove all CSS added to which resource selected.
    ['A', 'B', 'S', 'P', 'O'].each(function(item){
        removeCSS(item);
    });
    removeCSS('SELECTED');
    parameters = new Hash();
    
}

function removeCSS(item){
    $$('.' + item).invoke('removeClassName', item);
}

/////////////////////////////// SEMANTIC OPERATIONS //////////////////////////////////////////
//These are the operations applyed over triples or semantics annotations
function cmd_semantic(){
    $$('._clear').each(function(item){
        item.onclick = function(){
            clear();
        };
    });
    //Add a listener for the keyword search. 
    //This observer is applied over the form id_form_keyword
    $('load').onclick = function(){
        new Ajax.Request('/repository/enable?title=EXPLORATOR(Local)', {
            method: 'get'
        });
        
        ajax_create(new SemanticExpression().go($F('seachbykeyword')));
        ajax_update('listenabledrepositories', '/repository/listenabledrepositories');
    };
    $('search').onclick = function(){
        ajax_create(new SemanticExpression().search($F('seachbykeyword')));
    };
    
    
    
    
    $('id_form_keyword').onsubmit = function(){
        if ($F('seachbykeyword').indexOf('http://') != -1) 
            ajax_create(new SemanticExpression().go($F('seachbykeyword')));
        else 
        
            ajax_create(new SemanticExpression().search($F('seachbykeyword')));
        return false;
    };
    
    
    //Add a listener for the facet create form. 
    //This observer is applied over the form id_form_facet
    $$('._form_facet').each(function(item){
        item.onsubmit = function(){
            parameters.set('A', $$('.SELECTED'));
            ajax_request("/facets/create?name=" + $F(this['facetname']) + "&exp=" + new SemanticExpression('A'));
            clear();
            return false;
        };
    });
    
    $$('._facetlist').each(function(item){
        item.onchange = function(){
            //gets the set that has been faceted and computes the facet again.	 
            $$('div#facetgroup > div:nth-child(3)')[0].crt_facet($F(this));
            return false;
        };
    });
}

///////////////////////////////////// Expression Class ////////////////////
var SemanticExpression = Class.create({
    initialize: function(param){
        this.expression = 'SemanticExpression.new';
        //whether the parameter is not passed.
        if (param != undefined) {
            //check out whether the pararameter passed was not set or defined.
            if (parameters.get(param) != undefined) {
                this.union(param);
            }
            else {
                //set the expression as a ruby symbol: ':s'
                this.expression = param;
            }
        }
    },
    union: function(param){
        var a = parameters.get(param);
        if (a == undefined) 
            return this;
        //The parameter could be only one element or several.
        if (Object.isArray(a)) {
            this.expression += a.map(function(x){
                return '.union' + Element.exp(x);
            }).join('');
        }
        else {
            this.expression += '.union' + Element.exp(a);
        }
        return this;
    },
    intersection: function(param){
        var a = parameters.get(param);
        if (a == undefined) 
            return this;
        //The parameter could be only one element or several.
        if (Object.isArray(a)) {
            this.expression += '.intersection(' + new SemanticExpression(param) + ')';
            
        }
        else {
            this.expression += '.intersection' + Element.exp(a);
        }
        return this;
    },
    difference: function(param){
        var a = parameters.get(param);
        if (a == undefined) 
            return this;
        //The parameter could be only one element or several.			
        if (Object.isArray(a)) {
            this.expression += a.map(function(x){
                return '.difference' + Element.exp(x);
            }).join('');
        }
        else {
            this.expression += '.difference' + Element.exp(a);
        }
        return this;
    },
    getResourcesArray: function(param){
        var a = parameters.get(param);
        var expression = '';
        if (a == undefined) 
            return param;
        
        //The parameter could be only one element or several.			
        if (Object.isArray(a)) {
            expression += a.map(function(x){
                var resource = Element.resource(x);
                
                if (resource == 'null' || x.hasClassName('class')) {
                    var exp = x.readAttribute('exp');
                    if (exp.indexOf(':o,:o') != -1) {
                        return 'SemanticExpression.new' + encodeURIComponent(exp.replace(":o,:o", ':o')) + '.resources(:o)';
                    }
                    else 
                        if (exp.indexOf(':o,:p') != -1) {
                            return 'SemanticExpression.new' + encodeURIComponent(exp.replace(":o,:p", ':o')) + '.resources(:p)';
                        }
                        else {
                            return 'SemanticExpression.new' + encodeURIComponent(exp) + '.resources(:s)';
                        }
                }
                else {
                    return "['" + resource + "']";
                }
            }).join('|');
        }
        return expression; //returns a array of resources in ruby
    },
    spo: function(s, p, o, r){
    
        this.expression += '.spo(' + this.getResourcesArray(s) + ',' + this.getResourcesArray(p) + ',' + this.getResourcesArray(o) + ',' + parameters.get(r) + ')';
        return this;
    },
	remove: function(s, p, o, r){
    
        this.expression += '.remove(' + this.getResourcesArray(s) + ',' + this.getResourcesArray(p) + ',' + this.getResourcesArray(o) + ',' + parameters.get(r) + ')';
        return this;
    },
    keyword: function(k){
        this.expression += '.keyword(\'' + k + '\')';
        return this;
    },
    search: function(k){
        this.expression += '.search(\'' + encodeURIComponent(k) + '\')';
        return this;
    },
    go: function(k){
        this.expression += '.go(\'' + encodeURIComponent(k) + '\')';
        return this;
    },
    toString: function(){
        return this.expression;
    }
});
function preDefinedFilter(el){
    Element.extend(el);
    var win = el.up('._WINDOW');
    var exp = Element.exp(win);
    
    var select = el.previous('select');
    
    var operator = $F(select);
    var value = el.value;
    
    ajax_update(win.id, uri + "addfilter?uri=" + win.id + "&op=" + operator + "&value=" + value);
}

