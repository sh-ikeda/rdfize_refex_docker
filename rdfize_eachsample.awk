#! /usr/bin/awk -f
### usage: rdfize_eachsample.awk [-v id_uri_prefix=\"URI PREFIX LIST\"] [-v id_uri_abbrev=\"PREFIX ABBREV LIST\"] table_file

BEGIN {
    if(!id_uri_prefix) { # no command line variable is required.
        print "WARNING: id_uri_prefix is not given." > "/dev/stderr"
        print "usage:\n rdfize_eachsample.awk [-v id_uri_prefix=\"URI PREFIX LIST\"] [-v id_uri_abbrev=\"PREFIX ABBREV LIST\"] table_file" > "/dev/stderr"
        print " id_uri_prefix: A comma separated list of sample ID prefix URIs." > "/dev/stderr"
        print " id_uri_abbrev: A comma separated list of abbreviated names of sample ID prefix URIs." > "/dev/stderr"
        print "                The same index element of 'id_uri_prefix' is regarded as the full name of the abbreviation." > "/dev/stderr"
    }
    FS = "\t"
    print "@prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#> ."
    print "@prefix sio:     <http://semanticscience.org/resource/> ."
    print "@prefix dcterms: <http://purl.org/dc/terms/> ."
    print "@prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> ."
    print "@prefix refexs:  <http://refex.dbcls.jp/sample/> ."
    print "@prefix refexo:  <http://purl.jp/bio/01/refexo#> ."
    print "@prefix bs:      <http://rdf.ebi.ac.uk/resource/biosamples/sample/> ."
    print "@prefix pav:     <http://purl.org/pav/> ."
    print "@prefix foaf:    <http://xmlns.com/foaf/0.1/> ."
    print "@prefix schema:  <http://schema.org/> ."

    split(id_uri_prefix, prefix, ",")
    id_uri_prefix_num = length(prefix)
    if(id_uri_abbrev) {
        split(id_uri_abbrev, abbrev, ",")
        if(length(abbrev) > id_uri_prefix_num)
            n = id_uri_prefix_num
        else
            n = length(abbrev)
        for(i=1; i<=n; i++)
            printf("@prefix %-8s <%s> .\n", abbrev[i] ":", prefix[i])
    }
    print

    FS = "\t"
    prev_sample = ""
}

FNR>=2 {
    rseID = $1
    bsID = $2     # BioSampleID
    sampleID = $3 # ID given by each project
    if(rseID!=prev_sample) {
        if(FNR!=2)
            print "\t] .\n"
        print "refexs:" rseID
        print "\trefexo:sampleReference ["
    }
    else
        print "\t] , ["

    print "\t\trdfs:label \"" sampleID "\" ;"
    printf "\t\trdfs:seeAlso bs:" bsID
    for(i=1; i<=id_uri_prefix_num; i++) {
        printf ", "
        if(abbrev[i])
            printf abbrev[i] ":" sampleID " "
        else
            printf "<" prefix[i] sampleID "> "
    }
    printf "\n"

    prev_sample = rseID
}

END {
    print "\t] ."
}
