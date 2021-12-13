package eLab::Client;
# ABSTRACT: Access the eLabFTW API with Perl

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;

extends 'REST-Client';







no Moose;
__PACKAGE__->meta->make_immutable;

1;
