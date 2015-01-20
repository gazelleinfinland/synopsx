module namespace synopsx.models.tei.dictionary = 'synopsx.models.tei.dictionary';

(:~
 : equivalence function module for SynopsX
 :)
 
import module namespace G = "synopsx.globals" at '../../globals.xqm'; (: import globals variables :)

declare default function namespace 'synopsx.models.tei.dictionary';

declare namespace tei = 'http://www.tei-c.org/ns/1.0'; 


(:~
 : this function creates a map of two maps : one for metadata, one for content data
 :)
declare function synopsx.models.tei.dictionary:listLemmas($lang, $lemma) {
  let $corpus := db:open($G:DBNAME)//TEI[@xml:id="dictionary_it"]
  (: should be the xml file instead, in a second argument like this : dn:open('db', 'dictionary_'||$lang||'.xml':)
  let $meta as map(*) := {'title' : 'Liste des lemmes'}
  let $content as map(*) :=  map:merge(
    for $item in $corpus//*:entry 
      return 
        if ($lemma != 'all')
         then if (fn:starts-with($item, $lemma))
           then map:entry(fn:generate-id($item), corpusDictionaryEntry($item)) (: map:entry(fn:generate-id($item), corpusDictionaryEntry($item)):)
          else ()
         else map:entry(fn:generate-id($item), corpusDictionaryEntry($item))
    )
  return  map{
    'meta' : $meta,
    'content' : $content
  }
};

(:~
 : this function creates a map for a corpus item
 :)
declare function synopsx.models.tei.dictionary:corpusDictionaryEntry($lemma) as map(*) {
 map {
    'entry' : $lemma/form/orth[@type="lemma"]/text()
  }
};