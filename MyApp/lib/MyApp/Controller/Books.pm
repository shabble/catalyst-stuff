package MyApp::Controller::Books;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }


=head1 NAME

MyApp::Controller::Books - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched MyApp::Controller::Books in Books.');
}


=head2 list

Fetch all book objects and pass to books/list.tt2 in stash to be displayed

=cut

sub list :Local {
    # Retrieve the usual Perl OO '$self' for this object. $c is the Catalyst
    # 'Context' that's used to 'glue together' the various components
    # that make up the application
    my ($self, $c) = @_;

    # Retrieve all of the book records as book model objects and store
    # in the stash where they can be accessed by the TT template
    $c->stash(books => [$c->model('DB::Book')->all]);

    # Set the TT template to use.  You will almost always want to do this
    # in your action methods (action methods respond to user input in
    # your controllers).
    $c->stash(template => 'books/list.tt2');
}


=head2 base

Can place common logic to start chained dispatch here

=cut

sub base :Chained('/') :PathPart('books') :CaptureArgs(0) {
    my ($self, $c) = @_;

    # Store the ResultSet in stash so it's available for other methods
    $c->stash(resultset => $c->model('DB::Book'));

    # Print a message to the debug log
    $c->log->debug('*** INSIDE BASE METHOD ***');
}


=head2 url_create

Create a book with the supplied title and rating,
with manual authorization

=cut

sub url_create :Chained('base') :PathPart('url_create') :Args(3) {
    # In addition to self & context, get the title, rating & author_id args
    # from the URL.  Note that Catalyst automatically puts extra information
    # after the "/<controller_name>/<action_name/" into @_
    my ($self, $c, $title, $rating, $author_id) = @_;

    # Check the user's roles
    if ($c->check_user_roles('admin')) {
        # Call create() on the book model object. Pass the table
        # columns/field values we want to set as hash values
        my $book = $c->model('DB::Book')->create({
                title   => $title,
                rating  => $rating
            });

        # Add a record to the join table for this book, mapping to
        # appropriate author
        $book->add_to_book_authors({author_id => $author_id});
        # Note: Above is a shortcut for this:
        # $book->create_related('book_authors', {author_id => $author_id});

        # Assign the Book object to the stash and set template
        $c->stash(book     => $book,
                  template => 'books/create_done.tt2');
    } else {
        # Provide very simple feedback to the user.
        $c->response->body('Unauthorized!');
    }
}


=head2 form_create

Display form to collect information for book to create

=cut

sub form_create :Chained('base') :PathPart('form_create') :Args(0) {
    my ($self, $c) = @_;

    # Set the TT template to use
    $c->stash(template => 'books/form_create.tt2');
}


=head2 form_create_do
    
Take information from form and add to database
    
=cut
    
sub form_create_do :Chained('base') :PathPart('form_create_do') :Args(0) {
    my ($self, $c) = @_;

    # Retrieve the values from the form
    my $title     = $c->request->params->{title}     || 'N/A';
    my $rating    = $c->request->params->{rating}    || 'N/A';
    my $author_id = $c->request->params->{author_id} || '1';

    # Create the book
    my $book = $c->model('DB::Book')->create({
            title   => $title,
            rating  => $rating,
        });
    # Handle relationship with author
    $book->add_to_book_authors({author_id => $author_id});
    # Note: Above is a shortcut for this:
    # $book->create_related('book_authors', {author_id => $author_id});

    # Avoid Data::Dumper issue mentioned earlier
    # You can probably omit this
    $Data::Dumper::Useperl = 1;

    # Store new model object in stash and set template
    $c->stash(book     => $book,
              template => 'books/create_done.tt2');
}

=head2 object

Fetch the specified book object based on the book ID and store
it in the stash

=cut

sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
    # $id = primary key of book to delete
    my ($self, $c, $id) = @_;

    # Find the book object and store it in the stash
    $c->stash(object => $c->stash->{resultset}->find($id));

    # Make sure the lookup was successful.  You would probably
    # want to do something like this in a real app:
    #   $c->detach('/error_404') if !$c->stash->{object};
    die "Book $id not found!" if !$c->stash->{object};

    # Print a message to the debug log
    $c->log->debug("*** INSIDE OBJECT METHOD for obj id=$id ***");
}


=head2 delete

Delete a book

=cut

sub delete :Chained('object') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    # Check permissions
    $c->detach('/error_noperms')
        unless $c->stash->{object}->delete_allowed_by($c->user->get_object);

    # Use the book object saved by 'object' and delete it along
    # with related 'book_authors' entries
    $c->stash->{object}->delete;

    # Use 'flash' to save information across requests until it's read
    $c->flash->{status_msg} = "Book deleted";

    # Redirect the user back to the list page
    $c->response->redirect($c->uri_for($self->action_for('list')));
}


