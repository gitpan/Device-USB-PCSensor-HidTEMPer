package Device::USB::PCSensor::HidTEMPer::Device;

use 5.010;
use strict;
use warnings;
use Carp;

=head1

Device::USB::PCSensor::HidTEMPer::Device - Generic device class

=head1 VERSION

Version 0.01

=cut

our $VERSION = 0.01;

=head1 SYNOPSIS

None 

=head1 DESCRIPTION

This module contains a generic class that all HidTEMPer devices should inherit
from keeping the implemented methods consistent, and making it possible to 
use the same code to contact every supported device.

=head2 CONSTANTS

=over 3

=item * CONNECTION_TIMEOUT

USB communication timeout, specified in milliseconds.

=back
=cut

use constant CONNECTION_TIMEOUT => 60;

=head2 METHODS

=over 3

=item * new( $usb_device )

Creates a new generic Device object.

Output
  Returns a generic initialized object.

=cut

sub new
{
    my $class   = shift;
    my ( $usb ) = @_;
    
    # Make sure that this is always a reference to the device.
    $usb = ref $usb 
            ? $usb 
            : \$usb;
    
    my $self    = {
        device  => $usb, # Device::USB::Device interface that should be used
    };
    
    # Possible sensors
    $self->{sensor} = {
        internal    => undef,
        external    => undef, 
    };
    
    # If the two interfaces are currently in use, detach them and thereby
    # make them available for use.
    $usb->detach_kernel_driver_np(0) if $usb->get_driver_np(0);
    $usb->detach_kernel_driver_np(1) if $usb->get_driver_np(1);
    
    # Opens the device for use by this object.
    croak 'Error opening device' unless $usb->open();
    
    # It is only needed to set the configuration used under a Windows system.
    $usb->set_configuration(1) if $^O eq 'MSWin32';
    
    # Claim the two interfaces for use by this object.
    croak 'Could not claim interface' if $usb->claim_interface(0);
    croak 'Could not claim interface' if $usb->claim_interface(1);
    
    bless $self, $class;
    return $self;    
}

sub DESTROY
{
    my $self    = shift;
    
    # Delete sensors
    delete $self->{sensor}->{internal};
    delete $self->{sensor}->{external};
    
    # Release the two interfaces back to the operating system.
    $self->{device}->release_interface(0);
    $self->{device}->release_interface(1);

    delete $self->{device};
    
    return undef;
}

=item * type()

This method is used to acquire the hex value representing the device type.

Output
  Returns the hex value specifying the model type.

=cut

sub type
{
    my $self    = shift;
    
    # Command 0x52 will return the following 8 byte result, repeated 4 times.
    # Position 0: unknown
    # Position 1: Device ID
    # Position 2: Calibration value one for the internal sensor
    # Position 3: Calibration value two for the internal sensor
    # Position 4: Calibration value one for the external sensor
    # Position 5: Calibration value two for the external sensor
    # Position 6: unknown
    # Position 7: unknown
    
    my ( undef, $type ) = $self->read( 0x52 );
    return $type;
}

=item * read( @command_bytes )

Used to read information from the device. 

Input parameters
  Array of 8 bit hex values, maximum of 32 bytes, representing 
  the commands that will be executed by the device.

Output
  An array of 8 bit hex values or a text string using chars 
  (from 0 to 255) to represent the hex values.
  
Error
  Returns undef on error, and carp to display a description.

=cut

sub read
{
    my $self                = shift;
    my ( @bytes )           = @_;
    my ( $data, $checksum ) = ( 0, 0 );
    
    $checksum       += $self->command(32, 0xA, 0xB, 0xC, 0xD, 0x0, 0x0, 0x2 );
    $checksum       += $self->command(32, @bytes );
    $checksum       += $self->command(32, 0x0 );
    $checksum       += $self->command(32, 0x0 );
    $checksum       += $self->command(32, 0x0 );
    $checksum       += $self->command(32, 0x0 );
    $checksum       += $self->command(32, 0x0 );
    $checksum       += $self->command(32, 0x0 );
    $checksum       += $self->command(32, 0x0 );
    $checksum       += $self->command(32, 0xA, 0xB, 0xC, 0xD, 0x0, 0x0, 0x1 );
    
    # On error a wrong amount of bytes is returened.
    carp 'The device returned to few bytes'     if $checksum < 320;
    carp 'The device returned to many bytes'    if $checksum > 320;
    return undef if $checksum != 320;
    
    # Send a message to the device, capturing the output into into $data
    $checksum   = $self->{device}->control_msg(
        0xA1,               # Request type
        0x1,                # Request
        0x300,              # Value
        0x1,                # Index
        $data,              # Bytes to be transfeered
        32,                 # Number of bytes to be transferred, more than 32 eq seg fault
        CONNECTION_TIMEOUT  # Timeout
    );
    
    # Ensure that 32 bytes are read from the device.
    carp 'Error reading information from device' if $checksum != 32;
    
    return wantarray ? unpack "C*", $data : $data;
}

