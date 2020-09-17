#! /usr/bin/awk -f
### usage: rdfize_entry.awk -v id_uri_prefix=\"URI PREFIX LIST\" [-v id_uri_abbrev=\"PREFIX ABBREV LIST\"] table_file

BEGIN {
    if(!id_uri_prefix) {
        print "usage:\n rdfize_entry.awk -v id_uri_prefix=\"URI PREFIX LIST\" [-v id_uri_abbrev=\"PREFIX ABBREV LIST\"] table_file" > "/dev/stderr"
        print " id_uri_prefix: A comma separated list of gene ID prefix URIs. At least one prefix is required." > "/dev/stderr"
        print " id_uri_abbrev:  A comma separated list of abbreviated names of gene ID prefix URIs." > "/dev/stderr"
        print "                 The same index element of 'id_uri_prefix' is regarded as the full name of the abbreviation." > "/dev/stderr"
        exit 1
    }
    FS = "\t"
    print "@prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#> ."
    print "@prefix sio:     <http://semanticscience.org/resource/> ."
    print "@prefix dcterms: <http://purl.org/dc/terms/> ."
    print "@prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> ."
    print "@prefix refex:   <http://refex.dbcls.jp/entry/> ."
    print "@prefix refexs:  <http://refex.dbcls.jp/sample/> ."
    print "@prefix refexo:  <http://purl.jp/bio/01/refexo#> ."
    print "@prefix pav:     <http://purl.org/pav/> ."
    print "@prefix foaf:    <http://xmlns.com/foaf/0.1/> ."

    split(id_uri_prefix, prefix, ",")
    id_uri_prefix_num = length(prefix)
    if(id_uri_abbrev) {
        split(id_uri_abbrev, abbrev, ",")
        for(i=1; i<=length(abbrev); i++)
            printf("@prefix %-8s <%s> .\n", abbrev[i] ":", prefix[i])
    }
    print
}

FNR>=2 {
    entryID = $1
    geneID = $2
    rseID = $3
    print "refex:" entryID
    print "\ta refexo:RefExEntry ;"
    print "\trdfs:label \"" entryID "\" ;"
    print "\trefexo:refexSample refexs:" rseID " ;"
    print "\tdcterms:identifier \"" entryID "\" ;"
    print "\tsio:SIO_000216 "
    print "\t\t[ a refexo:logTPMMin ;\n\t\t  sio:SIO_000300 " $11 " ] ,"
    print "\t\t[ a refexo:logTPM1stQu ;\n\t\t  sio:SIO_000300 " $12 " ] ,"
    print "\t\t[ a refexo:logTPMMedian ;\n\t\t  sio:SIO_000300 " $13 " ] ,"
    print "\t\t[ a refexo:logTPMMean ;\n\t\t  sio:SIO_000300 " $14 " ] ,"
    print "\t\t[ a refexo:logTPM3rdQu ;\n\t\t  sio:SIO_000300 " $15 " ] ,"
    print "\t\t[ a refexo:logTPMMax ;\n\t\t  sio:SIO_000300 " $16 " ] ,"
    print "\t\t[ a refexo:logTPMSD ;\n\t\t  sio:SIO_000300 " $17 " ] ;"

    printf "\trefexo:isMeasurementOf "
    first = 1 # true

    for(i=1; i<=id_uri_prefix_num; i++) {
        if(!first)
            printf ", "
        else
            first = 0
        if(abbrev[i])
            printf abbrev[i] ":" geneID " "
        else
            printf "<" prefix[i] geneID "> "
    }
    print ".\n"
}
