# required libraries
#library(rentrez)
##library(ggplot2)

#don't repeat the query if there's an active one in the workspace, it takes a while
#plant_tax=entrez_search(db="taxonomy",term="(embryophyta[Subtree]) AND \"species\"[Rank]",retmax=136300)
str(plant_tax)

#plant_tax_ids_all = plant_tax$ids
#plant_tax_ids_100 = plant_tax$ids[1:100]

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