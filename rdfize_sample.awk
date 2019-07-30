#! /usr/bin/awk -f
### usage: rdfize_sample.awk sample_table_file

BEGIN {
    FS = "\t"
}

FNR>=2 {
    resID = $1
    desc = $2
    category = $3
    order = gensub("RES0*", "", "g", resID)

    print "refexs:" resID
    print "\ta refexo:RefExSample , sio:SIO_001050 ;"
    print "\trdfs:label \"" resID "\" ;"
    print "\tdcterms:identifier \"" resID "\" ;"
    print "\tdcterms:description \"" desc "\" ;"

    print "\tschema:additionalProperty ["
    print "\t\ta schema:PropertyValue ;"
    print "\t\tschema:name \"AlphabeticalUniqOrder\" ;"
    print "\t\tschema:value " order
    print "\t] , ["

    print "\t\ta schema:PropertyValue ;"
    print "\t\tschema:name \"SampleCategory\" ;"
    print "\t\tschema:value \"" category "\""
    print "\t] .\n"
}
