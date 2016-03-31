# Get the list of vascular only taxa
vascular_tax=entrez_search(db="taxonomy",term="(tracheophyta[Subtree]) AND \"species\"[Rank]",retmax=150000)

# Compare the vascular-only list to the final data to include only vascular plants
final_vasc=final[is.element(final$some_id,vasc),]

#### generate the (rbcL || matK) data:
for (i in 1:30){
  i_rbcL = 41+i
  i_matK = 71+i
  i_both = 101+i
  final_vasc[,i_both] = final_vasc[i_rbcL] + final_vasc[,i_matK]
}
### write out the column totals - counts of all nucleotides
write.table(colSums(final_vasc[,12:131]),"final_vascular_only_colSums.tdf",row.names=F,col.names=T,sep="\t")
# these then need to be reformatted in a text editor to give 4 series from 1986-2015 (all,rbcL,matK,(rbcL|matK))

### write out the column totals - counts of number of spp. with >0 sequences in each category
write.table(colSums(final_vasc != 0, na.rm=T),"final_vascular_only_colSums-nonzero.tdf",sep="\t")
# these then need to be reformatted in a text editor to give 4 series from 1986-2015 (all,rbcL,matK,(rbcL|matK))

#### with new source data, plot the total nucleotide record counts
totals=read.table("final_vascular_only_colSums.formatted.tdf",header=T,sep="\t")
quartz()
plot(totals$Year,log10(totals$All),xlab="year",sub="(zero years ommitted, including 1990 and earlier)",ylab="count of #total records (log10)",main="Embryophyta sequences in NBCI/EBI/DDBJ")
lines(totals$Year,log10(totals$All))
points(totals$Year,log10(totals$rbcL),col="red")
points(totals$Year,log10(totals$matK),col="blue")
points(totals$Year,log10(totals$rbcL.or.matK),col="green")
lines(totals$Year,log10(totals$rbcL.or.matK),col="green")
lines(totals$Year,log10(totals$matK),col="blue")
lines(totals$Year,log10(totals$rbcL),col="red")
legend(1985,7,"any sequence",fill="black",lwd=2)
legend(1985,6.5,"rbcL gene",fill="red",lwd=2)
legend(1985,6,"matK gene",fill="blue",lwd=2)
legend(1985,5.5,"matK or rbcL",fill="green",lwd=2)
#rect(2010.5,0,2014.5,5,lty=3,col="#9c9c9c33")

#### with new source data, plot the number of species with >0 nucleotide record counts
totals_counts=read.table("final_vascular_only_colSums-nonzero.formatted.tdf",header=T,sep="\t")
quartz()
plot(totals_counts$Year,log10(totals_counts$All),xlab="year",sub="(zero years ommitted, including 1990 and earlier)",ylab="count of #species with ≥1 sequence record (log10)",main="Embryophyta sequences in NBCI/EBI/DDBJ")
lines(totals_counts$Year,log10(totals_counts$All))
points(totals_counts$Year,log10(totals_counts$rbcL),col="red")
points(totals_counts$Year,log10(totals_counts$matK),col="blue")
points(totals_counts$Year,log10(totals_counts$rbcL.or.matK),col="green")
lines(totals_counts$Year,log10(totals_counts$rbcL.or.matK),col="green")
lines(totals_counts$Year,log10(totals_counts$matK),col="blue")
lines(totals_counts$Year,log10(totals_counts$rbcL),col="red")
legend(1985,3.5,"matK or rbcL",fill="green",lwd=2)
legend(1985,4,"matK gene",fill="blue",lwd=2)
legend(1985,4.5,"rbcL gene",fill="red",lwd=2)
legend(1985,5,"any sequence",fill="black",lwd=2)
