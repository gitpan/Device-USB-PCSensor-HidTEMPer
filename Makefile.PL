use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Device::USB::PCSensor::HidTEMPer',
    VERSION_FROM      => 'lib/Device/USB/PCSensor/HidTEMPer.pm',
    PREREQ_PM         => {},
    AUTHOR            => 'Magnus Sulland<msulland@cpan.org>'
);