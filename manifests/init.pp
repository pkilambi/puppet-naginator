#
# This class sets up the Nagios server pieces required for Nagios
# monitoring
#
# In addition, if the Nagios server is monitoring itself, this class
# also includes the definitions for monitors which target the
# Nagios server
#

class naginator {
  case $::osfamily {
   'redhat': {
        $service_name      = 'nagios'
	$package_name      = 'nagios'
	$package_name_list = [ "nagios", "nagios-plugins-nrpe", "nagios-plugins", ]
        $cfg_files         = [ "/etc/nagios/conf.d/nagios_command.cfg",
                               "/etc/nagios/conf.d/nagios_host.cfg",
                               "/etc/nagios/conf.d/nagios_hostextinfo.cfg",
                               "/etc/nagios/conf.d/nagios_service.cfg", ]
        $nagios_users      = '/etc/nagios/htpasswd.users'
        $cgi_cfg           = '/etc/nagios/cgi.cfg'
   }
   'debian': {
        $service_name      = 'nagios3'
        $package_name      = 'nagios3'
        $package_name_list = [ "nagios3", "nagios-nrpe-plugin", "nagios-plugins",
                               "nagios3-doc", ]
        $cfg_files         = [ "/etc/nagios3/conf.d/nagios_command.cfg",
                               "/etc/nagios3/conf.d/nagios_host.cfg",
                               "/etc/nagios3/conf.d/nagios_hostextinfo.cfg",
                               "/etc/nagios3/conf.d/nagios_service.cfg", ]
        $nagios_users      = "/etc/nagios3/htpasswd.users"
        $cgi_cfg           = '/etc/nagios3/cgi.cfg'
   }
    default: {
        fail("unsupported osfamily: $::osfamily")
   }
 }

    package { $package_name_list:
        ensure => installed,
    }

    service { $naginator::service_name:
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require    => Package[$package_name_list ],
    }

    #
    # workaround for Debian packaging / Puppet design decision
    # regarding resource management in "non-standard" locations
    if $osfamily == 'debian' {
        file { "/etc/nagios":
            ensure => link,
            target => "/etc/nagios3/conf.d",
        }
    }

    Nagios_host <<| |>> {
        notify => Service[ $service_name ],
    }

    Nagios_service <<| |>> {
        notify => Service[ $service_name ],
    }

    Nagios_hostextinfo <<| |>>

    file { $naginator::cfg_files :
        ensure  => file,
        mode    => 0644,
        owner   => root,
        group   => root,
        replace => false,
        notify  => Service[$service_name],
        require => Package[$package_name],
    }

    file { $naginator::nagios_users:
        ensure  => file,
        mode    => 0644,
        owner   => root,
        group   => root,
        source  => 'puppet:///modules/naginator/htpasswd.users',
        require => Package[$package_name],
    }

    file { $naginator::cgi_cfg:
        ensure  => file,
        mode    => 0644,
        owner   => root,
        group   => root,
        source  => 'puppet:///modules/naginator/cgi.cfg',
        require => Package[$package_name],
    }

}