=head2 list_recent

List recently created books

=cut

sub list_recent :Chained('base') :PathPart('list_recent') :Args(1) {
    my ($self, $c, $mins) = @_;

    # Retrieve all of the book records as book model objects and store in the
    # stash where they can be accessed by the TT template, but only
    # retrieve books created within the last $min number of minutes
    $c->stash(books => [$c->model('DB::Book')
                            ->created_after(DateTime->now->subtract(minutes => $mins))]);

    # Set the TT template to use.  You will almost always want to do this
    # in your action methods (action methods respond to user input in
    # your controllers).
    $c->stash(template => 'books/list.tt2');
}


=head2 list_recent_tcp

List recently created books

=cut

sub list_recent_tcp :Chained('base') :PathPart('list_recent_tcp') :Args(1) {
    my ($self, $c, $mins) = @_;

    # Retrieve all of the book records as book model objects and store in the
    # stash where they can be accessed by the TT template, but only
    # retrieve books created within the last $min number of minutes
    # AND that have 'TCP' in the title
    $c->stash(books => [$c->model('DB::Book')
                            ->created_after(DateTime->now->subtract(minutes => $mins))
                            ->title_like('TCP')
                        ]);

    # Set the TT template to use.  You will almost always want to do this
    # in your action methods (action methods respond to user input in
    # your controllers).
    $c->stash(template => 'books/list.tt2');
}


=head2 formfu_create

Use HTML::FormFu to create a new book

=cut

sub formfu_create :Chained('base') :PathPart('formfu_create') :Args(0) :FormConfig {
    my ($self, $c) = @_;

    # Get the form that the :FormConfig attribute saved in the stash
    my $form = $c->stash->{form};
  
    # Check if the form has been submitted (vs. displaying the initial
    # form) and if the data passed validation.  "submitted_and_valid"
    # is shorthand for "$form->submitted && !$form->has_errors"
    if ($form->submitted_and_valid) {
        # Create a new book
        my $book = $c->model('DB::Book')->new_result({});
        # Save the form data for the book
        $form->model->update($book);
        # Set a status message for the user
        $c->flash->{status_msg} = 'Book created';
        # Return to the books list
        $c->response->redirect($c->uri_for($self->action_for('list'))); 
        $c->detach;
    } else {
        # Get the authors from the DB
        my @author_objs = $c->model("DB::Author")->all();
        # Create an array of arrayrefs where each arrayref is an author
        my @authors;
        foreach (sort {$a->last_name cmp $b->last_name} @author_objs) {
            push(@authors, [$_->id, $_->last_name]);
        }
        # Get the select added by the config file
        my $select = $form->get_element({type => 'Select'});
        # Add the authors to it
        $select->options(\@authors);
    }
    
    # Set the template
    $c->stash->{template} = 'books/formfu_create.tt2';
}


=head2 formfu_edit

Use HTML::FormFu to update an existing book

=cut

sub formfu_edit :Chained('object') :PathPart('formfu_edit') :Args(0) 
        :FormConfig('books/formfu_create.yml') {
    my ($self, $c) = @_;

    # Get the specified book already saved by the 'object' method
    my $book = $c->stash->{object};

    # Make sure we were able to get a book
    unless ($book) {
        $c->flash->{error_msg} = "Invalid book -- Cannot edit";
        $c->response->redirect($c->uri_for($self->action_for('list')));
        $c->detach;
    }

    # Get the form that the :FormConfig attribute saved in the stash
    my $form = $c->stash->{form};

    # Check if the form has been submitted (vs. displaying the initial
    # form) and if the data passed validation.  "submitted_and_valid"
    # is shorthand for "$form->submitted && !$form->has_errors"
    if ($form->submitted_and_valid) {
        # Save the form data for the book
        $form->model->update($book);
        # Set a status message for the user
        $c->flash->{status_msg} = 'Book edited';
        # Return to the books list
        $c->response->redirect($c->uri_for($self->action_for('list')));
        $c->detach;
    } else {
        # Get the authors from the DB
        my @author_objs = $c->model("DB::Author")->all();
        # Create an array of arrayrefs where each arrayref is an author
        my @authors;
        foreach (sort {$a->last_name cmp $b->last_name} @author_objs) {
            push(@authors, [$_->id, $_->last_name]);
        }
        # Get the select added by the config file
        my $select = $form->get_element({type => 'Select'});
        # Add the authors to it
        $select->options(\@authors);
        # Populate the form with existing values from DB
        $form->model->default_values($book);
    }

    # Set the template
    $c->stash->{template} = 'books/formfu_create.tt2';
}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

