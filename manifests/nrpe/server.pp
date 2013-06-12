#
# class to set up NRPE daemon on remotely monitored nodes
# and allow access to it from Nagios server

class naginator::nrpe::server( $allowed_hosts = ['127.0.0.1'], ) {

    include naginator::params

    package { [ $::naginator::params::nrpe_package, $::naginator::params::nagios_plugin ]:
        ensure => installed,
    }

    service { $::naginator::params::nrpe_service:
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require    => Package[$::naginator::params::nrpe_package],
        subscribe  => File["nrpe_config"],
    }

    file { "nrpe_config":
        name    => "/etc/nagios/nrpe.cfg",
        content => template("naginator/nrpe.erb"),
        mode    => 0644,
        owner   => root,
        group   => root,
        require => File["nrpe_config_dir"],
        notify  => Service[$::naginator::params::nrpe_service],
    }

    file { "nrpe_config_dir":
        name    => "/etc/nagios",
        ensure  => directory,
        mode    => 0755,
        owner   => root,
        group   => root,
        require => Package[$::naginator::params::nrpe_package],
    }

}
