# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 1 };
use Device::LabJack;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

$idnum=-1;
$demo=0;
$stateIO=0;
$updateIO=0;
$ledOn=1;
@channels=(0,1,2,3);
@gains=(0,0,0,0);
$disableCal=0;

print "If you can see 4 status values followed by your current 8 AI voltages below, then this test has passed:-\n";

print "\nAISample(channels 0,1,2,3):-\n";

my(@results)=Device::LabJack::AISample($idnum,$demo,$stateIO,$updateIO,$ledOn,\@channels,\@gains,$disableCal);
print join("\n",@results);

print "\n\nAISample(channels 4,5,6,7):-";

@channels=(4,5,6,7);
my(undef,undef,undef,undef,@results)=Device::LabJack::AISample($idnum,$demo,$stateIO,$updateIO,$ledOn,\@channels,\@gains,$disableCal);
print join("\n",("",@results));


print "\n\nAOUpdate(write):-\n";

$trisD=1;
$trisIO=2;
$stateD=1;
$stateIO=2;
$updateDigital=1;
$resetCounter=1;
$analogOut0=2.1;
$analogOut1=4.2;

my(@results)=Device::LabJack::AOUpdate($idnum,$demo,$trisD,$trisIO,$stateD,$stateIO,$updateDigital,$resetCounter,$analogOut0,$analogOut1);

print join("\n",@results);



print "\n\nAOUpdate (read):-\n";

$trisD=1;
$trisIO=2;
$stateD=4;
$stateIO=8;
$updateDigital=0;
$resetCounter=0;
$analogOut0=2.1;
$analogOut1=4.2;

my(@results)=Device::LabJack::AOUpdate($idnum,$demo,$trisD,$trisIO,$stateD,$stateIO,$updateDigital,$resetCounter,$analogOut0,$analogOut1);

print join("\n",@results);



print "\n\nAIBurst:-\n";

$scanRate=456;
$triggerIO=0;
$triggerState=0;
$numScans=20;
$timeout=2;
$transferMode=0;


my(@results)=Device::LabJack::AIBurst($idnum,$demo,$stateIO,$updateIO,$ledOn,\@channels,\@gains,$scanRate,$disableCal,$triggerIO,$triggerState,$numScans,$timeout,$transferMode);


print join(", ",@results);



