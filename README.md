# Ansible Role: Monitoring Plugins

[![Build Status](https://travis-ci.com/transitiv/ansible-role-monitoring-plugins.svg?branch=master)](https://travis-ci.com/transitiv/ansible-role-monitoring-plugins)

This role installs packaged and custom monitoring plugins on RHEL/CentOS and
Debian/Ubuntu systems.

## Requirements

Root accesss is required for installing packages, so you must run it in a
playbook with global root privileges or define `become: yes` when the role is
included.

```yaml
- hosts: monitored_servers
  roles:
    - role: transitiv.monitoring-plugins
      become: yes
```

### Package Repositories

On CentOS and RHEL the EPEL repository must be enabled in order to install the
default packages.

On CentOS 8 the PowerTools repository must also be enabled to install the
default packages.

## Dependencies

This role has no dependencies.

## Variables

```yaml
monitoring_plugins_install_recommends: true
```

(Debian/Ubuntu) Defines whether apt installs recommended packages.

```yaml
# Debian 8 (Jessie)
monitoring_plugins_packages:
  - monitoring-plugins-standard
  - libnagios-plugin-perl
# Debian / Ubuntu
monitoring_plugins_packages:
  - monitoring-plugins-standard
  - libmonitoring-plugin-perl
# CentOS / RHEL 6
monitoring_plugins_packages:
  - perl-Monitoring-Plugin
  - perl-Class-Accessor
  - nagios-plugins-all
# CentOS / RHEL
monitoring_plugins_packages:
  - perl-Monitoring-Plugin
  - nagios-plugins-all
```

Defines the packages installed by this role. This variable is "flattened"
before it is used so it can contain nested lists if required.

```yaml
monitoring_plugins_config_file: /etc/monitoring-plugins.ini
```

Defines the location of an INI file that can be used for the
"[Extra-Opts](https://www.monitoring-plugins.org/doc/extra-opts.html)"
functionality supported by the standard monitoring plugins and plugins
utilising the Nagios::Plugin or Monitoring::Plugin Perl libraries. This is
useful for passing sensitive information such as passwords to plugins without
it being appearing in the command line.

```yaml
monitoring_plugins_config_user: ''
monitoring_plugins_config_group: ''
monitoring_plugins_config_mode: '0644'
```

Defines the user, group and permissions of the file specified in
`monitoring_plugins_config_file`.

Note that the default is not secure. If you will be using this functionality
then the mode should be set to a minimum of '0640', along with the user and/or
group that will be executing the plugins.

```yaml
monitoring_plugins_custom_directory: /usr/local/lib/nagios/plugins
```

Defines the destination directory for any custom monitoring plugins. The
directory will be created if it does not exist.

```yaml
monitoring_plugins_custom_directory_user: ''
monitoring_plugins_custom_directory_group: ''
monitoring_plugins_custom_directory_mode: '0755'
```

Defines the the user, group and permissions of the directory specified in
`monitoring_plugins_custom_directory`.

The default values should be sufficient unless your custom plugins contain
sensitive information.

```yaml
monitoring_plugins_custom_plugins_source_directory: files/monitoring-plugins
```

Defines the directory on the local filesystem used as the source for custom
plugins.


```yaml
monitoring_plugins_custom_plugins_user: ''
monitoring_plugins_custom_plugins_group: ''
monitoring_plugins_custom_plugins_mode: '0755'
```

Defines the user, group and permissions of the custom plugins copied into the
directory specified in `monitoring_plugins_custom_directory`.

```yaml
monitoring_plugins_custom_plugins: []
monitoring_plugins_group_custom_plugins: []
monitoring_plugins_host_custom_plugins: []
```

Defines the custom plugins that will be copied into the directory specified in
`monitoring_plugins_custom_directory`. The group and host variables can be used
to specify additional custom plugins on a group and host specific basis.

Values for entries can either be a plain filename or a hash with the following keys:

* `file` (required) - defines location of the plugin on the local filesystem (relative to `monitoring_plugins_custom_plugins_source_directory`)
* `name` (optional) - defines the filename of the plugin on the host (defaults to the basename of `file`)
* `user` (optional) - defines the owner of the plugin on the host
* `group` (optional) - defines the group of the plugin on the host
* `mode` (optional) - defines the permissions of the plugin on the host (defaults to `monitoring_plugins_custom_plugins_mode`)

```yaml
monitoring_plugins_config: {}
monitoring_plugins_group_config: {}
monitoring_plugins_host_config: {}
```

Defines the values used to render the file specified in
`monitoring_plugins_config_file`. The format of the file is a 2 level nested
hash with the top level key being the name of the group in the INI file and
inner hash specifying the keys and values within that group.

Note that the values of the base, group and host variables are merged using the
"[combine](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html#combining-hashes-dictionaries)"
filter, allowing values to be overridden or extra values to be added on a per
group or host basis.


## Example

### Inventory

```
[database_servers]
db01

[monitored_servers]
db01
```

### Playbook

```yaml
- hosts: monitored_servers
  become: yes
  roles:
    - transitiv.monitoring-plugins
```

### Variables

Inside `group_vars/all.yml`:

```yaml
monitoring_plugins_config_user: 'nagios'
monitoring_plugins_config_mode: '0640'

monitoring_plugins_custom_plugins:
  - check_linux_memory.pl
  - check_zfs_pool_usage.pl
```

Inside `group_vars/database_servers.yml`:

```yaml
monitoring_plugins_group_custom_plugins:
  - check_mysql_health.pl

monitoring_plugins_group_config:
  check_mysql_health:
    username: monitoring
```

Inside `host_vars/db01.yml`:

```
monitoring_plugins_host_config:
  check_mysql_health:
    database: wordpress
    password: "{{ lookup('password', 'passwords/db01/monitoring' }}"
```

## License

MIT

## Author Information

This role was created in 2019 by [Transitiv Technologies
Ltd](https://www.transitiv.co.uk).
