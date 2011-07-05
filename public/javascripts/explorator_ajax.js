/**
 * @author samuraraujo
 */
var loading_text="Loading ..."
//Execute an AJAX request , updating the container with the response text.
function ajax_update_callback(id, _uri, callbackfunction){
    $(id).innerHTML = 'Loading....'
    new Ajax.Request((_uri), {
        method: 'post',
        onComplete: function(transport){
            Element.replace(id, transport.responseText);
            init_all();
            eval(callbackfunction);
        }
    });
}
function ajax_update(id, _uri){
   
    new Ajax.Request((_uri), {
        method: 'post',
        onComplete: function(transport){
//			$(id).hide();            
//			$(id).appear();
			Element.replace(id, transport.responseText);		
            init_all();
        }
    });
}

//Execute an AJAX request , updating the container with the response text.
function ajax_insert(element, _uri, callbackfunction){
    new Ajax.Request((_uri), {
        method: 'post',
        onComplete: function(transport){
            element.insert(transport.responseText);
            init_all();
            eval(callbackfunction);
        }
    });
}

//Execute a ajax request.
function ajax_request(uri){

    $('loadwindow').show();
    new Ajax.Request(uri, {
        method: 'get',
        onComplete: function(transport){
			$('loadingtext').innerHTML = loading_text;
            $('loadwindow').hide();

            ui_add_window(transport.responseText);
            
        }
    });
}

//Execute a ajax request.
function ajax_request_forfacet(uri, item){
    $('loadwindow').show();
    new Ajax.Request(uri, {
        method: 'get',
        onComplete: function(transport){
			$('loadingtext').innerHTML = loading_text;
            $('loadwindow').hide();
            
            ui_add_window(transport.responseText);
            $('facetgroup').insert(item);
        }
    });
}

//Execute a AJAX request for remove something in the server
//This methods do not update the interface.
function ajax_remove(_uri){
    new Ajax.Request(_uri, {
        method: 'get',
    });
}

//execute a AJAX request, creating a new container with the content return by the request.
function ajax_create(_uri){
    $('loadwindow').show();
    new Ajax.Request(createuri + _uri, {
        method: 'post',
        onComplete: function(transport){
            ui_add_window(transport.responseText);
        }
    });
}
