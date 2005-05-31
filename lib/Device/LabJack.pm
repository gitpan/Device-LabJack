package Device::LabJack;

use 5.006;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Device::LabJack ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Device::LabJack', $VERSION);

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

LJperl - Perl extension for native access to the LabJack U12

=head1 SYNOPSIS

  use LJperl;

  $idnum=-1;  $demo=0;  $stateIO=0;        $updateIO=0;   $ledOn=1;
  @channels=(0,1,2,3);  @gains=(0,0,0,0);  $disableCal=0;

  $ledOn=$1 if($ARGV[0]=~/(\d+)/);

  my(@results)=LJperl::AISample($idnum,$demo,$stateIO,$updateIO,$ledOn,\@channels,\@gains,$disableCal);
  print join("\n",@results);

=head1 DESCRIPTION

This can read and write digital and analog data to and from the device.

=head1 INSTALLATION

   install labjack USB drivers
   perl Makefile.PL
   make
   make test
   make install

=head1 DEPENDENCIES

This module requires these other modules and libraries:

  ljackuw.lib 
  ljackuw.h             ... provided on the U12 CD or web site

Copy the above files into this directory before use.

=head2 EXPORT

None by default.


=head1 AUTHOR

Written by Chris Drake, Feb 1, 2003.

Find my current email address from the "contacts" page of 
my web site, at http://www.ReadNotify.com 

=head1 COPYRIGHT AND LICENCE

This is free, providing that if you improve or add to this module, you email 
me the new version. 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<perl>.

=cut
