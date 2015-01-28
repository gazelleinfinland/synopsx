xquery version "3.0" ;
module namespace synopsx.models.tei.article = 'synopsx.models.tei.article';
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

declare default function namespace 'synopsx.models.tei.article'; (: This is the default namespace:)
declare namespace tei = 'http://www.tei-c.org/ns/1.0'; (: Add namespaces :)


(:~
 : This function creates a map of two maps : one for metadata, one for content data
 :)
declare function listArticles() {
  let $texts := db:open($G:BLOGDB)//*:TEI
  let $lang := 'fr'
  let $meta := map {
    'title' : 'Liste d’articles', 
    'quantity' : getQuantity($texts, 'article'), (: @todo internationalize :)
    'author' : getAuthors($texts),
    'copyright'  : getCopyright($texts),
    'description' : getDescription($texts, $lang),
    'keywords' : getKeywords($texts, $lang)
    }
  let $content := map:merge(
    for $item in $texts/*:teiHeader 
    order by ($item//*:publicationStmt/*:date/@when) descending (: sans effet :)
    return  map:entry( fn:generate-id($item), header($item) )
    )
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};



(:~
 : This function creates a map of two maps : one for metadata, one for content data
 :)
declare function article($entryId as xs:string) {
  let $article := db:open($G:BLOGDB)/*:TEI[//*:sourceDesc[@xml:id=$entryId]]
  let $lang := 'fr'
  let $meta := map {
    'title' : getTitles($article, $lang), 
    'author' : getAuthors($article),
    'copyright'  : getCopyright($article),
    'description' : getDescription($article, $lang),
    'keywords' : getKeywords($article, $lang)
    }
  let $content as map(*) := map:merge(
    map:entry( fn:generate-id($article), header($article) )
    )
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : This function creates a map for a corpus item with teiHeader 
 :
 : @param $item a corpus item
 : @return a map with content for each item
 : @rmq subdivised with let to construct complex queries (EC2014-11-10)
 :)
declare function header($item as element()) {
  let $lang := 'fr'
  let $dateFormat := 'jjmmaaa'
  return map {
    'title' : getTitle($item, $lang),
    'subtitle' : getSubtitle($item, $lang),
    'date' : getDate($item, $dateFormat),
    'author' : getAuthors($item),
    'tei' : $item,
    'url' : getUrl($item, $lang)
    (: ', teiAbstract' : getAbstract($item, $lang) :)
  }
};

(:~
 : This function creates a map of two maps : one for metadata, one for content data
 :)
declare function listCorpus() {
  let $texts := db:open($G:DBNAME)//*:teiCorpus
  let $lang := 'fr'
  let $meta := map {
    'title' : 'Liste d’articles', 
    'quantity' : getQuantity($texts, 'article'), (: @todo internationalize :)
    'author' : getAuthors($texts),
    'copyright'  : getCopyright($texts),
    'description' : getDescription($texts, $lang),
    'keywords' : getKeywords($texts, $lang)
    }
  let $content as map(*) := map:merge(
    for $item in $texts/*:teiHeader 
    order by $item//*:publicationStmt/*:date/@when (: sans effet :)
    return  map:entry( fn:generate-id($item), header($item) )
    )
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};

(:~
 : This function creates a map for a corpus item with teiHeader 
 :
 : @param $item a corpus item
 : @return a map with content for each item
 : @rmq subdivised with let to construct complex queries (EC2014-11-10)
 :)
declare function corpusHeader($item as element()) {
  let $title as element()* := (
    $item//*:titleStmt/*:title
    )[1]
  let $date as element()* := (
    $item//*:teiHeader//*:date
    )[1]
  let $author  as element()* := (
    $item//*:titleStmt/*:author
    )[1]
  return map {
    'title'      : $title/text() ,
    'date'       : $date/text() ,
    'principal'  : $author/text()
  }
};


(:~
 : this function creates a map of two maps : one for metadata, one for content data
 :)
declare function synopsx.models.tei.article:listTexts() {
  let $corpus := db:open($G:DBNAME)
  let $meta as map(*) := map {'title' : 'Liste des textes'}
  let $content as map(*) :=  map:merge(
    for $item in $corpus//*:teiCorpus/*:teiHeader       
      return  map:entry(fn:generate-id($item), teiHeader($item))
    )
  return  map{
    'meta' : $meta,
    'content' : $content
  }
};


(:~
 : this function creates a map for a corpus item
 :)
declare function teiHeader($teiHeader) as map(*) {
 map {
    'title' : ($teiHeader//*:titleStmt/*:title/text()),
    'date' : ($teiHeader//*:date/text()),
    'author' : ($teiHeader//*:author/text())
  }
};


(:~
 : this function creates a map of two maps : one for metadata, one for content data
 :)
declare function listMentioned() {
  let $corpus := db:open($G:DBNAME)
  let $meta as map(*) := map {'title' : 'Liste des autonymes'}
  let $content as map(*) :=  map:merge(
    for $item in $corpus//*:mentioned 
      
      return  map:entry(fn:generate-id($item), mentioned($item))
    )
  return  map{
    'meta' : $meta,
    'content' : $content
  }
};


(:~
 : this function creates a map for a corpus item
 :)
declare function mentioned($item) as map(*) {
 map {
    'lang' : fn:string($item/@*:lang),
    'term' : $item/text()
  }
};

(:~
 : ~:~:~:~:~:~:~:~:~
 : tei builders
 : ~:~:~:~:~:~:~:~:~
 :)

(:~
 : this function get abstract
 : @param $content texts to process
 : @return a tei abstract
 :)
declare function getAbstract($content as element()*, $lang as xs:string){
  $content//*:front//*:div[@type='abstract'][fn:starts-with(@xml:lang, $lang)]
};

(:~
 : this function get authors
 : @param $content texts to process
 : @return a distinct-values comma separated list
 :)
declare function getAuthors($content as element()*){
  fn:string-join(
    fn:distinct-values(
      for $name in $content//*:respStmt[*:resp/@key='aut'] | $content//*:principal
      return fn:normalize-space(getName($name))
      ), 
    ', ')
};

(:~
 : this function get the licence url
 : @param $content texts to process
 : @return the @target url of licence
 :
 : @rmq if a sequence get the first one
 : @toto make it better !
 :)
declare function getCopyright($content){
  ($content//*:licence/@target)[1]
};

(:~
 : this function get date
 : @param $content texts to process
 : @param $dateFormat a normalized date format code
 : @return a date string in the specified format
 : @todo formats
 :)
declare function getDate($content as element()*, $dateFormat as xs:string){
  fn:normalize-space(
    $content//*:publicationStmt/*:date
  )
};

(:~
 : this function get description
 : @param $content texts to process
 : @param $lang iso langcode starts
 : @return a comma separated list of 90 first characters of div[@type='abstract']
 :)
declare function getDescription($content as element()*, $lang as xs:string){
  fn:string-join(
    for $abstract in $content//*:div[parent::*:div[fn:starts-with(@xml:lang, $lang)]][@type='abstract']/*:p 
    return fn:substring(fn:normalize-space($abstract), 0, 90),
    ', ')
};

(:~
 : this function get keywords
 : @param $content texts to process
 : @param $lang iso langcode starts
 : @return a comma separated list of values
 :)
declare function getKeywords($content as element()*, $lang as xs:string){
  fn:string-join(
    for $terms in fn:distinct-values($content//*:keywords[fn:starts-with(@xml:lang, $lang)]/*:term) 
    return fn:normalize-space($terms), 
    ', ')
};

(:~
 : this function serialize persName
 : @param $named named content to process
 : @return concatenate forename and surname
 :)
declare function getName($named as element()*){
  fn:normalize-space(
    for $person in $named/*:persName 
    return ($person/*:forename || ' ' || $person/*:surname)
    )
};

(:~
 : this function built a quantity message
 : @param $content texts to process
 : @return concatenate quantity and a message
 : @toto to internationalize
 :)
declare function getQuantity($content as element()*, $unit as xs:string){
  fn:normalize-space(
    if (fn:count($content)>1) 
      then fn:count($content) || ' ' || $unit || 's disponibles'
      else fn:count($content) || $unit || ' disponible'
    )
};

(:~
 : this function get sub-title
 : @param $content texts to process
 : @param $lang iso langcode starts
 : @return a string of comma separated titles
 :)
declare function getSubtitle($content as element()*, $lang as xs:string){
  fn:string-join(
    fn:normalize-space(
      for $title in $content//*:titleStmt/*:title[@type='sub']
      return $title[fn:starts-with(@xml:lang, $lang)]
      ),
    ', ')
};

(:~
 : this function get tei doc by id
 : @param $id documents id to retrieve
 : @return a plain xml-tei document
 :)
declare function getXmlTeiById($id as xs:string){
  db:open($G:BLOGDB)//*:TEI[//*:sourceDesc[@xml-id=$id]]
};

(:~
 : this function get title
 : @param $content texts to process
 : @param $lang iso langcode starts
 : @return a string of comma separated titles
 :)
declare function getTitle($content as element()*, $lang as xs:string){
  fn:string-join(
    fn:normalize-space(
      for $title in $content//*:titleStmt/*:title[@type='main']
      return $title[fn:starts-with(@xml:lang, $lang)]
      ),
    ', ')
};

(:~
 : this function get titles
 : @param $content texts to process
 : @param $lang iso langcode starts
 : @return a string of comma separated titles
 :)
declare function getTitles($content as element()*, $lang as xs:string){
  fn:string-join(
    for $title in $content//*:titleStmt/*:title
    return fn:normalize-space($title[fn:starts-with(@xml:lang, $lang)]),
    ', ')
};

(:~
 : this function get url
 : @param $content texts to process
 : @param $lang iso langcode starts
 : @return a string of comma separated titles
 : @toto print the real uri
 :)
declare function getUrl($content as element()*, $lang as xs:string){
  $G:PROJECTBLOGROOT || $content//*:sourceDesc/@xml:id
};



(:~
 : This function return the corpus title
 :)
declare function title() as element(){ 
  (db:open($G:DBNAME)//*:titleStmt/*:title)[1]
}; 
 
(:~
 : This function return a titles list
 :)
declare function listItems() as element()* { 
  db:open($G:DBNAME)//*:titleStmt/*:title
};
