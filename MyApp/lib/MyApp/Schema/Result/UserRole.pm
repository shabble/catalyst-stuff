package MyApp::Schema::Result::UserRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn");

=head1 NAME

MyApp::Schema::Result::UserRole

=cut

__PACKAGE__->table("user_role");

=head1 ACCESSORS

=head2 user_id

  data_type: INTEGER
  default_value: undef
  is_foreign_key: 1
  is_nullable: 1
  size: undef

=head2 role_id

  data_type: INTEGER
  default_value: undef
  is_foreign_key: 1
  is_nullable: 1
  size: undef

=cut

__PACKAGE__->add_columns(
  "user_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_foreign_key => 1,
    is_nullable => 1,
    size => undef,
  },
  "role_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_foreign_key => 1,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("user_id", "role_id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<MyApp::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "MyApp::Schema::Result::User",
  { id => "user_id" },
  { join_type => "LEFT" },
);

=head2 role

Type: belongs_to

Related object: L<MyApp::Schema::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "role",
  "MyApp::Schema::Result::Role",
  { id => "role_id" },
  { join_type => "LEFT" },
);


# Created by DBIx::Class::Schema::Loader v0.05002 @ 2010-02-17 16:27:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bRXps6LBVc4JT2SWbhY0cA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
