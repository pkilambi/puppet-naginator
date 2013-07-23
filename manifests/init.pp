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

    package { "package_name_list":
        name   => $::naginator::params::package_name_list,
        ensure => installed,
    }

    service { "nagios_service":
        name       => $::naginator::params::service_name,
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require    => Package["package_name_list"],
    }

    package { "nagios_package":
        name    => $::naginator::params::package_name,
        ensure  => installed,
    }      

    #
    # workaround for Debian packaging / Puppet design decision
    # regarding resource management in "non-standard" locations
    if $::osfamily == 'debian' {
        file { "/etc/nagios":
            ensure => link,
            target => "/etc/nagios3/conf.d",
        }
    }

    Nagios_host <<| |>> {
        max_check_attempts => "9",
        target  => $::naginator::params::nagios_host_cfg,
        notify => Service[ "nagios_service" ],
    }

    Nagios_service <<| |>> {
        target  => $::naginator::params::nagios_service_cfg,
        notify => Service[ "nagios_service" ],
    }

    Nagios_hostextinfo <<| |>> {
        target  => $::naginator::params::nagios_hostextinfo_cfg,
    }

    if ($::osfamily == 'Redhat') {
        file { "/etc/nagios/conf.d/nagios_command.cfg":
            ensure => present,
            content => template( "naginator/rhel/command.cfg.erb" ),
            mode => 644,
            owner => nagios, group => nagios,
            notify => Service["nagios_service"],
            require => Package["nagios_package"],
        }
    }

    file { $::naginator::params::cfg_files :
        ensure  => file,
        mode    => 0644,
        owner   => root,
        group   => root,
        replace => false,
        notify  => Service["nagios_service"],
        require => Package["nagios_package"],
    }

    file { $::naginator::params::nagios_users:
        ensure  => file,
        mode    => 0644,
        owner   => root,
        group   => root,
        source  => $::naginator::params::passwd_path,
        require => Package["nagios_package"],
    }

    file { $::naginator::params::cgi_cfg:
        ensure  => file,
        mode    => 0644,
        owner   => root,
        group   => root,
        source  => $::naginator::params::cgi_file_path,
        require => Package["nagios_package"],
    }

    file { $::naginator::params::nagios_apache:
         ensure => link,
         target => $::naginator::params::nagios_apache,
    }
}