=item * command( $total_byte_size, @data )

This method is used to send a command to the device, only used for commands 
where the output is not needed to be captured.

Input parameters
  1) The total size that should be sent. Zero padding will be added 
  at the end to achieve specified length.
  2..x) An array of 8bit hex values representing the data that 
  should be sent.

Output
  Returns the number of bytes that where sent to the device if 
  successful execution. This is the same amout of bytes that where 
  specified as input.

Error
  Returns undef on error, and carp to display a description.

=cut

sub command
{
    my $self                = shift;
    my ( $size, @bytes )    = @_;

    # Convert to char and add zero padding at the end
    my $data    = join '', map{ chr $_ } @bytes;
    $data      .= join '', map{ chr $_ } ( (0)x( $size - $#bytes ) );

    # Send the message to the device
    my $return  = $self->{device}->control_msg(
        0x21,               # Request type
        0x9,                # Request
        0x200,              # Value
        0x1,                # Index
        $data,              # Bytes to be transferred
        $size,              # Number of bytes to be transferred
        CONNECTION_TIMEOUT  # Timeout
    );
    
    # If the device returns correct amount of bytes return count, all OK.
    return $return if $return == $size;
    
    carp 'The device return less bytes than anticipated'    if $return < $size;
    carp 'The device returned more bytes than anticipated'  if $return > $size;
    return undef;
}

=item * write( @bytes )

This method is used to write information back to the device. Be carefull when
using this, since any wrong information sent may destroy the device.

Output
  Returns the number of bytes that where sent to the device if 
  successful execution. This should be 288 if everything is 
  successful.

Error
  Returns undef on error, and carp to display a description.

=cut

sub write
{
    my $self                = shift;
    my ( @bytes )           = @_;
    my ( $data, $checksum ) = ( 0, 0 );
    
    # Filter out possible actions
    return undef if $bytes[0] > 0x68 || $bytes[0] < 0x61;
    
    $checksum       += $self->command(32, 0xA, 0xB, 0xC, 0xD, 0x0, 0x0, 0x2 );
    $checksum       += $self->command(32, @bytes );
    $checksum       += $self->command(32, 0x0 );
    $checksum       += $self->command(32, 0x0 );
    $checksum       += $self->command(32, 0x0 );
    $checksum       += $self->command(32, 0x0 );
    $checksum       += $self->command(32, 0x0 );
    $checksum       += $self->command(32, 0x0 );
    $checksum       += $self->command(32, 0x0 );
    
    # On error a wrong amount of bytes is returened.
    carp 'The device returned to few bytes'     if $checksum < 288;
    carp 'The device returned to many bytes'    if $checksum > 288;
    return undef if $checksum != 288;
    
    return $checksum;
}

=item * internal

Used to get the reference to the internal temperature sensor attached to this
device

Output
  Reference to the internal temperature sensor. Undef if no sensor is present.

=cut

sub internal
{
    return $_[0]->{sensor}->{internal};
}

=item * external

Used to get the reference to the external temperature sensor attached to this
device

Output
  Reference to the external temperature sensor. Undef if no sensor is present.

=cut

sub external
{
    return $_[0]->{sensor}->{external};
}

=item * transform

Empty method that should be implemented in order to be able to transfor 
a object from the generic device into a spesific device.

=cut

sub transform   { return undef; }

=back

=head1 DEPENDENCIES

  use 5.010;
  use strict;
  use warnings;
  use Carp;

This module depends on the Device::USB and Device::USB::Device modules in 
order to communicate using the libusb project. Errors are reported using 
the Carp module.

This module uses the strict and warning pragmas. 

=head1 BUGS

If you find any bugs or missing features please notify me using the following 
email address: msulland@cpan.org

In this release the object does not update the device by writing information 
back to it. If or when this feature will be included, and the necessity of it, 
is still unknown.

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
