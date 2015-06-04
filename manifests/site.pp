## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# PRIMARY FILEBUCKET
# This configures puppet agent and puppet inspect to back up file contents when
# they run. The Puppet Enterprise console needs this to display file contents
# and differences.

# Define filebucket 'main':
filebucket { 'main':
  server => 'puppetmaster1',
  path   => false,
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }
}
#45.xx.x.x is the yum1 machine
node 'yum1' {
   include jenkins
   include java 
   include maven
}

node 'java1' {
  include java
  #include maven
  #include ::tomcat
  #tomcat { 'Calendar.war':
  #catalina_base => '/var/lib/tomcat/webapps',
  #war_source    =>'/var/tmp/Calendar.war',

  #file { '/opt/apache-tomcat-7.0.62/webapps/Calendar.war':
  #ensure => file,
  #source => '/var/tmp/Calendar.war',
  #notify => Exec['restart_tomcat'],
  #}

  file { '/opt/apache-tomcat-7.0.62/webapps/simple-webapp.war':
  ensure => file,
  source => '/var/tmp/simple-webapp.war',
  notify => Exec['restart_tomcat'],
  }

  exec { 'restart_tomcat':
    #cwd => '/bin/systemctl',
    command     => '/usr/sbin/service tomcat restart',
    #command     => 'sh /opt/apache-tomcat-7.0.62/bin/startup.sh',
    refreshonly => true,
  }

}



