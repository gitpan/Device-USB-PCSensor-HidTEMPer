package Device::USB::PCSensor::HidTEMPer::Sensor;

use 5.010;
use strict;
use warnings;
use Carp;
use Scalar::Util qw/ weaken /;

=head1

Device::USB::PCSensor::HidTEMPer::Sensor - Generic sensor class

=head1 VERSION

Version 0.01

=cut

our $VERSION = 0.01;

=head1 SYNOPSIS

None

=head1 DESCRIPTION

This module contains a generic class that all HidTEMPer sensors should inherit
from keeping the implemented methods consistent, and making it possible to 
use the same code to contact every supported device.

=head2 CONSTANTS

=over 3

=item * MAX_TEMPERATURE

The highest temperature this sensor can detect.

=cut

use constant MAX_TEMPERATURE    => 0;

=item * MIN_TEMPERATURE

The lowest temperature this sensor can detect.

=back

=cut

use constant MIN_TEMPERATURE    => 0;

=head2 METHODS

=over 3

=item * new( $device )

Generic initializing method, creating a sensor object.

Input parameter
  Ref to the device that contains the sensor.

=cut

sub new
{
    my $class       = shift;
    my ( $unit )    = @_;
    
    # All devices are required to spesify the temperature range
    my $self    = {
        unit    => $unit,
    };
    
    weaken $self->{unit};
    
    bless $self, $class;
    return $self;
}

=item * fahrenheit()

Reads the current temperature and returns the corresponding value in 
fahrenheit degrees.

Output
  A number representing the current temperature in fahrenheit.

=cut

sub fahrenheit
{
    my $self    = shift;
    my $celsius = $self->celsius() // 0;
    
    # Calculate and return the newly created degrees
    return ( ( $celsius * 9 ) / 5 ) + 32;
}

=item * max()

Returns the highest part of the sensors temperature range ( the most positive
number )

Output
  A number representing the highest possible temperature the sensor 
  can detect.

=cut

sub max
{ 
    return $_[0]->MAX_TEMPERATURE;
}

=item * min()

Returns the lowest part of the sensors temperature range ( the most negative 
number ).

Output
  A number representing the lowest possible temperature the sensors 
  can detect. 

=cut

sub min
{
    return $_[0]->MIN_TEMPERATURE;
}

=item * celsius()

Empty method that should be implemented in each sensor, returing the 
current degrees in celsius. Returns undef.

=cut

sub celsius { 
    return undef; 
}

=back

=head1 DEPENDENCIES

  use 5.010;
  use strict;
  use warnings;
  use Carp;

This module uses the strict and warning pragmas. 

=head1 BUGS

If you find any bugs or missing features please notify me using the following 
email address: msulland@cpan.org

In this version the calibration values present in the device is not used, 
and the values returned are thereby not calibrated like the official software 
does. This feature is scheduled to be included in the next release of this code
if it is found to make the device more accurate.

=head1 FOR MORE INFORMATION

None

=head1 AUTHOR

Magnus Sulland < msulland@cpan.org >

=head1 ACKNOWLEDGEMENTS

None

=head1 COPYRIGHT & LICENSE

Copyright (c) 2010 Magnus Sulland

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
