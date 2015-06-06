#############################################################################
#
# retrieveTheirTweets.pl      		                  
#
# Description:
#  
#	This script will periodically retrieve the tweets of those you follow
#	Background: this is the second twitter API using script I wrote. It needs
#	to be re-factored. Right now it has two blocks of code that are almost 
# 	the same. The first block gets the initial set of tweets from the people
# 	that you follow, and then goes to sleep. The second block get the next set
#	of tweets and keeps looking until it loops to the value in $maxLoops.
# 	The reason for that is the first time we call the API, we don't use the 
#	high water value, while the second time you do. There is a better way to do
#	it: see my other program called retrieveMyTweets.pl
#
#	I wrote this and other programs as an exercise in calling the new twitter API. 
#	Feel free to modify it as you see fit.
#
# References:
#
# First thing I did was create an access token via https://apps.twitter.com/
# Then I found an OAuth library for Perl and twitter here:
# http://search.cpan.org/~mmims/Net-Twitter-Lite-0.12004/lib/Net/Twitter/Lite.pod
# More info here:
# http://search.cpan.org/~mmims/Net-Twitter-Lite-0.12004/lib/Net/Twitter/Lite/WithAPIv1_1.pod (v1.1)
#
# History:
#
#       2014.09.10	Initial implementation. (BLM)
#
# Examples:
#
#       To call the program, enter: 
#		perl retrieveTheirTweets.pl
#
#		To end the program, enter control+c. Or set the maxLoops variable to a
#		smaller number
#
##############################################################################
#
# Initialization of shell script

# Store the keys you get from https://apps.twitter.com/ in these 4 variables.
 #$consumer_key			=	'WaEYInYao1x6mZUrTJEfHeT9V';
 #$consumer_secret		=	'hO3oxvd2vZNqbaOD5JpXeo30bDQSjV3xAnrpMSUiqZvKnIm2hb';
 #$access_token			=	'2409477433-QmQfcuZxgPmttzAx3tNYZC14wvhqCT8UsPCBTdI';
 #$access_token_secret	=	'Beh8Ecyj3BGjCTWy7VuL6VoJUydemOOubW5ICRvBt0vq2';
 my $consumer_key			=	'gV13Qbm4MxZ4qwQoi3BhYaq9y';
 my $consumer_secret		=	'jry6nNhLQQm6pmMOveNa8gVIDQyhnBiiJnzsO39DMa7c4hXYsb';
 my $access_token			=	'4922631-M9l7nwz6DZyJK9ZfYQ0YmcgcWvN7S6LY4wxwpsvfk';
 my $access_token_secret	=	'EQ4wctEHxZKiGU0icr0DcydbYUUNfPhnlLiAXW58Bw';
 
my $high_water = 0;			# a variable to store the ID of the last tweet retrieved
my $maxLoops = 60;			# Quit the program
my $sleepPeriod = 300;		# Seconds to sleep before getting more tweets.
my $count = 100;			# Number of tweets to get each loop.
my $shortOutput = 1;		# = 0 if you want verbose output
my $noRTs = 1;				# = 0 if you want to see people's RTs.
 
# Prepare to use the Twitter API.

use Net::Twitter::Lite::WithAPIv1_1;	# Required to use ...
use Scalar::Util 'blessed';				# ... the Twitter API

my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
    consumer_key        => $consumer_key,
    consumer_secret     => $consumer_secret,
    access_token        => $access_token,
    access_token_secret => $access_token_secret,
	ssl => 1,
);

print "\n";
print "-----------\n";

$top_id_found = 0;	
$tweetcount = 0;
my $statuses = $nt->home_timeline({ count => $count  });	# Retrieve tweets

# Loop through the tweets received.
for my $status ( @$statuses ) {
	$IDx = $status->{id};
	my $timestamp = $status->{created_at};	
	my $statusOutput = $status->{text};
	
	#Get rid of any HTML tags that look ugly.
	$statusOutput =~ s/[^[:ascii:]]+//g; 	# get rid of non-ASCII characters that cause print errors
	$statusOutput =~ s/&amp;/&/g; 			# get rid of HTML like characters
	$statusOutput =~ s/&gt;/>/g; 			# get rid of HTML like characters
	$statusOutput =~ s/&lt;/</g; 			# get rid of HTML like characters
	
	# Display the tweet and increase $tweetcount
	if ($statusOutput !~ m/^RT/) {
		if ($shortOutput eq 1) {
			print "$status->{user}{screen_name}\t$statusOutput\n";
		} else {
			print "$IDx\t$timestamp\t$status->{user}{screen_name}\t$statusOutput\n";
		};
	};
		
	$tweetcount++;
	
	# If we have not found the top ID yet, then the ID for this tweet is the top ID.
	# Set the $high_water value to this ID. When we retrieve the next set of tweets, 
	# we will start at that from that tweet.
	
	if ($top_id_found eq 0) {
		$high_water = $IDx;
		$top_id_found = 1;
	};
};

# The initial block is completed. Now we start with the second block.
# It is more or less the same as the first block. The main difference
# is the call to the twitter API. It also shows the "tweet speed".

for (my $i=1; $i <= $maxLoops; $i++) {
	sleep($sleepPeriod);
	$top_id_found = 0;
	print "----------- Tweet speed is " . ($tweetcount * 60 / $sleepPeriod) . " per minute -----------\n";
	$tweetcount = 0;
	my $statuses = $nt->home_timeline({ since_id => $high_water, count => $count  });
	
    for my $status ( @$statuses ) {
		$IDx = $status->{id};
		my $statusOutput = $status->{text};
		$statusOutput =~ s/[^[:ascii:]]+//g; 	# get rid of non-ASCII characters that cause print errors
		$statusOutput =~ s/&amp;/&/g; 			# get rid of HTML like characters
		$statusOutput =~ s/&gt;/>/g; 			# get rid of HTML like characters
		$statusOutput =~ s/&lt;/</g; 			# get rid of HTML like characters
		my $timestamp = $status->{created_at};
		
		if ($statusOutput !~ m/^RT/) {
			if ($shortOutput eq 1) {
				print "$status->{user}{screen_name}\t$statusOutput\n";
			} else {
				print "$IDx\t$timestamp\t$status->{user}{screen_name}\t$statusOutput\n";
			};
		};
		
		$tweetcount++;
		if ($top_id_found eq 0) {
			$high_water = $IDx;
			$top_id_found = 1;
		};
    };
};