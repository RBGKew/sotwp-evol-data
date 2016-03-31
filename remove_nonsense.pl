
open(NONS,$ARGV[1]) or die ("can't open $ARGV[1]\n");
@nonsense_ids;
while(<NONS>){
	chomp($line=$_);
	@fields=split(/\t/,$line);
	if($fields[0] =~ /[0-9]+/){
		push(@nonsense_ids,$fields[0]);
	}
}
close(NONS);
my %nons= map { $_ => 1 } @nonsense_ids;
print "read in ".(keys(%nons))." nonsense vals\n";

open(IN,$ARGV[0]) or die ("can't open $ARGV[0]\n");
open(OUT,'>',$ARGV[0].'.noNonsense.tdf') or die ("can't open ".$ARGV[0].'noNonsense.tdf'."\n");

$removed;
while(<IN>){
	chomp($line=$_);
	@fields=split(/\t/,$line);
	if($fields[0] =~ /[0-9]+/){
		if(!exists($nons{$fields[0]})){
			print OUT $line."\n";
		}else{
			print "\tnonsense: $fields[0]\n";
			$removed++;
		}
	}else{
		print OUT $line."\n";
	}
}
close(IN);
close(OUT);
print "removed $removed\n";
