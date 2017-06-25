use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME             => 'WebService::Vscale',
	AUTHOR           => q{Sysoev Kirill <k.sysoev@me.com>},
	VERSION_FROM     => 'lib/WebService/Vscale.pm',
	ABSTRACT_FROM    => 'lib/WebService/Vscale.pm',
	LICENSE          => 'artistic_2',
	PL_FILES         => {},
	MIN_PERL_VERSION => 5.006,
	CONFIGURE_REQUIRES => {
		'ExtUtils::MakeMaker' => 0,
	},
	BUILD_REQUIRES => {
		'Test::More' => 0,
	},
	PREREQ_PM => {
		'AnyEvent::HTTP' => 0,
		'JSON::XS' => 0,
	},
	dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean => { FILES => 'WebService-Vscale-*' },
);
