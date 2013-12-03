define icinga::plugins::checkicingareload (
  $pkgname                                  = $::operatingsystem ? {
    /^(Redhat|CentOS)$/: => 'nagios-plugins-icinga-reload-check',
    /^(Debian|Ubuntu)$/: => 'nagios-plugin-icinga-reload-check',
  }
  $contact_groups                           = $::environment,
  $max_check_attempts                       = $::icinga::params::max_check_attempts,
  $notification_period                      = $::icinga::notification_period,
  $notifications_enabled                    = $::icinga::notifications_enabled,
) {

  require ::icinga

  $command_name = 'icinga-reload-check'

  if ! defined(Package[$pkgname]) {
    package{ $pkgname:
      ensure => present,
    }
  }

  file { "${::icinga::includedir_client}/${command_name}.cfg":
    ensure  => 'file',
    mode    => '0644',
    owner   => $::icinga::client_user,
    group   => $::icinga::client_group,
    notify  => Service[$::icinga::service_client],
    content => "command[${command_name}]=cd ${::icinga::plugindir}/; ./checkicingareload",
  }

  nagios_service { "check_icinga_reload":
    check_command         => $command_name,
    service_description   => "See if the icinga configuration has been successfully loaded",
    host_name             => $::fqdn,
    contact_groups        => $contact_groups,
    max_check_attempts    => $max_check_attempts,
    notification_period   => $notification_period,
    notifications_enabled => $notifications_enabled,
    target                => "${::icinga::targetdir}/services/${::fqdn}.cfg",
  }
}