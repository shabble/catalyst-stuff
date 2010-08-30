package MyApp::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn");

=head1 NAME

MyApp::Schema::Result::User

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: INTEGER
  default_value: undef
  is_nullable: 1
  size: undef

=head2 username

  data_type: TEXT
  default_value: undef
  is_nullable: 1
  size: undef

=head2 password

  data_type: TEXT
  default_value: undef
  is_nullable: 1
  size: undef

=head2 email_address

  data_type: TEXT
  default_value: undef
  is_nullable: 1
  size: undef

=head2 first_name

  data_type: TEXT
  default_value: undef
  is_nullable: 1
  size: undef

=head2 last_name

  data_type: TEXT
  default_value: undef
  is_nullable: 1
  size: undef

=head2 active

  data_type: INTEGER
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
  "username",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "password",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "email_address",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "first_name",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "last_name",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "active",
  {
    data_type => "INTEGER",
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
  { "foreign.user_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.05002 @ 2010-02-17 16:27:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:174DVpqYH1U4h9EGCBq87Q


# You can replace this text with custom content, and it will be preserved on regeneration

# many_to_many():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of has_many() relationship this many_to_many() is shortcut for
#     3) Name of belongs_to() relationship in model class of has_many() above
#   You must already have the has_many() defined to use a many_to_many().
__PACKAGE__->many_to_many(roles => 'user_roles', 'role');


# Have the 'password' column use a SHA-1 hash and 10-character salt
# with hex encoding; Generate the 'check_password" method
__PACKAGE__->add_columns(
    'password' => {
        data_type           => "TEXT",
        size                => undef,
        encode_column       => 1,
        encode_class        => 'Digest',
        encode_args         => {salt_length => 10},
        encode_check_method => 'check_password',
    },
);


=head2 has_role

Check if a user has the specified role

=cut

use Perl6::Junction qw/any/;
sub has_role {
    my ($self, $role) = @_;

    # Does this user posses the required role?
    return any(map { $_->role } $self->roles) eq $role;
}


1;
