package Curses::Toolkit::Widget::Border;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Widget::Bin);

use Curses::Toolkit::Object::Coordinates;

=head1 NAME

Curses::Toolkit::Widget::Border - a border widget

=head1 DESCRIPTION

This widget consists of a border, and a child widget in that border

This widget can contain 0 or 1 other widget.

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::Border

=cut

sub draw {
	my ($self) = @_;
	my $theme = $self->get_theme();
	my $c = $self->get_coordinates();
	$theme->draw_hline($c->x1(), $c->y1(), $c->width());
	$theme->draw_hline($c->x1(), $c->y2() - 1, $c->width());
	$theme->draw_vline($c->x1(), $c->y1(), $c->height());
	$theme->draw_vline($c->x2() - 1, $c->y1(), $c->height());
	$theme->draw_corner_ul($c->x1(), $c->y1());
	$theme->draw_corner_ll($c->x1(), $c->y2() - 1);
	$theme->draw_corner_ur($c->x2() - 1, $c->y1());
	$theme->draw_corner_lr($c->x2() - 1, $c->y2() - 1);
}

# Returns the relative rectangle that a child widget can occupy.
# This returns the current widget space, shrinked by one (the border size)
#
# input : none
# output : a Curses::Toolkit::Object::Coordinates object

sub _get_available_space {
	my ($self) = @_;
	my $rc = $self->get_relatives_coordinates();
	use Curses::Toolkit::Object::Coordinates;
	return Curses::Toolkit::Object::Coordinates->new(
		x1 => 1, y1 => 1,
        x2 => $rc->width() - 1, y2 => $rc->height() - 1,
	);
}

=head2 get_desired_space

Given a coordinate representing the available space, returns the space desired
The Border desires all the space available, so it returns the available space

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_desired_space {
	my ($self, $available_space) = @_;
	my $desired_space = $available_space->clone();
	return $desired_space;
}

=head2 get_minimum_space

Given a coordinate representing the available space, returns the minimum space
needed to properly display itself

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_minimum_space {
	my ($self, $available_space) = @_;
	my ($child) = $self->get_children();
	my $child_space = Curses::Toolkit::Object::Coordinates->new_zero();
	if (defined $child) {
		my $child_available_space = $available_space->clone();
		$child_available_space->set( x1 => $child_available_space->x1() + 1, y1 => $available_space->y1() + 1,
									 x2 => $child_available_space->x2() - 1, y2 => $available_space->y1() - 1,
								   );
		$child_space = $child->get_minimum_space($child_available_space);
	}
	my $minimum_space = $available_space->clone();
	$minimum_space->set( x2 => $available_space->x1() + $child_space->width() + 2,
						 y2 => $available_space->y1() + $child_space->height() + 2,
					   );
	return $minimum_space;
}

1;
