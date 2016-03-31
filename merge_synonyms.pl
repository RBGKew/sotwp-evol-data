#read in data and compile hash indexed on kew ID (field [7])
open(IN,$ARGV[0]) or die ("can't open $ARGV[0]\n");
open(OUT,'>',$ARGV[0].'.merged-synonyms.tdf') or die ("can't open ".$ARGV[0].'merged-synonyms.tdf'."\n");

%synonyms;
while(<IN>){
	chomp($line=$_);
	@fields=split(/\t/,$line);
	#print "vacant: $fields[7]\t";
	#print "$fields[8]\n";
	if($fields[0] =~ /[0-9]+/){
		if(exists($synonyms{$fields[7]})){
			print "exists: $fields[7]\n";
			#merge them
			#setting field[5] val to synonym cluster
			#check lengths equal
			@new=@fields;
			@ext=split(/\t/,$synonyms{$fields[7]});
			if(scalar(@new) != scalar(@ext)){
				warn "NOT MERGING: unqeual lengths: ".scalar(@new)."!=".scalar(@ext)."\n";
			}else{
				print "merging:\n\t$new[5] $new[0] $new[2] $new[7] $new[8]\n\t$ext[5] $ext[0] $ext[2] $ext[7] $ext[8]\n";
				$accepted_name; #try and preserve the accepted name
				if($ext[5] =~ /[A]+/){
					$accepted_name = $ext[2];
					print "retain name $accepted_name\n";
					$ext[5] .= 'Accepted.namecluster';
					$ext[2] = $accepted_name;
				}else{
					if($new[5] =~ /[A]+/){
						$accepted_name = $new[2];
						print "retain name $accepted_name\n";
						$ext[5] = 'Accepted.namecluster';
						$ext[2] = $accepted_name;
					}
				}
				for($i=11;$i<scalar(@ext);$i++){
					$ext[$i] = $ext[$i] + $new[$i];
					#loopthrough adding values
				}
				$synonyms{$fields[7]} = join("\t",@ext);
				#replace the existing $key with this val
			}
			print "\n";
		}else{
			#print "vacant: $fields[7]\n";
			$synonyms{$fields[7]} = $line;
		}
	}else{
		print OUT $line."\n";
	}
}

#print out all setting field[5] val to synonym cluster
close(IN);

foreach $key(keys(%synonyms)){
	print OUT $synonyms{$key}."\n";
}
close(OUT);
