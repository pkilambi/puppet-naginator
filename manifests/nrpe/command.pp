#
# definition used to create config files on remote nodes specifying
# monitoring commands to be executed by Nagios server via NRPE

define naginator::nrpe::command ( $command,) {

    include naginator::params

    file { "${::naginator::params::nrpe_dir}/${title}.cfg":
        ensure => present,
        mode   => 0755,
        owner  => root,
        group  => root,
        content => template("naginator/command.erb"),
        require => Package[ [ $::naginator::params::nrpe_package, $::naginator::params::nagios_plugin] ],
        notify  => Service[$::naginator::params::nrpe_service],
    }

}
