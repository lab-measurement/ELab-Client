package ELab::Client;
# ABSTRACT: Access the eLabFTW API with Perl

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::Params::Validate;
use JSON;
use HTTP::Request::Common qw '';

extends 'REST::Client';

has host => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

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

=head1 SYNOPSYS

  use ELab::Client;

  my $elab = ELab::Client->new(
                    host => 'https://elab.somewhere.de/',
                    token => 'ae...d4',
              );

  my $e = $elab->post_experiment(4,
                    title => "Replacement experiment title",
                    body => "Replacement body text"
              );

=head1 METHODS

=head2 API interface

This interface is intended to be compatible to the elabapy Python client.


=head3 get_backup_zip($datespan)

  use File::Slurp;
  write_file('backup.zip', get_backup_zip('20200101-20210101'));

Generates a zip file with all experiments changed in a given time period.
The period is specified as FROM-TO in the format YYYYMMDD-YYYYMMDD.

Requires sysadmin permissions.

=cut

sub get_backup_zip {
  my $self = shift;
  my $datespan = shift;
  return $self->elab_get("backupzip/$datespan");
}


=head3 get_items_types()

  my $t = $elab->get_items_types();

Returns a list of database item types with their type id's.
The return value is an array reference, with the array items being hash
references for each item type.

=cut

sub get_items_types {
  my $self = shift;
  return decode_json $self->elab_get("items_types/");
}

=head3 get_item_types()

Alias for get_items_types()

=cut

sub get_item_types {
  return get_items_types(@_);
}


=head3 get_status()

  my $s = $elab->get_status();

Returns a list of possible experiment states.
The return value is an array reference, with the array items being hash
references for each status type.

=cut

sub get_status {
  my $self = shift;
  return decode_json $self->elab_get("status/");
}

=head3 get_experiment_states()

Alias for get_status()

=cut

sub get_experiment_states {
  return get_status(@_);
}


=head3 add_link_to_experiment($id, ...)

  my $result = add_link_to_experiment(2, link => 5)

Adds to an experiment a link to a database item with given id.
Returns a hash reference with status information.

=cut

sub add_link_to_experiment {
  my $self = shift;
  my $id = shift;
  my (%args) = validated_hash(
    \@_,
    link  => { isa => 'Str' },
  );
  return decode_json $self->elab_post("experiments/$id", $self->buildQuery(%args));
}


=head3 add_link_to_item($id, ...)

  my $result = add_link_to_item(2, link => 5)

Adds to a database item a link to another database item with given id.
Returns a hash reference with status information.

=cut

sub add_link_to_item {
  my $self = shift;
  my $id = shift;
  my (%args) = validated_hash(
    \@_,
    link  => { isa => 'Str' },
  );
  return decode_json $self->elab_post("items/$id", $self->buildQuery(%args));
}



#########
# sorted until here
#########



=head3 create_experiment()

  my $e = $elab->create_experiment();

Creates a new experiment. The return value is a hash reference with fields

  result      string       'success' or error message
  id          string       id of the new experiment

=cut

sub create_experiment {
  my $self = shift;
  return decode_json $self->elab_post("experiments");
}


=head3 create_item($type)

  my $e = $elab->create_item($type);

Creates a new database item of type $type. The return value is a hash 
reference with fields

  result      string       'success' or error message
  id          string       id of the new item

=cut

sub create_item {
  my $self = shift;
  my $type = shift;
  return decode_json $self->elab_post("items/$type");
}


=head3 create_template

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


=head3 get_all_experiments

Lists experiments, with maximum number limit and starting at offset.

  my $a = $elab->get_all_experiments(limit => 15, offset => 0);

The return value is an array reference, where each element is a hash reference
describing an experiment (not fully, but abbreviated).

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


=head3 get_experiment

Returns an experiment.

  my $e = $elab->get_experiment($id);

The return value is a hash reference with the full experiment information.

=cut

sub get_experiment {
  my $self = shift;
  my $id = shift;
  return decode_json $self->elab_get("experiments/$id");
}


=head3 get_all_items

Lists database items, with maximum number limit and starting at offset.

  my $a = $elab->get_all_items(limit => 25, offset => 0);

The return value is an array reference, where each element is a hash reference
corresponding to a database item.

=cut

sub get_all_items {
  my $self = shift;
  my (%args) = validated_hash(
    \@_,
    limit  => { isa => 'Int', default => 25 },
    offset => { isa => 'Int', default => 0 },
  );
  return decode_json $self->elab_get("items/".$self->buildQuery(%args));
}



=head3 get_item

Returns a database item.

  my $i = $elab->get_item($id);

=cut

sub get_item {
  my $self = shift;
  my $id = shift;
  return decode_json $self->elab_get("items/$id");
}


=head3 get_tags

Returns the tags of the team.

  my $t = $elab->get_tags();

=cut

sub get_tags {
  my $self = shift;
  return decode_json $self->elab_get("tags/");
}


=head3 get_upload

Get an uploaded file from its id

  my $data = $elab->get_upload($id);

The result is the raw binary data of the uploaded file.

=cut

sub get_upload {
  my $self = shift;
  my $id = shift;
  return $self->elab_get("uploads/$id");
}



=head3 get_all_templates

  my $t = $elab->get_all_templates();

=cut

sub get_all_templates {
  my $self = shift;
  return decode_json $self->elab_get("templates/");
}


=head3 get_template

  my $t = $elab->get_template($id);

=cut

sub get_template {
  my $self = shift;
  my $id = shift;
  return decode_json $self->elab_get("templates/$id");
}


=head3 post_experiment

  my $e = $elab->post_experiment(13,
                    title => "Updated experiment title",
                    body => "Updated experiment body text"
        );

=cut

