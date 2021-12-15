package eLab::Client;
# ABSTRACT: Access the eLabFTW API with Perl

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::Params::Validate;

extends 'REST::Client';

has token => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has endpoint => (
  is => 'ro',
  isa => 'Str',
  default => 'api/v1/'
);

sub BUILD {
  my $self = shift;
  my $args = shift;

  $self->addHeader('Authorization', $self->token());
}

sub elab_get {
  my $self = shift;
  my $url = shift;

  return $self->GET($self->endpoint().$url);
}

sub elab_post {
  my $self = shift;
  my $url = shift;

  return $self->POST($self->endpoint().$url);
}


# from here on we try to follow elabapy

sub create_experiment {
  my $self = shift;

  return $self->elab_post("experiments");
}

sub create_item {
  my $self = shift;
  my $type = shift;

  return $self->elab_post("items/".$type);
}

sub create_template {
  my $self = shift;

  return $self->elab_post("templates");
}



sub get_experiment {
  my $self = shift;
  my $id = shift;

  return $self->elab_get("experiments/".$id);
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
