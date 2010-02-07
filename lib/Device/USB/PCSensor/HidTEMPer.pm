package Device::USB::PCSensor::HidTEMPer;

use 5.010;
use strict;
use warnings;
use Carp;

use Device::USB;
use Device::USB::PCSensor::HidTEMPer::Device;
use Device::USB::PCSensor::HidTEMPer::NTC;
use Device::USB::PCSensor::HidTEMPer::TEMPer;

=head1 NAME

Device::USB::PCSensor::HidTEMPer - Device overview

=head1 VERSION

Version 0.01

=cut

our $VERSION = 0.01;

=head1 SYNOPSIS

  use Device::USB::PCSensor::HidTEMPer;

  my $pcsensor  = Device::USB::PCSensor::HidTEMPer->new();
  my @devices   = $pcsensor->list_devices();
  
  foreach my $device ( @devices ){
    say $device->internal()->celsius();
  }

=head1 DESCRIPTION

Simplified interface to the usb devices hiding Device::USB from the user. 
Using this class to list devices ensures that only the correct 
temperature devices are returned, all initialized and ready for use.

=head2 CONSTANTS

The following constants are declared in this class

=over 3

=item * PRODUCT_ID

Contains the hex value of the product id on the usb chip.

=cut

use constant PRODUCT_ID	=> 0x660c; 

=item * VENDOR_ID

Contains the hex value representing the manufacturer of the chip, in this
case this is "Tenx Technology, Inc."

=cut

use constant VENDOR_ID	=> 0x1130;

=back

=head2 METHODS

=over 4

=item * new()

=cut

sub new
{
    my $class   = shift;
    
    my $self    = {
        usb     => undef,
        devices => undef, 
    };
    
    $self->{usb}        = Device::USB->new();
    $self->{devices}    = ();
    
    bless $self, $class;
    return $self;
}

=item * list_devices()

Returns an array of all the recognized devices that are attaced to the system.
Each device is a object of the same type as the device found.

=cut

sub list_devices
{
    my $self    = shift;
	my @devices	= ();
	
	@devices = grep defined( $_ ),
	            map $self->device( $_ ), $self->{usb}->list_devices( VENDOR_ID, 
	                                                                 PRODUCT_ID );

	return wantarray ? @devices : scalar @devices;
}

=item * device( $generic_device )

Convert a generic usb-device into the corresponding HidTEMPer device.

Input parameters
  1) The Device::USB::Device object that should be converted to the 
  appropriate object type.


Output
  This method returns a object of the corresponding type if the 
  device is supported, else it returns undef. Returns undef on 
  errors, and carp to display the error message.

=cut

sub device
{
	my $self    = shift;
	my $usb     = shift;
	my $device  = Device::USB::PCSensor::HidTEMPer::Device->new( $usb );

=pod

List of supported devices:

 Hex value   Product         Internal sensor    External sensor
 0x5b        HidTEMPerNTC    Yes                Yes
 0x58        HidTEMPer       Yes                No

=cut

	# Reblesses the generic device into the correct version.
	given ( $device->type() ){
	    when ( undef )  { carp 'Undefined device type returned' }
	    when ( 0x58 )   { return Device::USB::PCSensor::HidTEMPer::TEMPer->transform( $device )   }
	    when ( 0x5b )   { return Device::USB::PCSensor::HidTEMPer::NTC->transform( $device )      }
	    default         { carp 'Unsupported device' }
	}

	return undef;
}

=back

=head1 DEPENDENCIES

  use 5.010;
  use strict;
  use warnings;
  use Carp;
  use Device::USB;
  use Device::USB::PCSensor::HidTEMPer::Device;
  use Device::USB::PCSensor::HidTEMPer::NTC;
  use Device::USB::PCSensor::HidTEMPer::TEMPer;

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
