/**
 * This code implements all the user interface behaviour of explorator
 * @author samuraraujo
 */
//Add global ui methods to the elements
Element.addMethods({
    //Hide an element
    ui_hide: function(item){
        new Effect.BlindUp(item, {
            duration: 0.3
        });
    },
    //Show an element
    ui_show: function(item){
    
        new Effect.BlindDown(item, {
            duration: 0.3
        });
    }, //maximize a window
    //remove an element
    ui_remove: function(item){
        //removes the element from the model and replace the interface with a new one.	
        new Effect.Shrink(item, {
            duration: 0.2,
            afterFinish: function(){
                //definitely removes the element from the set.
                item.remove();
            }
        });
        item.ctr_remove();
    }, //close an element
    ui_close: function(item){
        new Effect.Shrink(item, {
            duration: 0.2,
            afterFinish: function(){
                //definitely removes the element from the set.
                item.remove();
            }
        });
    }, //open an element
    ui_open: function(item){
    
        item.ctr_open();
    }
});

//This method should be executed when the window load.
//Plug the behaviour to the annoted elements.
function register_ui_behaviour(){
    //Initialize window behaviour.
    register_ui_window_behaviour();
    //Initialize de selection behaviour.
    register_ui_selection_behaviour();
    //Initialize de resource behaviour.
    register_ui_resource_behaviour();
}

////////////////////////////////////////////////////////////////////////////////////////////////////////	
//////////////////////////////RESOURCE BEHAVIOURS/////////////////////////////////////////////////////////
function register_ui_resource_behaviour(){
    //Add window show behaviour to the elements with  _MINIMIZE annotation 
    $$('.resource').each(function(resource){
        resource.identify();
        resource.ondblclick = function(e){
            resource.ui_open();
            $('loadingtext').innerHTML = "Loading: " + getTextValue(resource);
            e.stopPropagation();
        };
        //	   resource.onclick = function(e){        
        //		   $('seachbykeyword').value=resource.readAttribute('resource');
        //  			e.stopPropagation();
        //        };
        
       
    });
    
    $$('.flickr_pagination').each(function(item){
    
        item.onclick = function(e){
            item.previous('.tranparentpanel').setStyle({
                display: 'block',
                position: 'absolute',
                width: '100%',
                height: '100%'
            });
            
        };
        
    });
    
    $$('.all').each(function(resource){
        resource.identify();
        resource.onclick = function(e){
            resource.ui_open();
            e.stopPropagation();
        };
        
    });
    $$('.instances').each(function(item){
        item.identify();
        item.onclick = function(e){
            if (item.hasClassName('bluebackground')) {
                item.innerHTML = 'i'
                item.removeClassName('bluebackground');
                item.up('.resource').setAttribute('exp', item.readAttribute('instances'));
            }
            //If it was not selected before, select.            
            else {
                item.innerHTML = 'c'
                item.addClassName('bluebackground');
                item.up('.resource').setAttribute('exp', item.readAttribute('classes'));
            }
            e.stopPropagation();
        };
        item.up('.resource').setAttribute('exp', item.readAttribute('instances'));
    });
    //calcuates the facets
    $$('._facet').each(function(item){
        item.onclick = function(){
            if ($$('.SELECTED').size() != 1) {
                alert("Select JUST 1 set to apply the facets.");
            }
            else {
                if ($$('.SELECTED').first().hasClassName('resource')) {
                    alert('You can only facet a SET not a RESOURCE.')
                    return;
                }
                
                $$('.SELECTED').first().crt_facet('default');
            }
            
        };
    }); //calcuates the facets
    $$('._infer').each(function(item){
        item.onclick = function(){
        
            if ($$('.SELECTED').size() != 1) {
                alert("Select JUST 1 set to apply the facets.");
            }
            else {
                if ($$('.SELECTED').first().hasClassName('resource')) {
                    alert('You can only facet a SET not a RESOURCE.')
                    return;
                }
                $$('.SELECTED').first().crt_infer();
            }
        };
    });
    $$('._view').each(function(x){
        x.onclick = function(){
            ajax_request('/viewer/index?setid=' + x.up('._WINDOW').id);
        };
    });
    $$('._object_view').each(function(item){
        item.onclick = function(){
        
        
            item.up('._WINDOW').select('.tranparentpanel').first().setStyle({
                display: 'block',
                position: 'absolute',
                width: '100%',
                height: '100%'
            });
            item.up('._WINDOW').crt_refresh('object_view', '');
        };
    });
    $$('._predicate_view').each(function(item){
        item.onclick = function(){
            item.up('._WINDOW').select('.tranparentpanel').first().setStyle({
                display: 'block',
                position: 'absolute',
                width: '100%',
                height: '100%'
            });
            item.up('._WINDOW').crt_refresh('predicate_view', '');
        };
    });
    $$('._subject_view').each(function(item){
        item.onclick = function(){
            item.up('._WINDOW').select('.tranparentpanel').first().setStyle({
                display: 'block',
                position: 'absolute',
                width: '100%',
                height: '100%'
            });
            item.up('._WINDOW').crt_refresh('subject_view', '');
            
        };
    });
}

