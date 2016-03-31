#!/usr/bin/perl

# interleave data from multiple years (columns and update 'matK || rbcL' fields)

# usage: merge_sampleYears.pl <infile1> <infile2> > STDOUT

$merges = 0;
$uniques_1 = 0;
$uniques_2 = 0;

# master IDs hash
%master;

# open 1 make a hash of lines
%input;
open(IONE,$ARGV[0]) or die "no input\t 1";

while(<IONE>){
	# assume UID is field 1, index 0
	chomp($line = $_);
	@fields = split(/t/,$line);
	$UID = $fields[0];
	$input{$UID} = $line;
}

# close 1
close(IONE);

# open 2 compare lines to hash
open(ITWO,$ARGV[1]) or die "no input 2\n\n";

#	if line exists, 
#		merge, removing from hash [ 'delete($key{$value})' ]
#		print merged to master hash

#	else 
#		print w/o merge (e.g. infile 2 not in infile 1) to master hash

warn "input hash size ".scalar(%input)." values.\nmaster hash size ".scalar(%master)." values.\nstarting 2\n";

while(<ITWO>){
	# assume UID is field 1, index 0
	chomp($line = $_);
	@fields = split(/t/,$line);
	$UID = $fields[0];
	#test UID
	if(exists($input{$UID})){
		# merge lines, remove from hash
		$existing = $input{$UID};
		$this = $line;
		#warn "merging $UID:\n\t$existing\n\t$this\n";
		@fields_this = split(/\t/,$line);
		@fields_existing = split(/\t/,$existing);
		@merged = ();
		#check lengths are equal
		if(scalar(@fields_this) != scalar(@fields_existing)){
			warn "lengths-mismatch: $UID, ".scalar(@fields_this)." != ".scalar(@fields_existing)."\n";
		}else{
			#lengths are equal we should be able to merge
			for($i=0;$i<scalar(@fields_existing);$i++){
				if($fields_this[$i] eq $fields_existing[$i]){
					#entries are the same (likely zero or name info). don't need to merge
					push(@merged,$fields_this[$i]);
				}else{
					if(($fields_this[$i] =~ /[A-Za-z]+/) or ($fields_existing[$i] =~ /[A-Za-z]+/)){
					# TODO
					# this represents some kind of text error, likely NAs e.g:
#merging 1573215	:
#	1573215	txid1573215	NA	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
#	1573215	txid1573215	Heuchera hallii	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
#merge-text-error: 1573215	, merging [ Heuchera hallii ] ne [ NA ]
					#					
						warn "merge-text-error: $UID, merging [ $fields_this[$i] ] ne [ $fields_existing[$i] ]\n";
						$merged_names='';
						#revision - move to string lengths
						$len_name_this = length($fields_this[$i]);
						$len_name_existing = length($fields_existing[$i]);
						
						if($len_name_this < $len_name_existing){
							$merged_names = $fields_existing[$i];
						}else{
							$merged_names = $fields_this[$i];
						}
						
						##
						#if(($fields_this[$i] eq 'NA')and($fields_existing[$i] ne 'NA')){
						#	$merged_names = $fields_existing[$i];
						#}else{
						#	$merged_names = $fields_this[$i];
						#}
						push(@merged,$merged_names);
					}else{
					# they should both be merge-able numbers
						$merge_nums = $fields_this[$i] + $fields_existing[$i];
						#print "merge-numbers: $UID, merging $fields_this[$i]  $fields_existing[$i] to $merge_nums\n";
						push(@merged,$merge_nums);
					}
				}
			}			
		}
		$master{$UID} = join("\t",@merged);
		delete($input{$UID});
		$merges++;
	}else{
		# don;t merge
		$master{$UID} = $line;
		$uniques_2++;
	}
}

# close 2
close(ITWO);

warn "input hash size ".scalar(%input)." values.\nmaster hash size ".scalar(%master)." values.\nstarting 2\n";

# print out remains of hash (e.g. infile 1, not in infile 2) to master hash
foreach $UID(sort(keys(%input))){
	$master{$UID} = $input{$UID};
	$uniques_1++;
}

warn "input hash size ".scalar(%input)." values.\nmaster hash size ".scalar(%master)." values.\nstarting 2\n";

# sort master hash keys, print to STDOUT
foreach $UID(reverse(sort(keys(%master)))){
	print $master{$UID}."\n";
}
warn "
merges\t= $merges;
uniques_1\t= $uniques_1;
uniques_2\t= $uniques_2;
";