sub post_experiment {
  my $self = shift;
  my $id = shift;
  my (%args) = validated_hash(
    \@_,
    title  => { isa => 'Str', optional => 1 },
    date => { isa => 'Str', optional => 1 },
    body => { isa => 'Str', optional => 1 },
    bodyappend => { isa => 'Str', optional => 1 },
  );
  return decode_json $self->elab_post("experiments/$id", $self->buildQuery(%args));
}


=head3 post_item

  my $i = $elab->post_item(4,
                    title => "Database item",
                    body => "here are the bodies"
        );

=cut

sub post_item {
  my $self = shift;
  my $id = shift;
  my (%args) = validated_hash(
    \@_,
    title  => { isa => 'Str', optional => 1 },
    date => { isa => 'Str', optional => 1 },
    body => { isa => 'Str', optional => 1 },
    bodyappend => { isa => 'Str', optional => 1 },
  );
  return decode_json $self->elab_post("items/$id", $self->buildQuery(%args));
}


=head3 post_template

=cut

sub post_template {
  my $self = shift;
  my $id = shift;
  my (%args) = validated_hash(
    \@_,
    title  => { isa => 'Str', optional => 1 },
    date => { isa => 'Str', optional => 1 },
    body => { isa => 'Str', optional => 1 },
  );
  return decode_json $self->elab_post("templates/$id", $self->buildQuery(%args));
}



=head3 upload_to_experiment

  my $e = $elab->upload_to_experiment(13, file => "mauterndorf.jpg");

=cut

sub upload_to_experiment {
  my $self = shift;
  my $id = shift;
  my (%args) = validated_hash(
    \@_,
    file  => { isa => 'Str' },
  );
  my $request = HTTP::Request::Common::POST(
        $self->host().$self->endpoint()."experiments/$id", 
        {
          file => [ $args{file} ]
        },
        Content_Type => 'form-data', 
        Authorization => $self->token(),
      );
  return decode_json $self->getUseragent()->request($request)->decoded_content(); 
}


=head3 upload_to_item

  my $e = $elab->upload_to_item(13, file => "mauterndorf.jpg");

=cut

sub upload_to_item {
  my $self = shift;
  my $id = shift;
  my (%args) = validated_hash(
    \@_,
    file  => { isa => 'Str' },
  );
  my $request = HTTP::Request::Common::POST(
        $self->host().$self->endpoint()."items/$id", 
        {
          file => [ $args{file} ]
        },
        Content_Type => 'form-data', 
        Authorization => $self->token(),
      );
  return decode_json $self->getUseragent()->request($request)->decoded_content(); 
}


=head3 add_tag_to_experiment

=cut

sub add_tag_to_experiment {
  my $self = shift;
  my $id = shift;
  my (%args) = validated_hash(
    \@_,
    tag  => { isa => 'Str' },
  );
  return decode_json $self->elab_post("experiments/$id", $self->buildQuery(%args));
}


=head3 add_tag_to_item

=cut

sub add_tag_to_item {
  my $self = shift;
  my $id = shift;
  my (%args) = validated_hash(
    \@_,
    tag  => { isa => 'Str' },
  );
  return decode_json $self->elab_post("items/$id", $self->buildQuery(%args));
}


=head3 get_bookable

=cut

sub get_bookable {
  my $self = shift;
  return decode_json $self->elab_get("bookable/");
}


=head3 create_event

=cut

sub create_event {
  my $self = shift;
  my $id = shift;
  my (%args) = validated_hash(
    \@_,
    start  => { isa => 'Str' },
    end  => { isa => 'Str' },
    title  => { isa => 'Str' },
  );
  return decode_json $self->elab_post("events/$id", $self->buildQuery(%args));
}


=head3 get_event

=cut

sub get_event {
  my $self = shift;
  my $id = shift;
  return decode_json $self->elab_get("events/$id");
}


=head3 get_all_events

=cut

sub get_all_events {
  my $self = shift;
  return decode_json $self->elab_get("events/");
}


=head3 destroy_event

=cut

sub destroy_event {
  my $self = shift;
  my $id = shift;
  return decode_json $self->elab_delete("events/$id");
}


=head2 Low-level methods

=cut

sub BUILD {
  my $self = shift;
  my $args = shift;

  $self->addHeader('Authorization', $self->token());
}

=head3 elab_get($url)

  my $hashref = decode_json $self->elab_get("events/$id");

Sends a GET requrest to the server, and returns the response as JSON.
  
=cut

sub elab_get {
  my $self = shift;
  my $url = shift;
  my $result = $self->GET($self->endpoint().$url);
  return undef unless $result->responseCode() eq '200';
  return $result->responseContent();
}

=head3 elab_delete($url)

  my $hashref = decode_json $self->elab_delete("events/$id");

Sends a DELETE requrest to the server, and returns the response as JSON.
  
=cut

sub elab_delete {
  my $self = shift;
  my $url = shift;
  my $result = $self->DELETE($self->endpoint().$url);
  return undef unless $result->responseCode() eq '200';
  return $result->responseContent();
}

=head3 elab_post($url, $data)

  my $hashref = decode_json $self->elab_post("events/$id", $self->buildQuery(%args));

Sends a POST requrest to the server, with the posted data supplied as an
urlencoded string (starting with '?' for convenient use of buildQuery).
Returns the obtained data as JSON.
  
=cut

sub elab_post {
  my $self = shift;
  my $url = shift;
  my $data = shift;
  $data =~ s/^\?//;  # buildQuery starts with "?" (makes no sense here)
  my $headers = { 'Content-Type' => 'application/x-www-form-urlencoded' };
  my $result = $self->POST($self->endpoint().$url, $data, $headers);
  return undef unless $result->responseCode() eq '200';
  return $result->responseContent();
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
