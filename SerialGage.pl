#!/usr/bin/env perl

# Turn on some global code settings
use strict;
use warnings;

# import libraries
use Device::SerialPort;
use Tk;
use Tk::Gauge;

my $result = "";
# what happens w/ zero or empty string?
$result = '1';

sub open_serial_port {
  my $port = Device::SerialPort->new("/dev/ttyACM0");
  $port->databits(8);
  $port->baudrate(9600);
  $port->parity("none");
  $port->stopbits(1);
  return $port;
}

# Change this line to switch between testing and real
my $port = open_serial_port; # real
#my $port = FakeSerialPort->new; # test

# There was this sleep after the serial port setup?
# sleep(2);

sub get_value {
  $result = $port->lookfor;    # poll until data rcvd
  # I took the sleep out here, see comment by `repeat` below
  return $result;
}

my $mw = MainWindow->new;
$mw->configure(-bg=>'white');

my $iLCD = 100; # integral Lowest Common Denominator? (from example code)
my $xgrid = 0;
my $cpu = $mw->Gauge(
  -background           => 'black',
  -caption              => "Exhaust Gas Temperature",
  -captioncolor         => 'white',
  -fill                 => 'black',
  -from                 => 0,
  -hubcolor             => 'black',
  -hubradius            => 15,
  -majortickinterval    => 1000 / $iLCD,
  -majorticklength      => 10,
  -majortickcolor       => 'red',
  -majorticklabelcolor  => 'red',
  -majorticklabelscale  => $iLCD / 1000,
  -minortickinterval    => 500 / $iLCD,
  -minorticklength      => 10,
  -minortickcolor       => 'white',
  -finetickinterval     => 100 / $iLCD,
  -fineticklength       => 5,
  -finetickcolor        => 'white',
  -margin               => 65,
  -needles              => [
    {
      -arrowshape => [ 11, 11, 1 ],
      -color      => 'red',
      -format     => '%d',
      -radius     => 64,
      -showvalue  => 0,
      -title      => 'EGT',
      -titlecolor => 'white',
      -variable   => \$xgrid,
      -width      => 4,
    },
  ]
  ,
  -needlepad            => 42,
  -outline              => 'lightgray',
  -outlinewidth         => 1,
  -to                   => 10000 / $iLCD,
)->pack;

# `get_value` is defined above
# the first value is how long to sleep (in milliseconds?)
# increase to save cpu
$mw->repeat(700 => sub { $xgrid = get_value } );

MainLoop;
