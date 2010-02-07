package Device::USB::PCSensor::HidTEMPer::NTC::Internal;

use 5.010;
use strict;
use warnings;
use Carp;

use Device::USB::PCSensor::HidTEMPer::Sensor;
our @ISA = 'Device::USB::PCSensor::HidTEMPer::Sensor';

=head1

Device::USB::PCSensor::HidTEMPer::NTC::Internal - The HidTEMPerNTC internal sensor

=head1 VERSION

Version 0.01

=cut

our $VERSION = 0.01;

=head1 SYNOPSIS

None

=head1 DESCRIPTION

This is the implementation of the HidTEMPerNTC internal sensor.

=head2 CONSTANTS

=over 3

=item * MAX_TEMPERATURE

The highest temperature this sensor can detect.

=cut

use constant MAX_TEMPERATURE    => 120;

=item * MIN_TEMPERATURE

The lowest temperature this sensor can detect.

=back

=cut

use constant MIN_TEMPERATURE    => -40;

=head2 METHODS

=over 3

=item * celsius

Read the current temperature from the device.

Output
  Returns the corrent degree in celsius

=cut

sub celsius
{
    my $self    = shift;
    my @data    = ();
    my $reading = 0;
    
    # Command 0x54 will return the following 8 byte result, repeated 4 times.
    # Position 0: Signed int returning the main temperature reading
    # Position 1: Unsigned int divided by 256 to give presision.
    # Position 2: unknown
    # Position 3: unused
    # Position 4: unused
    # Position 5: unused
    # Position 6: unused
    # Position 7: unused
    
    # First reading
    @data       = $self->{unit}->read( 0x54 );
    $reading    = $data[0] + ( $data[1] / 256 );
    
    # Secound reading
    @data       = $self->{unit}->read( 0x54 );
    $reading    += $data[0] + ( $data[1] / 256 );    

    # Return the average, this adds precision
    return $reading / 2;
}

=back

=head1 INHERITED METHODS

This module inherits methods from:
  Device::USB::PCSensor::HidTEMPer::Sensor

=head1 DEPENDENCIES

  use 5.010;
  use strict;
  use warnings;
  use Carp;
  use Device::USB::PCSensor::HidTEMPer::Sensor;

This module uses the strict and warning pragmas. 

=head1 BUGS

If you find any bugs or missing features please notify me using the following 
email address: msulland@cpan.org

=head1 FOR MORE INFORMATION

None

=head1 AUTHOR

Magnus Sulland < msulland@cpan.org >
 
=head1 ACKNOWLEDGEMENTS

This code is inspired by Relavak's source code and the comments found at:
http://relavak.wordpress.com/2009/10/17/temper-temperature-sensor-linux-driver/

=head1 COPYRIGHT & LICENSE

Copyright (c) 2010 Magnus Sulland

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
