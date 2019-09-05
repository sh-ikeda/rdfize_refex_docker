#! /usr/bin/awk -f
### usage: calc_tpm_stats.awk -v entry_id_num=NUM eachsample_table_file tpm_table_file

function quantile(array, p,
                  q, l, t, v, nums, i) {
    for(i in array)
        nums[i] = array[i]
    l = length(nums)

    # array must be sorted in advance
    for(i=1; i<l; i++)
        if(nums[i] > nums[i+1]) {
            print "error: invalid argument: `array` for `quantile` must be sorted" > "/dev/stderr"
            exit 1
        }

    if((p<0 || p>4) || p!=int(p)) {
        print "error: invalid argument: `p` for `quantile` must be integer and 0<=p<=4 ."
        exit 1
    }

    q = p/4
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

    if(!entry_id_num) {
        entry_id_num = 1
        print "WARNING: `-v entry_id_num` is not given. Without this, RFX ID of the output begins from RFX0000000001, which might be inappropriate."
    }
}

FNR==NR {
    group_id[$2] = $1
    next
}

FNR==1 {
    for(i=2; i<=NF; i++) {
        if(!group_id[$i]) {
            print "ERROR: Sample ID " $i " is not assigned RES ID." > "/dev/stderr"
            exit 1
        }
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

    print "ID\tGeneID\tSampleID\tMin\t1stQu\tMedian\tMean\t3rdQu\tMax\tSD\tlogMin\tlog1stQu\tlogMedian\tlogMean\tlog3rdQu\tlogMax\tlogSD"

    next
}

{
    for(id in group_size) {
        size = group_size[id]

        for(j=1; j<=size; j++) {
            tpm[j] = $(group_element_column[id, j])
            sqtpm[j] = tpm[j]^2
        }
        asort(tpm, sorted)

        for(j=1; j<=size; j++) {
            logtpm[j] = log(sorted[j]+1)/log(2)
            sqlogtpm[j] = logtpm[j]^2
        }

        m = mean(sorted)
        lm = mean(logtpm)
        entry_id = sprintf("%s%010d", entry_id_prefix, entry_id_num)
        if(size==1) {
            sdOrZero = 0
            log_sdOrZero = 0
        }
        else {
            sdOrZero = sqrt(size/(size-1)*(mean(sqtpm)-m^2))
            log_sdOrZero = sqrt(size/(size-1)*(mean(sqlogtpm)-lm^2))
        }

        print entry_id, $1, id, quantile(sorted, 0), quantile(sorted, 1), quantile(sorted, 2), m, quantile(sorted, 3), quantile(sorted, 4), sdOrZero, quantile(logtpm, 0), quantile(logtpm, 1), quantile(logtpm, 2), lm, quantile(logtpm, 3), quantile(logtpm, 4), log_sdOrZero

        entry_id_num++

        delete(tpm)
        delete(sorted)
        delete(sqtpm)
        delete(logtpm)
        delete(sqlogtpm)
    }
}
