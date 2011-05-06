package Net::HTTP::Spore::Middleware::Flickr;
use Moose;
use Digest::MD5 qw(md5_hex);
use YAML::Syck;

extends 'Net::HTTP::Spore::Middleware';

sub call{
	my ($self, $request) = @_;
    $self->{"spore.method"} = $request->env->{"spore.method"};
    $self->{"spore.method"} =~ s/_/./g;
    
    push( @{$request->env->{"spore.params"}}, "method", "flickr." . $self->{"spore.method"} );

	if ( $self->{api_key} ){
		push( @{$request->env->{"spore.params"}}, 'api_key', $self->{api_key});
	}
	if ( $self->{format} ){
		push( @{$request->env->{"spore.params"}}, 'format', $self->{format});
	}
    if ( $request->env->{"spore.method"} eq 'auth_url'){
        my %args = @{$request->env->{"spore.params"}} ;
        $self->{api_sig} = $self->sign(\%args);
		push( @{$request->env->{"spore.params"}}, 'api_sig', $self->{api_sig});
        return "http://api.flickr.com/services/auth/" . '?api_key=' . $self->{api_key} . "&perms=" . $args{perms}."&api_sig=".$self->{api_sig};
    }
	if ( $self->{api_secret} ){
		my %args = @{$request->env->{"spore.params"}} ;
		push( @{$request->env->{"spore.params"}}, 'api_sig', $self->sign(\%args));
	}
}

sub sign{
	my ($self, $args) = @_;
	
	my $sig = $self->{api_secret};

	foreach my $key (sort {$a cmp $b} keys %{$args}) {
		my $value = (defined($args->{$key})) ? $args->{$key} : "";
		$sig .= $key . $value;
	}
	return md5_hex($sig);
}

1;
