package MyApp::Controller::AJAX;

use strict;
use warnings;
use parent 'Catalyst::Controller::HTML::FormFu';

sub index : Path Args(0) {
    my ($self, $c) = @_;

    $c->stash(
              no_wrapper => 1,
              template => 'ajax.tt2'
             );
}

sub end : ActionClass('RenderView') {}


1;
