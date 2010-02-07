package Device::USB::PCSensor::HidTEMPer::TEMPer;

use 5.010;
use strict;
use warnings;
use Carp;

use Device::USB::PCSensor::HidTEMPer::Device;
use Device::USB::PCSensor::HidTEMPer::TEMPer::Internal;
our @ISA = 'Device::USB::PCSensor::HidTEMPer::Device';

=head1

Device::USB::PCSensor::HidTEMPer::TEMPer - The HidTEMPer device

=head1 VERSION

Version 0.01

=cut

our $VERSION = 0.01;

=head1 SYNOPSIS

None

=head1 DESCRIPTION

This is the implementation of the HidTEMPer devices that have only one internal
sensor measuring the temperature.

=head2 CONSTANTS

None

=head2 METHODS

=over 3

=item * transform()

Transforms a generic device instance into a HidTEMPer instance.

Output
  Ref to the object that have been transformed.

=cut

sub transform
{
    my ( $class, $self )    = @_;
    
    # Add sensor references to this instance
    $self->{sensor}->{internal} = Device::USB::PCSensor::HidTEMPer::TEMPer::Internal->new( $self );    
    
    # Rebless and return a new version
    bless $self, $class;
    
    return $self;
}

sub DESTROY
{
    $_[0]->SUPER::DESTROY();
}

=back

=head1 INHERITED METHODS

This module inherits methods from:
  Device::USB::PCSensor::HidTEMPer::Device

=head1 DEPENDENCIES

  use 5.010; 
  use strict;
  use warnings;
  use Carp;
  use Device::USB::PCSensor::HidTEMPer::Device;
  use Device::USB::PCSensor::HidTEMPer::TEMPer::Internal;

This module uses the strict and warning pragmas. 

=head1 BUGS

If you find any bugs or missing features please notify me using the following 
email address: msulland@cpan.org

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
