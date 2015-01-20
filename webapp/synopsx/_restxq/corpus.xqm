xquery version "3.0" ;
module namespace synopsx.corpus = 'synopsx.corpus';

(:~
 : This module is the RESTXQ for SynopsX
 : @version 0.1
 : @date 2014-12-15 
 : @author Séverine Gedzelman
 :
 :)
 
 import module namespace G = "synopsx.globals" at '../globals.xqm';

(: Put here all import modules declarations as needed :)
import module namespace synopsx.models.tei.book = 'synopsx.models.tei.book' at '../models/tei/book.xqm';
import module namespace synopsx.models.xml.equivalence = 'synopsx.models.xml.equivalence' at '../models/xml/equivalence.xqm';
import module namespace synopsx.models.tei.dictionary = 'synopsx.models.tei.dictionary' at '../models/tei/dictionary.xqm';

(: Put here all import declarations for mapping according to models :)
import module namespace synopsx.mappings.htmlWrapping = 'synopsx.mappings.htmlWrapping' at '../mappings/htmlWrapping.xqm';

(: Use a default namespace :)
declare default function namespace 'synopsx.corpus';


declare namespace tei = 'http://www.tei-c.org/ns/1.0'; (: déclaration pour test :)


declare 
  %restxq:path('/corpus/{$langs}/{$option}')
  %output:method("xhtml") (: TODO content negociation :)
  function corpusList($langs, $option){
    let $options := map {} (: specify an xslt mode and other kind of option :)
    let $layout := $G:TEMPLATES || 'simpleHtml.xhtml' (: global layout file template :)
    let $pattern := $G:TEMPLATES || 'tei_mentioned_list.xhtml' (: fragment layout template file (to be repeated or not) :)
    return synopsx.mappings.htmlWrapping:globalWrapper
      (
        synopsx.models.tei.book:listTexts(), $options, $layout, $pattern
      )
};

