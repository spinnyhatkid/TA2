TA2
===

Server and client ldap and nfs configurations

# Client & Server Kickstart Installations
* Root user password for client installations is automatically set to 'client'
* user1 password defaults to user

# NFS Server Config
* When running the NFS config program with the -h or --help options the application will let the user know that the script configures a server to use NFS.
* When run without the help options the NFS config program will proceed to configure the server in the following ways:
 * The firewall will be configured to set a static port of 4002 to be used for the mountd service to prevent it from aquiring a random port each time it starts.
 * The ports used by nfs, portmapper and mountd will be opened in the iptables for both UDP and TCP traffic for the 10.0.0.0/8 IP address range.
 * The /etc/exports file is configured to allow the exporting of the /home directory with read write permissions for the 10.0.0.0/8 IP address range.  After configuring the /etc/exports file the /home directory is then exported.
 * NFS is configured to run on a level 3 startup.
 * A newly created nfsManifest.txt file logs each step of the configuration.
