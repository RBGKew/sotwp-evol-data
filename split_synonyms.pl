#read in synonyms list
open(SYN,$ARGV[1]) or die ("can't open $ARGV[1]\n");
%synonyms;
while(<SYN>){
	chomp($line=$_);
	@fields=split(/\t/,$line);
	if($fields[0] =~ /[0-9]+/){
		$synonyms{$fields[0]} = $line;
	}
}
close(SYN);
print "read in ".(keys(%synonyms))." synonym clusters\n";

#read in data and split off synonym clusters into separate list
open(IN,$ARGV[0]) or die ("can't open $ARGV[0]\n");
open(NSYN,'>',$ARGV[0].'.no-synonyms.tdf') or die ("can't open ".$ARGV[0].'no-synonyms.tdf'."\n");
open(ASYN,'>',$ARGV[0].'.all-synonyms.tdf') or die ("can't open ".$ARGV[0].'all-synonyms.tdf'."\n");

while(<IN>){
	chomp($line=$_);
	@fields=split(/\t/,$line);
	if($fields[0] =~ /[0-9]+/){
		if(exists($synonyms{$fields[0]})){
			print ASYN $line."\n";
		}else{
			print NSYN $line."\n";
		}
	}else{
		print NSYN $line."\n";
		print ASYN $line."\n";
	}
}
close(IN);
close(NSYN);
close(ASYN)
