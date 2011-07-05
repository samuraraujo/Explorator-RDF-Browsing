/**
 * This code implements all the user interface behaviour of explorator
 * @author samuraraujo
 */
////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// HELPER OPERATIONS //////////////////////////////////////////
function getTextValue(element){
    element.cleanWhitespace();
    
    a = element.childNodes;
    for (var index = 0; index < a.length; index++) {
        if (a[index].nodeType == 3) 
            return a[index].nodeValue.trim();
        
    }
    return "";
}

function init_all(){
    $('loadingtext').innerHTML = loading_text;
    $('loadwindow').hide();
    register_ui_behaviour();
    register_controllers();
    querybuilderselection();
    curlbracket();
}

// The functions below remove all css rules registered for a rdf resource and replace for the new's one.
String.prototype.trim = function(){
    var m = this.match(/^\s*(\S+(\s+\S+)*)\s*$/);
    return (m == null) ? "" : m[1];
};
function getDynamicCssRules(){
    var st = document.styleSheets[1];
    var text = ''
    for (var i = st.cssRules.length - 1; i >= 0; i--) {
        text += (st.cssRules[i].cssText) + "\n";
    }
    return text;
}

function setDynamicCssRules(){
    //Get the second CSS in the html <head> element.
    var st = document.styleSheets[1];
    
    for (var i = st.cssRules.length - 1; i >= 0; i--) {
        st.deleteRule(i);
    }
    css = $F('csstext').split('}');
    var idx = 0;
    css.each(function(item){
        item = item.trim();
        if (item.length > 0) {
            st.insertRule(item + '}', idx++);
        }
    });
}

function facetsetmove(){
    if ($('facetgroup') != null) {
        $('body').insert($$('div#facetgroup > div:nth-child(3)')[0]);
        $('facetgroup').remove();
    }
}

function filterResources(input){
    Element.extend(input);
    var filterText = input.value;
    
    if (filterText != null) {
        input.up('._WINDOW').crt_refresh('subject_view', filterText);
    }
}

function checkEnter(e, input){
    var characterCode
    
    if (e && e.which) {
        characterCode = e.which
    }
    else {
        e = event
        characterCode = e.keyCode
    }
    
    if (characterCode == 13) {
        filterResources(input)
        return false
    }
    else {
        return true
    }
    
}




