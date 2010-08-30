package MyApp::Controller::API;

use strict;
use warnings;
use parent 'Catalyst::Controller::REST';

__PACKAGE__->config(default => 'application/json');

sub grid : Local ActionClass('REST') {}

sub grid_POST {
    my ($self, $c) = @_;

    my ($page, $search_by, $search_text, $rows, $sort_by, $sort_order) =
      @{ $c->req->params }{qw/page qtype query rp sortname sortorder/};

    s/\W*(\w+).*/$1/ for $sort_by, $sort_order, $search_by; # sql injections bad

    my %data;

    my $rs = $c->model('DB::Book')->search({}, {
                                                order_by => "$sort_by $sort_order",
                                               });

    $rs = $rs->search_literal("lower($search_by) LIKE ?", lc($search_text))
      if $search_by && $search_text;

    my $paged_rs = $rs->search({}, {
                                    page => $page,
                                    rows => $rows,
                                   });

    $data{total} = $rs->count;
    $data{page}  = $page;
    $data{rows}  = [
                    map { +{
                            id => $_->id,
                            cell => [
                                     $_->id,
                                     $_->title,
                                     $_->rating,
                                     $_->author_list,
                                    ]
                           } } $paged_rs->all
                   ];

    $self->status_ok($c, entity => \%data);
}

sub book : Local ActionClass('REST') {
    my ($self, $c, $id) = @_;

    $c->stash(book => $c->model('DB::Book')->find($id));
}

sub book_DELETE {
    my ($self, $c, $id) = @_;

    $c->stash->{book}->delete;

    $self->status_ok($c, entity => { message => 'success' });
}


sub book_form_add : Local Args(0) FormConfig('books/formfu_create.yml') {
    my ($self, $c) = @_;

    my $form = $c->stash->{form};

    if ($form->submitted_and_valid) {
        my $book = $c->model('DB::Book')->new_result({});
        $form->model->update($book);
    } else {
        my @author_objs = $c->model("DB::Author")->all();
        my @authors;
        foreach (sort {$a->last_name cmp $b->last_name} @author_objs) {
            push(@authors, [$_->id, $_->last_name]);
        }
        my $select = $form->get_element({type => 'Select'});
        $select->options(\@authors);
    }

    $c->stash(
              no_wrapper => 1,
              template => 'books/formfu_create.tt2'
             );
}

sub book_form_edit : Local Args(1) FormConfig('books/formfu_create.yml') {
    my ($self, $c, $id) = @_;

    $c->log->info("book form edit called");

    my $form = $c->stash->{form};
    my $book = $c->model('DB::Book')->find($id);

    if ($form->submitted_and_valid) {
        $form->model->update($book);
    } else {
        my @author_objs = $c->model("DB::Author")->all();
        my @authors;
        foreach (sort {$a->last_name cmp $b->last_name} @author_objs) {
            push(@authors, [$_->id, $_->last_name]);
        }
        my $select = $form->get_element({type => 'Select'});
        $select->options(\@authors);
        $form->model->default_values($book);
    }

    $c->stash(
              no_wrapper => 1,
              template => 'books/formfu_create.tt2'
             );
}

1;