////////////////////////////////////////////////////////////////////////////////////////////////////////	
//////////////////////////////WINDOW BEHAVIOURS/////////////////////////////////////////////////////////
function register_ui_window_behaviour(){
    //create a new window with the expression.
    $$('._new').each(function(x){
        x.onclick = function(){
            ajax_create(Element.exp(this));
        };
    });
    $$('._refresh').each(function(item){
        item.onclick = function(){
            item.up('._WINDOW').crt_refresh('subject_view', '');
        };
    });
    
    //Adds a id to all _WINDOW elements.
    //This is necessary for the ajax_update method know which element should be updated.
    $$('._WINDOW').each(function(item){
        item.identify();
    });
    //Add window show behaviour to the elements with  _MINIMIZE annotation 
    $$('._show').each(function(item){
        item.onclick = function(e){
            item.up('._WINDOW').childElements().each(function(x){
                if (!x.hasClassName('_NO_MINIMIZE')) {
                    x.ui_show();
                }
            });
            e.stopPropagation();
        };
    });
    //Add window hide behaviour to the elements with _MINIMIZE annotation
    $$('._hide').each(function(item){
        item.onclick = function colapse(){
            item.up('._WINDOW').childElements().each(function(x){
                if (!x.hasClassName('_NO_MINIMIZE') && x.visible()) {
                    x.ui_hide();
                }
            });
        };
    });
    
    $$('._expandproperties').each(function(item){
        item.onclick = function(e){
            item.up('._WINDOW').select('.properties').each(function(x){
                x.ui_show();
            });
            item.up('._WINDOW').select('._collapseproperties').invoke('show');
            item.up('._WINDOW').select('._expandproperties').invoke('hide');
            e.stopPropagation();
        };
    });
    $$('._collapseproperties').each(function(item){
        item.onclick = function(e){
            item.up('._WINDOW').select('.properties').each(function(x){
                x.ui_hide();
            });
            item.up('._WINDOW').select('._expandproperties').invoke('show');
            item.up('._WINDOW').select('._collapseproperties').invoke('hide');
            e.stopPropagation();
        };
        
    });
    
    
    //Add window maximize behaviour to the _WINDOW
    $$('._maximize').each(function(item){
        item.onclick = function(){
            item.up('._WINDOW').addClassName('windowmaximized');
        };
    });
    $$('._minimize').each(function(item){
        item.onclick = function(){
            item.up('._WINDOW').removeClassName('windowmaximized');
        };
    });
    //Add window close behaviour to the elements with _WINDOW annotation	
    $$('._remove').each(function(item){
        item.onclick = function(){
            item.up('._WINDOW').ui_remove();
        };
    });
    $$('._close').each(function(item){
        item.onclick = function(){
            item.up('._WINDOW').ui_close();
        };
    });
    
    //    $$('._editable').each(function(item){
    //       new Ajax.InPlaceEditor(item.identify(), '/crud/edit');     
    //    });
    
    //Add the drag and drop behaviour. This allows the object to be repositioned on the screen.
    $$('._draggable').each(function(item){
        new Draggable(item, {});
    });
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////SELECTION BEHAVIOURS//////////////////////////////////////////////////////
function register_ui_selection_behaviour(){
    $$('.select').each(function(item){
        item.onclick = function(e){
            item.select('.properties').each(function(x){
                if (!x.hasClassName('_NO_MINIMIZE') && x.visible()) {
                    x.ui_hide();
                }
            });
            var uri = item.readAttribute('resource');
            if (uri != null) 
                $('seachbykeyword').value = uri.replace('<', '').replace('>', '')
            
            
            item.select('._collapseproperties').invoke('hide');
            item.select('._expandproperties').invoke('show');
            //When only click event happens
			 
            if (e.altKey) {            
                var uri = item.getAttribute('resource');
 
                window.open(uri.substring(1, uri.length - 2), '_blank');
				            e.stopPropagation();
				return;
            }
        
            if (!(e.ctrlKey || e.metaKey)) {
                //remove the selection from all elements on the interface
                $$('.SELECTED').invoke('removeClassName', 'SELECTED');
                //add selection to this element
                item.addClassName('SELECTED');
            }
            //When a shift + click event happens
            else {
                //If it was selected before, deselect. 
                if (item.hasClassName('SELECTED')) {
                    item.removeClassName('SELECTED');
                }
                //If it was not selected before, select.
                else {
                    item.addClassName('SELECTED');
                }
                //If the window is selected, then does not select this element
                if (item.up('._WINDOW.SELECTED')) {
                    item.removeClassName('SELECTED');
                }
            }
            //Deselect all element selected inside another one.
            item.select('.SELECTED').invoke('removeClassName', 'SELECTED');
            //stop the event propagation.
            e.stopPropagation();
        };
    });
    $$('._checkboxfacet').each(function(item){
        item.onclick = function(){
            item.crt_dofacet();
        };
    });
}





///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////WINDOW HELPER FUNCTION//////////////////////////
//Create a empty div window and add to the body.
function ui_create_window(){
    var div = document.createElement('div');
    Element.extend(div);
    id = div.identify();
    div.setAttribute("class", "_WINDOW select");
    document.body.insertBefore(div, $$('.set').first());
    return id;
}

//Adds a html fragment on the html body.
function ui_add_window(result){
    var range = document.createRange();
    range.selectNode(document.body);
    var documentFragment = range.createContextualFragment(result);
    document.body.insertBefore(documentFragment, $$('.set').first());
    init_all();
    $$('.set').first().hide();
    
    Effect.Grow($$('.set').first(), {
        direction: 'top-left'
    });
    
}
