xquery version "3.0" ;
module namespace synopsx.models.tei.book = 'synopsx.models.tei.book';
(:~
 : This module is for TEI models
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

import module namespace G = "synopsx.globals" at '../../globals.xqm'; (: import globals variables :)

declare default function namespace 'synopsx.models.tei.book'; (: This is the default namespace:)
declare namespace tei = 'http://www.tei-c.org/ns/1.0'; (: Add namespaces :)
 

(:~
 : This function creates a map of two maps : one for metadata, one for content data
 :)
declare function synopsx.models.tei.book:listTexts() {
  let $corpus := db:open($G:DBNAME) (: openning the database:)
  let $meta as map(*) := {
    'title' : 'Liste des textes' (: title page:)
    }
  let $content as map(*) := map:merge(
    for $item in $corpus//tei:TEI/tei:teiHeader (: every teiHeader is add to the map with arbitrary key and the result of  corpusHeader() function apply to this teiHeader:)
    return  map:entry(fn:generate-id($item), getTextHeader($item))
    )
  return  map{
    'meta'       : $meta,
    'content'    : $content
  }
};

(:~
 : This function creates a map for a corpus item with teiHeader 
 :
 : @param $item a corpus item
 : @return a map with content for each item
 : @rmq subdivised with let to construct complex queries (EC2014-11-10)
 :)
declare function synopsx.models.tei.book:getTextHeader($item as element()) {
  let $title as element()* := (
    $item//tei:titleStmt/tei:title
    )[1]
  let $date as element()* := (
    $item//tei:titleStmt/tei:date
    )[1]
  let $principal  as element()* := (
    $item//tei:titleStmt/tei:principal
    )[1]
  return map {
    'title'      : $title ,
    'date'       : $date ,
    'principal'  : $principal
  }
};

(:~
 : This function creates a map for a corpus item with teiHeader 
 :
 : @param $item a corpus item
 : @return a map with content for each item
 : @rmq subdivised with let to construct complex queries (EC2014-11-10)
 :)
declare function synopsx.models.tei.book:buildCommonTextStructure() {
   let $corpus := db:open($G:DBNAME) (: openning the database:)
   let $meta as map(*) := {
    'title' : 'Structure du texte' 
    }
     let $content as map(*) := {
    'title' : 'TODO' 
    }
  (:~let $content := '<structure><item>'
    {$corpus//tei:TEI/text/front}'</item>'
    for $item in $corpus//tei:TEI/text/front/seg 
      return '<item>'$item/@type $item/@n'</item>'
  '</structure>' TO DO:)
  
  
  return  map{
    'meta'       : $meta,
    'content'    : $content
  }
};

