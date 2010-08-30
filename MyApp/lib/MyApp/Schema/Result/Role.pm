package MyApp::Schema::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn");

=head1 NAME

MyApp::Schema::Result::Role

=cut

__PACKAGE__->table("role");

=head1 ACCESSORS

=head2 id

  data_type: INTEGER
  default_value: undef
  is_nullable: 1
  size: undef

=head2 role

  data_type: TEXT
  default_value: undef
  is_nullable: 1
  size: undef

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "role",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user_roles

Type: has_many

Related object: L<MyApp::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "MyApp::Schema::Result::UserRole",
  { "foreign.role_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.05002 @ 2010-02-17 16:27:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:I2Sm+YHDp9fI2mcsZ2dj8g


# You can replace this text with custom content, and it will be preserved on regeneration
1;
