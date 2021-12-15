package ELab::Client;
# ABSTRACT: Access the eLabFTW API with Perl

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::Params::Validate;
use JSON;

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

=head1 METHODS

=cut

sub BUILD {
  my $self = shift;
  my $args = shift;

  $self->addHeader('Authorization', $self->token());
}

sub elab_get {
  my $self = shift;
  my $url = shift;
  my $result = $self->GET($self->endpoint().$url);
  return undef unless $result->responseCode() eq '200';
  return $result->responseContent();
}

sub elab_post {
  my $self = shift;
  my $url = shift;
  my $result = $self->POST($self->endpoint().$url);
  return undef unless $result->responseCode() eq '200';
  return $result->responseContent();
}


# from here on we try to follow elabapy

=head2 create_experiment

Creates a new experiment:

  my $e = $elab->create_experiment();

The return value is a hash reference with fields

  result      string       'success' or error message
  id          string       id of the new experiment

=cut

sub create_experiment {
  my $self = shift;
  return decode_json $self->elab_post("experiments");
}


=head2 create_item

Creates a new database item of type $type: 

  my $e = $elab->create_item($type);

The return value is a hash reference with fields

  result      string       'success' or error message
  id          string       id of the new item

=cut

sub create_item {
  my $self = shift;
  my $type = shift;
  return decode_json $self->elab_post("items/$type");
}


=head2 create_template

Creates a new template:

  my $t = $elab->create_template();

The return value is a hash reference with fields

  result      string       'success' or error message
  id          string       id of the new template

=cut

sub create_template {
  my $self = shift;
  return decode_json $self->elab_post("templates");
}


=head2 get_all_experiments

Lists experiments, with maximum number limit and starting at offset.

  my $a = $elab->get_all_experiments(limit => 15, offset => 0);

The return value is a hash reference.

=cut

sub get_all_experiments {
  my $self = shift;
  my (%args) = validated_hash(
    \@_,
    limit  => { isa => 'Int', default => 25 },
    offset => { isa => 'Int', default => 0 },
  );
  return decode_json $self->elab_get("experiments/?".$self->buildQuery(%args));
}


=head2 get_experiment

  my $e = $elab->get_experiment($id);

=cut

sub get_experiment {
  my $self = shift;
  my $id = shift;

  return decode_json $self->elab_get("experiments/$id");
}


# missing: get_all_items


=head2 get_item

  my $i = $elab->get_item($id);

=cut

sub get_item {
  my $self = shift;
  my $id = shift;

  return $self->elab_get("items/$id");
}


=head2 get_items_types

  my $t = $elab->get_items_types();

=cut

sub get_items_types {
  my $self = shift;

  return $self->elab_get("items_types/");
}


=head2 get_tags

  my $t = $elab->get_tags();

=cut

sub get_tags {
  my $self = shift;

  return $self->elab_get("tags/");
}


# missing: get_upload


=head2 get_status

  my $s = $elab->get_status();

=cut

sub get_status {
  my $self = shift;

  return $self->elab_get("status/");
}


=head2 get_all_templates

  my $t = $elab->get_all_templates();

=cut

sub get_all_templates {
  my $self = shift;

  return $self->elab_get("templates/");
}


=head2 get_template

  my $t = $elab->get_template($id);

=cut

sub get_template {
  my $self = shift;
  my $id = shift;

  return $self->elab_get("templates/$id");
}


# missing: post_experiment


# missing: post_item


# missing: post_template


# missing: add_link_to_experiment


# missing: add_link_to_item


# missing: upload_to_experiment


# missing: upload_to_item


# missing: upload_to_item


# missing: add_tag_to_experiment


# missing: add_tag_to_item


# missing: get_backup_zip


# missing: get_bookable


# missing: create_event


# missing: get_event


# missing: get_all_events


# missing: destroy_event


no Moose;
__PACKAGE__->meta->make_immutable;

1;
