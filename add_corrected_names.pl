#read in correct names list
open(NAMES,$ARGV[1]) or die ("can't open $ARGV[1]\n");
%correct_names;
$header;
while(<NAMES>){
	chomp($line=$_);
	@fields=split(/\t/,$line);
	if($fields[0] =~ /[0-9]+/){
		$correct_names{$fields[0]} = $line;
	}else{
		$header = $line;
	}
}
close(NAMES);
print "read in ".(keys(%correct_names))." name vals\n";

#read in data and append correct names
open(IN,$ARGV[0]) or die ("can't open $ARGV[0]\n");
open(OUT,'>',$ARGV[0].'.correct_names.tdf') or die ("can't open ".$ARGV[0].'correct_names.tdf'."\n");

while(<IN>){
	chomp($line=$_);
	@fields=split(/\t/,$line);
	if($fields[0] =~ /[0-9]+/){
		if(exists($correct_names{$fields[0]})){
			#print "match $fields[0] data $correct_names{$fields[0]}\n";
			print OUT $correct_names{$fields[0]}."\t".$line."\n";
		}else{
			print "ODD: no name found $fields[0]\n";
		}
	}else{
		print OUT $header."\t".$line."\n";
	}
}
close(IN);
close(OUT);
