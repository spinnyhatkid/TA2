TA2
===

Server and client ldap and nfs configurations

# NFS Server Config
* When running the NFS config program with the -h or --help options the application will let the user know that the script configures a server to use NFS.
* When run without the help options the NFS config program will proceed to configure the server in the following ways:
 * The firewall will be configured to set a static port of 4002 to be used for the mountd service to prevent it from aquiring a random port each time it starts.
 * The ports used by nfs, portmapper and mountd will be opened in the iptables for both UDP and TCP traffic for the 10.0.0.0/8 IP address range.
 * The /etc/exports file is configured to allow the exporting of the /home directory with read write permissions for the 10.0.0.0/8 IP address range.  After configuring the /etc/exports file the /home directory is then exported.
 * NFS is configured to run on a level 3 startup.
 * A newly created nfsManifest.txt file logs each step of the configuration.

#LDAP Server Config

*  When running the LDAP config program with the -h or --help options the application will let the user know that the script configures a server to use LDAP.
* When run without the help options the LDAP config program will proceed to configure the server in the following ways:
  * The firewall will be configured to allow traffic on ports 389, and 636 for UDP and TCP packets for the 10.0.0.0/8 network
  * The slapd config file was configured with the following suffix and rootdn:
    * Suffix: dc=cit470_Team_4,dc=nku,dc=edu
    * Rootdn: cn=Manager,dc=cit470,dc=nku,dc=edu
  * The script creates the following LDAP database:
    * dn: dc=cit470_Team_4,dc=nku,dc=edu
		    dc: cit470_Team_4
		    objectClass: top
		    objectClass: domain
		  dn: ou=People,dc=cit470_Team_4,dc=nku,dc=edu
		    ou: People
		    objectClass: top
		    objectClass: organizationalUnit
		  dn: ou=Group,dc=cit470_Team_4,dc=nku,dc=edu
		    ou: Group
		    objectClass: top
		    objectClass: organizationalUnit
  * LDAP is configured to run on a level 3 startup.
  * A newly created ldapManifest.txt file logs each step of the configuration.
