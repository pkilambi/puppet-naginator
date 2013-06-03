#
# This class sets up the Nagios server pieces required for Nagios
# monitoring
#
# In addition, if the Nagios server is monitoring itself, this class
# also includes the definitions for monitors which target the
# Nagios server
#

class naginator {
 
  include naginator::params

    package { $::naginator::params::package_name_list:
        ensure => installed,
    }

    service { $::naginator::params::service_name:
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require    => Package[$::naginator::params::package_name_list ],
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
        notify => Service[ $::naginator::params::service_name ],
    }

    Nagios_service <<| |>> {
        notify => Service[ $::naginator::params::service_name ],
    }

    Nagios_hostextinfo <<| |>>

    file { $::naginator::params::cfg_files :
        ensure  => file,
        mode    => 0644,
        owner   => root,
        group   => root,
        replace => false,
        notify  => Service[$::naginator::params::service_name],
        require => Package[$::naginator::params::package_name],
    }

    file { $::naginator::params::nagios_users:
        ensure  => file,
        mode    => 0644,
        owner   => root,
        group   => root,
        source  => 'puppet:///modules/naginator/htpasswd.users',
        require => Package[$::naginator::params::package_name],
    }

    file { $::naginator::params::cgi_cfg:
        ensure  => file,
        mode    => 0644,
        owner   => root,
        group   => root,
        source  => 'puppet:///modules/naginator/cgi.cfg',
        require => Package[$::naginator::params::package_name],
    }

}
