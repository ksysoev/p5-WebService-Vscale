package Vscale::Scalet;

use AnyEvent;
use Data::Dumper;

sub new {
	my $class = shift;
	my $connect = shift;

	my %args = @_;

	my $self = {
		connect => $connect,
		status_watcher => undef,
		status_request => {},

		status => undef,
		rplan => undef,
		locked => undef,
		keys => [],
		private_address => {},
		name => undef,
		ctid => undef,
		public_address => {},
		hostname => undef,
		location => undef,
		active => undef,
		made_from => undef,
		%args
	};

	bless $self, $class;

	return $self;
}

sub status {
	return $_[0]->{status};
}

sub rplan {
	return $_[0]->{rplan};
}

sub locked {
	return $_[0]->{locked};
}

sub ssh_keys {
	return $_[0]->{keys} || [];
}

sub private_address {
	return $_[0]->{private_address} || {};	
}

sub name {
	return $_[0]->{name};	
}

sub ctid {
	return $_[0]->{ctid};	
}

sub public_address {
	return $_[0]->{public_address} || {};	
}

sub hostname {
	return $_[0]->{hostname};
}

sub location {
	return $_[0]->{location};
}

sub active {
	return $_[0]->{active};
}

sub made_from {
	return $_[0]->{made_from};
}

sub update_info {
	my $self = shift;

	my %args = @_;
	my ($on_result, $on_error) = (sub{}, sub{});	

	$on_result = delete $args{on_result} if ref $args{on_result} eq 'CODE';
	$on_error = delete $args{on_error} if ref $args{on_error} eq 'CODE';

	if ($self->{ctid}) {
		$self->{connect}->_send_request(
			'GET', 
			'scalets/'.$self->{ctid}, 
			undef,
			sub {
				my $response = shift;
				eval {@{$self}{keys %{$response}} = values %{$response}; 1} or do {
					$on_error->('Wrong response format');
					return;
				};
				$on_result->();
			}, 
			$on_error
		);
	} else {
		$on_error->('Wrong ctid of scalet')
	}

}

sub delete {
	my $self = shift;

	my %args = @_;
	my ($on_result, $on_error) = (sub{}, sub{});

	$on_result = delete $args{on_result} if ref $args{on_result} eq 'CODE';
	$on_error = delete $args{on_error} if ref $args{on_error} eq 'CODE';

	if ($self->{ctid}) {
		$self->{connect}->_send_request('DELETE', 'scalets/'.$self->{ctid}, undef, $on_result, $on_error);
	} else {
		$on_error->('Wrong ctid of scalet')
	}	
}

sub reboot {
	my $self = shift;

	my %args = @_;
	my ($on_result, $on_error) = (sub{}, sub{});

	$on_result = delete $args{on_result} if ref $args{on_result} eq 'CODE';
	$on_error = delete $args{on_error} if ref $args{on_error} eq 'CODE';

	if ($self->{ctid}) {
		$self->{connect}->_send_request('PATCH', 'scalets/'.$self->{ctid}.'/restart', undef, $on_result, $on_error);
	} else {
		$on_error->('Wrong ctid of scalet')
	}	
}

sub rebuild {
	my $self = shift;

	my %args = @_;
	my ($on_result, $on_error) = (sub{}, sub{});

	$on_result = delete $args{on_result} if ref $args{on_result} eq 'CODE';
	$on_error = delete $args{on_error} if ref $args{on_error} eq 'CODE';

	if ($self->{ctid}) {
		$self->{connect}->_send_request('PATCH', 'scalets/'.$self->{ctid}.'/rebuild', undef, $on_result, $on_error);
	} else {
		$on_error->('Wrong ctid of scalet')
	}	
}

sub stop {
	my $self = shift;

	my %args = @_;
	my ($on_result, $on_error) = (sub{}, sub{});

	$on_result = delete $args{on_result} if ref $args{on_result} eq 'CODE';
	$on_error = delete $args{on_error} if ref $args{on_error} eq 'CODE';

	if ($self->{ctid}) {
		$self->{connect}->_send_request('PATCH', 'scalets/'.$self->{ctid}.'/stop', undef, $on_result, $on_error);
	} else {
		$on_error->('Wrong ctid of scalet')
	}	
}

sub start {
	my $self = shift;

	my %args = @_;
	my ($on_result, $on_error) = (sub{}, sub{});

	$on_result = delete $args{on_result} if ref $args{on_result} eq 'CODE';
	$on_error = delete $args{on_error} if ref $args{on_error} eq 'CODE';

	if ($self->{ctid}) {
		$self->{connect}->_send_request('PATCH', 'scalets/'.$self->{ctid}.'/start', undef, $on_result, $on_error);
	} else {
		$on_error->('Wrong ctid of scalet')
	}
}

sub upgrade {
	my $self = shift;
	my $new_plan  = shift;

	my %args = @_;
	my ($on_result, $on_error) = (sub{}, sub{});

	$on_result = delete $args{on_result} if ref $args{on_result} eq 'CODE';
	$on_error = delete $args{on_error} if ref $args{on_error} eq 'CODE';

	if ($self->{ctid}) {
		$self->{connect}->_send_request('POST', 'scalets/'.$self->{ctid}.'/upgrade', { rplan => $new_plan }, $on_result, $on_error);
	} else {
		$on_error->('Wrong ctid of scalet')
	}	
}


sub backup {
	my $self = shift;
	my $backup_name  = shift;

	my %args = @_;
	my ($on_result, $on_error) = (sub{}, sub{});

	$on_result = delete $args{on_result} if ref $args{on_result} eq 'CODE';
	$on_error = delete $args{on_error} if ref $args{on_error} eq 'CODE';

	if ($self->{ctid}) {
		$self->{connect}->_send_request('POST', 'scalets/'.$self->{ctid}.'/backup', { name => $backup_name }, $on_result, $on_error);
	} else {
		$on_error->('Wrong ctid of scalet')
	}
}

sub when {
	my $self = shift;
	my $status  = shift;
	my $callback  = shift;

	return unless ref $callback eq 'CODE';

	if ($status  eq $self->{status}) {
		$callback->();
	} else {
		$self->{status_request}{$status} = [] unless ref $self->{status_request}{$status} eq ref [];
		push @{$self->{status_request}{$status}}, $callback;

		$self->{status_watcher} = AnyEvent->timer (
		after => 1, #to avoid multiple request when we make several watchers;
		interval => 5,
		cb => sub {
			$self->update_info(on_result => sub {
				if (ref $self->{status_request}{$self->{status}} eq ref []) {
					while (my $cb = shift @{$self->{status_request}{$self->{status}}}) {
						eval {$cb->()};
					}
					delete $self->{status_request}{$self->{status}};
					unless (keys %{$self->{status_request}}) {
						$self->{status_watcher} = undef 
					}
				}
			});
		},
	);
	}

}


1;