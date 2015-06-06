#############################################################################
#
# tweet.pl      		                  
#
# Description:
#  
#	This script will allow you to tweet from a command line
#
# History:
#
#       2014.08.11	Initial implementation. (BLM)
#
# Examples:
#
#       To call the program, enter: 
#		perl tweet.pl
#
#		To end the program, enter a null string
#
##############################################################################
#
# Initialization of shell script

 $consumer_key			=	'fillThisInWithYourData';
 $consumer_secret		=	'fillThisInWithYourData';
 $access_token			=	'fillThisInWithYourData-fillThisInWithYourData';
 $access_token_secret	=	'fillThisInWithYourData';
 
 use Net::Twitter::Lite::WithAPIv1_1;
 use Scalar::Util 'blessed';

  my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
      consumer_key        => $consumer_key,
      consumer_secret     => $consumer_secret,
      access_token        => $access_token,
      access_token_secret => $access_token_secret,
	  ssl => 1,
  );
  
$keepTweeting = 1;
$quitOn = "";
  
# Main body of the shell script.


while ($keepTweeting) {
	system("CLS");	# Clear the CMD window

	print "Enter your tweet (or a blank line to quit) \n";

	$line = <STDIN>;
	chomp ($line);
	
	if ($line eq $quitOn) { 
		$keepTweeting = 0;
	} else {
		my $result = $nt->update($line);
	};
}

#
# Finalization  of the script and exit.
# 

exit(0);

