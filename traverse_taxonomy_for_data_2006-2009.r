# required libraries
library(rentrez)
library(parallel)
##library(ggplot2)

#don't repeat the query if there's an active one in the workspace, it takes a while
#plant_tax=entrez_search(db="taxonomy",term="(embryophyta[Subtree]) AND \"species\"[Rank]",retmax=136300)
#str(plant_tax)

#plant_tax_ids_all = plant_tax$ids
#plant_tax_ids_100 = plant_tax$ids[1:100]

count_taxon_lanks <- function(some_id){
  #specify variables
  sci_name = 'NA'
  txid = paste('txid',some_id,sep='')
  nuccore_total = 0
  any_rbcL = 0
  any_matK = 0
  elink_someid_nuc = ''
  
  # counts are now specified for each year in (1985:2015)
  nuccore_count = rep(0,30) # how many nucleotide records in nuccore, any locus
  rbcL_count = rep(0,30)  # how many rbcL records in nuccore
  matK_count = rep(0,30)  # how many matK records in nuccore
  either_count = rep(0,30)  # how many rbcL *OR* matK records in nuccore
  # forget genomes, too few and it'll take ages..
  # genome_count = rep(0,30)  # how many records in genome, nuclear only - no plastids/chloroplasts or mitochondria
  # call would be something like 
  #   genome_count = entrez_search(db='genome',term="txid4530[Organism] AND (\"1985\"[Create Date] : \"2002/04/03\"[Create Date])")$count
  
  # try and get the scientific name
  try((
    sci_name = entrez_summary(db="taxonomy",id=some_id)$scientificname
  ),silent=TRUE)
  
  # is there any nuccore data *at* *all*? if not don't bother iterating...
  try((
    elink_someid_nuc = entrez_link(dbfrom="taxonomy",id=some_id,db="nucleotide")
  ),silent=TRUE)
  try((nuccore_total = length(elink_someid_nuc$links$taxonomy_nuccore)),silent=TRUE)
  
  print(paste(sci_name,'total',nuccore_total,collapse=' '))
  
  if(nuccore_total > 0){
    # try and get dem numbers.... iterate from 1:30
    # any rbcL at all?    
    any_rbcL= try(entrez_search(db="nucleotide",term=paste(txid,"[Orgn] AND rbcL[Gene]",sep=''))$count,silent=TRUE)
    # any matK at all?    
    any_matK= try(entrez_search(db="nucleotide",term=paste(txid,"[Orgn] AND matK[Gene]",sep=''))$count,silent=TRUE)
    
    for(i in seq(from=24,to=21,by=-1)){
      # set the 'to' year. years are defined as any date yyyy/mm/dd with yyyy==pdat, inclusive
      pyear = 1985 + i
      # attempt to get the data... do we need try clauses for this...?
      if(any_rbcL > 0){
        #   mcparallel({
        # fork process
        q_rbcL=paste(txid,"[Orgn] AND rbcL[Gene] AND (\"1985/01/01\"[PDAT] : \"",pyear,"\"[PDAT])",sep='')
        rbcL_count[i] = try(entrez_search(db="nucleotide",term=q_rbcL)$count,silent=TRUE)
        # decrement any_rbcL to the current time-window total, to avoid querying dead years
        any_rbcL = rbcL_count[i]
        #    })
      }
      if(any_matK > 0){
        #   mcparallel({
        # fork process
        q_matK=paste(txid,"[Orgn] AND matK[Gene] AND (\"1985/01/01\"[PDAT] : \"",pyear,"\"[PDAT])",sep='')
        matK_count[i] = try(entrez_search(db="nucleotide",term=q_matK)$count,silent=TRUE)
        # decrement any_matK to the current time-window total, to avoid querying dead years
        any_matK = matK_count[i]
        #    })
      }
      if(nuccore_total > 0){
        #  mcparallel({
        # fork process
        q_any=paste(txid,"[Orgn] AND (\"1985/01/01\"[PDAT] : \"",pyear,"\"[PDAT])",sep='')
        nuccore_count[i] = try(entrez_search(db="nucleotide",term=q_any)$count,silent=TRUE)
        # decrement nuccore total to the current time-window total, to avoid querying dead years
        nuccore_total = nuccore_count[i]
        
        #  })
      }
    }
  }

  # collapse the count vectors to tdf strings
  nuccore_count = paste(nuccore_count,collapse="\t") # how many nucleotide records in nuccore, any locus
  rbcL_count = paste(rbcL_count,collapse="\t")  # how many rbcL records in nuccore
  matK_count = paste(matK_count,collapse="\t")  # how many matK records in nuccore
  either_count = paste(either_count,collapse="\t")  # how many rbcL *OR* matK records in nuccore
  #genome_count = paste(genome_count,collapse="\t")  # how many records in genome, nuclear only - no plastids/chloroplasts or mitochondria
  
  #write output
  output = paste(some_id,txid,sci_name,nuccore_count,rbcL_count,matK_count,either_count,collapse="\t",sep="\t")
  write(output,file="ncbi_stats_detailed_2006-2009.tdf",append=TRUE)
  #Sys.sleep(1)
}

list_taxon_links <- function(some_id){
  sci_name = 'NA'
  nuccore_count = 'NA'
  genome_count = 'NA'
  # try and get the scientific name
  try((
    sci_name = entrez_summary(db="taxonomy",id=some_id)$scientificname
    ),silent=TRUE)
  # try and get the nuccore count
  try((
    elink_someid_nuc = entrez_link(dbfrom="taxonomy",id=some_id,db="nucleotide")
    ),silent=TRUE)
  try((
    nuccore_count = length(elink_someid_nuc$taxonomy_nuccore)
    ),silent=TRUE)
  # try and get the genome count
  try((
    elink_someid_gen = entrez_link(dbfrom="taxonomy",id=some_id,db="genome")
    ),silent=TRUE)
  try((
    genome_count = length(elink_someid_gen$taxonomy_genome)
    ),silent=TRUE)
  output = paste(some_id,"\t",sci_name,"\t",nuccore_count,"\t",genome_count)
  write(output,file="myfile",append=TRUE)
  ##Sys.sleep(1)
}

# for(i in 1:length(plant_tax_ids_100)){
#   sci_name = 'NA'
#   try(
#     (sci_name = entrez_summary(db="taxonomy",id=some_id)$scientificname)
#   )
#   output = paste(some_id,"\t",sci_name)
#   write(output,file="myfile",append=TRUE)
# }
