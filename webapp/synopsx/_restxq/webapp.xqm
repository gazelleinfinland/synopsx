xquery version "3.0" ;
module namespace synopsx.webapp = 'synopsx.webapp';
(:~
 : This module is the RESTXQ for SynopsX
 : @version 0.2 (Constantia edition)
 : @date 2014-11-10 
 : @author synopsx team
 :
 : This file is part of SynopsX.
 : created by AHN team (http://ahn.ens-lyon.fr)
 :
 : SynopsX is free software: you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation, either version 3 of the License, or
 : (at your option) any later version.
 :
 : SynopsX is distributed in the hope that it will be useful,
 : but WITHOUT ANY WARRANTY; without even the implied warranty of
 : MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 : See the GNU General Public License for more details.
 : You should have received a copy of the GNU General Public License along 
 : with SynopsX. If not, see <http://www.gnu.org/licenses/>
 :
 :)

import module namespace G = "synopsx.globals" at '../globals.xqm';

(: Put here all import modules declarations as needed :)
import module namespace synopsx.models.tei = 'synopsx.models.tei.book' at '../models/tei/book.xqm';

import module namespace synopsx.models.tei.article = 'synopsx.models.tei.article' at '../models/tei/article.xqm';

(: Put here all import declarations for mapping according to models :)
import module namespace synopsx.mappings.htmlWrapping = 'synopsx.mappings.htmlWrapping' at '../mappings/htmlWrapping.xqm';

(: Use a default namespace :)
declare default function namespace 'synopsx.webapp';

(:~
 : This resource function return the corpus item
 : 
 : @return an xhtml page binding layout templates and models
 : @rmq demo function for templating
 :)
declare 
  %restxq:path('/corpus')
  %output:method("xhtml") (: TODO content negociation :)
  function corpusList(){
    let $options := map {} (: specify an xslt mode and other kind of option :)
    let $layout := $G:TEMPLATES || 'tei_chapters.xhtml' (: global layout file template :)
    let $pattern := $G:TEMPLATES || 'tei_chapter.xhtml' (: fragment layout template file (to be repeated or not) :)
    return 
       copy $page := fn:doc($G:TEMPLATES || 'html.xhtml')
       modify (replace node $page//*:div[@title="main"] with synopsx.mappings.htmlWrapping:globalWrapper(synopsx.models.tei.article:listArticles(), $options, $layout, $pattern),
     replace value of node $page//*:div[@id="site-title"] with <h1>Mon titre</h1>
   )
       return $page   
};



(: declare 
  %restxq:path('/test')
  %output:method("xhtml") 
  function test(){
    let $params := map { 
      'title' : 'test', 
      'author' : 'jpm',
      'content' : map { 
          'pattern' : fn:doc($G:TEMPLATES || 'tei_chapter.xhtml'),
          'wrapper' : fn:doc($G:TEMPLATES || 'tei_chapters.xhtml'),
           'items' : map:get(synopsx.models.tei.article:listArticles(), 'content')}
  }
  return wrapper(fn:doc($G:TEMPLATES || 'html.xhtml'), $params)
      
}; :)


(: Aim : 
keys of the map are removed recursively
CASE 1 : Test if no more key, then return the document (fully built)
CASE 2 : Get first key, 
:)
declare function wrapper ($template as document-node(), $params as map(*)) as document-node()* {
    let $result := 
    
      (:CASE 1      
      if(fn:empty(fn:trace(map:keys($params), 'First test'))):)
      if(map:size(fn:trace($params,'Params :')) = 0)
       then $template
      else 
      (:CASE 2 - tested three times and for each item :)
       let $key := map:keys($params)[1]
       let $value :=  map:get($params, $key)
       (: preparing for the next call, 
        - remove from the map, the key used here, creating a new map $params2
        - calling the wrapper with the new map $params2:)
       let $params2 := map:remove($params, $key)
       let $updated_template := wrapper ($template, $params2)
      return fn:trace($updated_template,'update template') update (
    for $text in //text()[.=fn:concat('{', $key, '}')] 
     return 
     (: Testing whether the value of one of the params is 
     - a text, replace the node in the templated text, that has the same name as the key of the params, being analyzed
     - a map, 
     :)
       typeswitch($value)
         case text() 
           return replace value of node $text with $value
         case map(*) 
           return 
             let $pattern := map:get($value, 'pattern')
             let $items := map:get($value, 'items')
             let $seq := (
               for $item in $items
               return fn:trace(wrapper($pattern,$item), 'Wrapper is launched with : '||map:size($params))
           )
             return insert node $seq into fn:trace(map:get($value, 'wrapper'), 'Value of wrapper : ')
         default return ()
       ,
     for $text in //@*[fn:string(.)=fn:concat('{', $key, '}')] 
     return replace value of node $text with map:get($params, $key)
 )
 return $result
};

(: Where everything will be decided later on :)
declare function main($params){
    (:let $project := map:get($params,'project'):)
    $G:HOME
};


(:~
 : To be use to implement the webapp entry points
 : Used in the last version of synopsx  
 :
 : These five functions analyze the given path and retrieve the data
 :
 :)

declare 
  %restxq:path("")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("xhtml")
function index() {
  let $params := map {
    "project" : "synopsx",
    "dataType" : "home"
  }
  return main($params)
};

declare 
  %restxq:path("{$project}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("xhtml")
function index($project) {
  let $params := map {
    "project" : $project,
    "dataType" : "home"
  }
  return main($params)
};


declare 
  %restxq:path("{$project}/{$dataType}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("xhtml")
function index($project, $dataType) {
  let $params := map {
    "project" : $project,
    "dataType" : $dataType
  }
  return main($params)
};

declare
  %restxq:path("{$project}/{$dataType}/{$value}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("xhtml")
function index($project, $dataType, $value) {
  let $params := map {
    "project" : $project,
    "dataType" : $dataType,
    "value" : $value
  }
  return main($params)
};

declare 
  %restxq:path("{$project}/{$dataType}/{$value}/{$option}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("xhtml")
function index($project, $dataType, $value, $option) {
  let $params := map {
    "project" : $project,
    "dataType" : $dataType,
    "value" : $value,
    "option" : $option
  }
  return main($params)
};