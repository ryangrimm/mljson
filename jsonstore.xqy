xquery version "1.0-ml";

import module namespace reststore="http://marklogic.com/reststore" at "lib/reststore.xqy";

declare option xdmp:mapping "false";

(:
    TODO:
    Copy a document (POST)                  /jsonstore.xqy?uri=http://foo/bar    copyto=http://foo/bar/baz
    Move a document (POST)                  /jsonstore.xqy?uri=http://foo/bar    moveto=http://foo/bar/baz

    DONE:
    Set the document properties (POST)      /jsonstore.xqy?uri=http://foo/bar    property=key:value&property=foo:bar
    Set the document permissions (POST)     /jsonstore.xqy?uri=http://foo/bar    permission=role:capability&permission=foo:read
    Set the document collections (POST)     /jsonstore.xqy?uri=http://foo/bar    collection=name&collection=bar
    Set the document quality (POST)         /jsonstore.xqy?uri=http://foo/bar    quality=10
    Insert a document (PUT|POST)            /jsonstore.xqy?uri=http://foo/bar
    Delete a document (DELETE)              /jsonstore.xqy?uri=http://foo/bar
    Get a document (GET)                    /jsonstore.xqy?uri=http://foo/bar
    Get a document and metadata (GET)       /jsonstore.xqy?uri=http://foo/bar&include=(all|content|collections|properties|permissions|quality)
:)

let $requestMethod := xdmp:get-request-method()
let $uri := xdmp:get-request-field("uri", ())[1]
let $bodyContent := xdmp:get-request-body("text")

where exists($uri)
return
    if($requestMethod = "GET")
    then reststore:getDocument($uri)
    else if($requestMethod = "DELETE")
    then reststore:deleteDocument($uri)
    else if($requestMethod = "PUT")
    then reststore:insertDocument($uri, $bodyContent)
    else if($requestMethod = "POST")
    then
        if(empty(doc($uri)) and exists($bodyContent))
        then reststore:insertDocument($uri, $bodyContent)
        else (
            reststore:setProperties($uri, reststore:propertiesFromRequest()),
            reststore:setPermissions($uri, reststore:permissionsFromRequest()),
            reststore:setCollections($uri, reststore:collectionsFromRequest()),
            reststore:setQuality($uri, reststore:qualityFromRequest())
        )
    else ()
