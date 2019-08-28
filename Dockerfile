FROM alpine:3.10
RUN apk add --no-cache gawk
WORKDIR /usr/local/bin
COPY ./calc_tpm_stats.awk ./merge_tpm.awk ./rdfize_eachsample.awk ./rdfize_entry.awk ./rdfize_sample.awk ./
RUN chmod 755 ./*awk
CMD ["sh"]
