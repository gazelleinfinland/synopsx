module namespace synopsx.models.xml.equivalence = 'synopsx.models.xml.equivalence';

(:~
 : equivalence function module for SynopsX
 :)
 
import module namespace G = "synopsx.globals" at '../../globals.xqm'; (: import globals variables :)

declare default function namespace 'synopsx.models.xml.equivalence';

declare namespace tei = 'http://www.tei-c.org/ns/1.0'; 


(:~
 : this function creates a map of two maps : one for metadata, one for content data
 :)
declare function synopsx.models.xml.equivalence:listEquivalences($lang, $lemma) {
  let $corpus := db:open($G:DBNAME)/equivalences 
  (: should be the xml file instead, in a second argument like this : dn:open('db', 'equivalences.xml':)
  let $meta as map(*) := map{'title' : 'Liste des equivalences'}
  let $content as map(*) :=  map:merge(
    for $item in $corpus//equivalence 
     return
       if (fn:starts-with($item, $lemma))
        then map:entry(fn:generate-id($item), corpusEquivalence($lang, $item))
     else ()
    )
  return  map{
    'meta' : $meta,
    'content' : $content
  }
};

(:~
 : this function creates a map for a corpus item
 :)
declare function synopsx.models.xml.equivalence:corpusEquivalence($lang, $equivalence) as map(*) {
 let $map := 
   if ($lang = 'it')
   then  
     map {
      'location' : fn:string($equivalence/@loc),
      'blado' : $equivalence//word[@refText="i1"]/text/text(),
      'vintimille' : $equivalence//word[@refText="f3"]/text/text(),
      'gohory' : $equivalence//word[@refText="f1"]/text/text(),
      'cappel' : $equivalence//word[@refText="f6"]/text/text(),
      'auvergne' : $equivalence//word[@refText="f5"]/text/text(),
      'lahoussaie' : $equivalence//word[@refText="f7"]/text/text()
      }
   else  
     map {
      'location' : fn:string($equivalence/@loc),
      'vintimille' : $equivalence//word[@refText="f3"]/text/text(),
      'gohory' : $equivalence//word[@refText="f1"]/text/text(),
      'cappel' : $equivalence//word[@refText="f6"]/text/text(),
      'auvergne' : $equivalence//word[@refText="f5"]/text/text(),
      'lahoussaie' : $equivalence//word[@refText="f7"]/text/text(),
      'blado' : $equivalence//word[@refText="i1"]/text/text()
    } 
  return $map
};