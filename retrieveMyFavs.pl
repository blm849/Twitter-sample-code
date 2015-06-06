#####################################################################################################
#
# retrieveMyFavs.pl      		                  
#
# Description:
#  
#	This script will retrieve your favorites, optionally deleting them as it goes along.
#
# History:
#
#       2014.12.02	Initial implementation. (BLM)
#       2014.12.08  Disable creation of status message. If none provided, then don't update it.
#
# Examples:
#
#       To call the program, enter: 
#		retrieveMyFavs.pl argument1 argument2
#
#		Where the first argument is a file name of a configFile passed to this program.
#		(e.g. configFile = blm849.cfg or blmtest849.cfg)
#		The config file must contains the following four lines
#		$consumer_key='xxxx';
#		$consumer_secret='yyyy';
#		$access_token='aaaa';
#		$access_token_secret='bbbb';
#       These variables are assigned values that allow this program to talk to twitter's API
#		This config file can also have other variable assignment statements in it, as well as 
# 		comments like this. Any additional lines are optional.
#
#		The second argument is a string (e.g. "Program is done") that is sent as a tweet after the
#		script is complete.
#
#		The first arguments are mandatory.
#
#####################################################################################################

# Process input parameters
my $configFile = $ARGV[0];
my $newStatusMessage = $ARGV[1];

# If a status message wasn't provided, create one.
# Disable creation of status message. 
# if ($newStatusMessage eq '') {$newStatusMessage = $0 . " running on " . localtime(time)};

# Initialize variables used by this program.
my $sleepPeriod = 60;					# Sleep for a minute
my $count = 200;						# max # of favorites to retrieve at one time
my $maxLoops = 25;						# number of times to call the API
my $outputFile = "favorites.tsv";		# file to archive favorites to
my $deleteFavorites = 0;				# = 0 if you don't delete favorites.

# These variables are counters and place holders used by the script.
my $totalCount = 0;
my $loopCount = 0;
my $max_id = '';
my $firstFlag;
my $lastIDOutput = '';
my $keepLooping = 1;

# Read in and evaluate the config file. The config file can override the initial variable values.

open CONFIG, "$configFile" or die "Exiting. Couldn't find the config file you passed " . $configFile;
my $config = join "", <CONFIG>;
close CONFIG;
eval $config;
die "Couldn't intrepret $configFile\nError details follow: $@\n" if $@;

# Set up the Perl modules we are going to use.
use Scalar::Util 'blessed'; 
use Net::Twitter::Lite::WithAPIv1_1;

my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
     consumer_key        => $consumer_key,
     consumer_secret     => $consumer_secret,
     access_token        => $access_token,
     access_token_secret => $access_token_secret,
	 ssl => 1,
);

# MYFILE is where the favorites will be printed to.
open (MYFILE, '>>' . $outputFile) || die "Could not write to " . $outputFile . "\n";

# The main part of the script. Keep looping until a condition occurs that 
# forces the program to exit (e.g., get to the end of the favorites).

while ($keepLooping) {

	# Retrieve your favorites. If $max_id is blank, then we have not 
	# requested any favorites yet and this is the first time through
	# Since it is the first time through, set $firstFlag to 1.
	# If it is not blank, then ask for the next 
	# batch of favorites, starting with the one whose ID equals $max_id and
	# set $firstFlag to 0.

	if ($max_id eq '') {
		$favorites = $nt->favorites({ count => $count  });
		$firstFlag = 1;
	} else  {
		$favorites = $nt->favorites({ max_id => $max_id, count => $count  });
		$firstFlag = 0;
	}; 
	
	# If first flag is true, then this is the first time processing favorites so 
	# proceed as long as one or more favorites came back.
	# However, if this is not the first time through and all you have
	# retrieved is one favorite, then you are at the end of the favorites and 
	# you should exit.
	
	if (($firstFlag && @$favorites[0] ne "" ) || (@$favorites[1] ne "")) {

		# Update the user with a status update.
		print "retrieving the next " . $count . " favs. Current total count is " . $totalCount . "\n";

		#Loop through the favorites retrieved.
		
		for my $favorite ( @$favorites ) {
			$IDx = $favorite->{id};
			$favoriteOutput = $favorite->{text};
			$favoriteOutput =~ s/[^[:ascii:]]+//g; 	# get rid of non-ASCII characters that cause print errors
			$favoriteOutput =~ s/&amp;/&/g; 		# get rid of HTML like characters
			$favoriteOutput =~ s/&gt;/>/g; 			# get rid of HTML like characters
			$favoriteOutput =~ s/&lt;/</g; 			# get rid of HTML like characters
			$timestamp = $favorite->{created_at};
			$screenName = $favorite->{user}{screen_name};
	
			# Output (ie. print) this favorite if we have not output it already.
			
			if ($IDx ne $lastIDOutput) {
				print "$IDx\t$timestamp\t$screenName\t$favoriteOutput\n";
				print MYFILE "$IDx\t$timestamp\t$screenName\t$favoriteOutput\n";
				$lastIDOutput = $IDx;
				$max_id = $IDx;
				
				# If deleteFavorites is 1, then delete any favorites we print.
				if ($deleteFavorites eq 1) {
					my $dead_favorite = $nt->destroy_favorite({ id => $IDx });
				};
				$totalCount++;	# Update the total count.
			};
		} ;
	} else {
		$keepLooping = 0;
		print "Could not retrieve any more favorites.\n";
	};
	
	# We are at the end of the loop, so increment the loop count and then
	# see if we are at the maximum number of loops, and if we are, turn off
	# keep looping flag.
	
	$loopCount++;
	if ($loopCount >= $maxLoops) {
		$keepLooping = 0;
	}
	
	# Finally, before we loop back to the top to make more requests to the 
	# twitter API. Twitter will not let you continually use the API. 
	# You need to pause. If you are to keep looping, then this sleep 
	# statement allows us to comply with the wait time requested.
	
	if ($keepLooping) {
		print "Sleeping for " . $sleepPeriod . " seconds.\n";
		sleep($sleepPeriod);
	};
};

# Retrieval of tweets done. Update your twitter feed if a message was 
# provide. Then close MYFILE.
if ($newStatusMessage ne '') {
	my $result = $nt->update($newStatusMessage);
};
