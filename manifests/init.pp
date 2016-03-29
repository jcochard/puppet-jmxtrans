# == Class jmxtrans
#
class jmxtrans {
	include jmxtrans::install
	include jmxtrans::service
}

# == Class jmxtrans::metrics
#
# Writes a jmxtrans JSON file in
# /var/lib/jmxtrans/$title.json.
# Each file in this directory should correspond to a single
# JMX instance and specify the object and metric names to query
# the JMX instance for.
#
# == Parameters
# $jmx                  - host:port of JMX to query (required)
# $queries              - array of hashes of the form [ { "obj" => "JMX object name", "attr" => [ "array", "of", "JMX", "metric", "names" ] }, ... ]
# $jmx_username         - JMX username (if there is one)
# $jmx_password         - JMX password (if there is one)
# $seconds              - set the seconds between runs
# $ganglia              - host:port of Ganglia gmond
# $ganglia_group_name   - Ganglia metrics group
# $graphite             - host:port of Graphite server
# $graphite_root_prefix - rootPrefix for Graphite
# $outfile              - local file path in which to save metric query results
define jmxtrans::metrics(
	$jmx,
	$queries,
	$jmx_username         = undef,
	$jmx_password         = undef,
	$resultAlias          = undef,
	$seconds              = undef,
	$ganglia              = undef,
	$ganglia_group_name   = undef,
	$graphite             = undef,
	$graphite_root_prefix = undef,
	$outfile              = undef
	)
{
	require jmxtrans

	file { "/var/lib/jmxtrans/${title}.json":
		content => template("jmxtrans/jmxtrans.json.erb"),
		notify  => Service["jmxtrans"],
		require => Package["jmxtrans"],
	}

	# This should probably go in a params file
	if $seconds {
		case $::osfamily {
			'Debian': {
				$defaults_location = '/etc/default/jmxtrans'
			}
			'Redhat': {
				$defaults_location = '/etc/sysconfig/jmxtrans'
			}
			default: {
				fail("\"${module_name}\" provides no defaults_location
							for \"${::osfamily}\"")
			}
		}
		file_line { 'jmx_defaults':
	    path   => $defaults_location,
	    line   => 'export SECONDS_BETWEEN_RUNS=10',
	    match  => 'export SECONDS_BETWEEN_RUNS=',
			notify => Service['jmxtrans'],
	  }
	}
}
