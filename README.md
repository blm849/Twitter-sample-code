# Twitter-sample-code

This repo contains various Twitter sample code I have written over the years.

The first twitter code I wrote was tweet.pl. It is a looping program that will ask you for something to tweet, tweet it for you, and then
ask you again. It will loop until you simply press the Enter key.

The second twitter code I wrote was retrieveTheirTweets.pl. It will act as a command line twitter client for you. It will retrieve all the tweets
of the people you follow, wait so many seconds, and then retrieve the next set of tweets of people you follow. I used this program to experiment
with my ability to use the twitter API. I added some features like the ability to turn off RTs from people, as well as to show the "velocity" or 
rate of tweets I get.

The third set of twitter code I wrote was retrieveMyTweets.pl and retrieveMyFavs.pl. These program will retrieve all your tweets and all your 
favorites. There is a flag in the program that if you set it to 1, it will delete the tweets and favs as well. It is a good way to start again and 
clear out your tweets and favs. Or you can just use it as a way to back them up.

The third set of twitter code is (I believe) better and more sophisticated code than the second and first sets. Each program gives you an idea on
how to use the Twitter interface.

I have two version of perl running on my machine: a 32 bit and a 64 bit version. The 64 bit version is the default one. However, the twitter API 
code I am runs under 32 bit perl. That is why I have all these BAT files: to bypass the 64 bit perl and involve the 32 bit version.

The 32 bit version is v5.10.1 from ActiveState (http://www.ActiveState.com)

Besides my code and Perl, you will need to get your own keys. You can do that here: 
https://dev.twitter.com/docs/api/1.1

Once you have the keys, to make hello.pl work, you will need to copy them into the hello.pl program.

For the other code, make your own *.cfg file (e.g. myown.cfg), add your key values to the new .cfg file, and then call the program with cfg file
as a parameter. For example:

c:\perl\bin\perl retrieveMyTweets.pl myown.cfg

You are also going to need the OAuth library for perl. Go here for that:
 http://search.cpan.org/~mmims/Net-Twitter-Lite-0.12004/lib/Net/Twitter/Lite.pod

I used the sample code in the synopsis section to build my code.

Other notes I took:
To install the library, I had to use cpan. I couldn't do it through the regular cmd prompt. I had to do it through the Microsoft SDK environment cmd shell. Then it would work.


