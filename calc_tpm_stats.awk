#! /usr/bin/awk -f
### usage: calc_tpm_stats.awk -v entry_id_num=NUM eachsample_table_file tpm_table_file

function quantile(array, p,
                  q, l, t, v, nums, i) {
    for(i in array)
        nums[i] = array[i]
    # array must be sorted in advance
    q = p/4
    l = length(nums)
    t = (l-1)*q+1
    v = nums[int(t)]
    return v + (t-int(t)) * (nums[int(t)+1]-v)
}

function mean(nums,
              s, i) {
    s = 0
    for(i in nums)
        s += nums[i]
    return s/length(nums)
}

BEGIN {
    OFS = "\t"
    FS = "\t"

    if(!entry_id_prefix)
        entry_id_prefix = "RFX"

    if(!entry_id_num)
        entry_id_num = 1
}

FNR==NR {
    group_id[$2] = $1
    next
}

FNR==1 {
    for(i=2; i<=NF; i++) {
        if(!group_size[group_id[$i]])
            group_size[group_id[$i]] = 1
        else
            group_size[group_id[$i]]++
        group_element_column[group_id[$i], group_size[group_id[$i]]] = i
    }

    if(debug)
        for(id in group_size) {
            printf id
            for(j=1; j<=group_size[id]; j++)
                printf "\t" group_element_column[id, j]
            printf "\n"
        }

    print "ID\tGeneID\tSampleID\tMin\t1stQu\tMedian\tMean\t3rdQu\tMax\tSD"

    next
}

{
    for(id in group_size) {
        size = group_size[id]

        for(j=1; j<=size; j++) {
            tpm[j] = $(group_element_column[id, j])
            sqtpm[j] = tpm[j]*tpm[j]
        }
        asort(tpm, sorted)
        m = mean(sorted)
        entry_id = sprintf("%s%010d", entry_id_prefix, entry_id_num)
        if(size==1)
            sdOrZero = 0
        else
            sdOrZero = sqrt(size/(size-1)*(mean(sqtpm)-m*m))

        print entry_id, $1, id, quantile(sorted, 0), quantile(sorted, 1), quantile(sorted, 2), m, quantile(sorted, 3), quantile(sorted, 4), sdOrZero

        entry_id_num++

        delete(tpm)
        delete(sorted)
        delete(sqtpm)
    }
}
