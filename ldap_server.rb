#!/usr/bin/env ruby

require 'optparse'

options = {}

optparse = OptionParser.new do |opts| 

	options [ :help ] 
	opts.on('-h','--help','Help') do
		options [ :help ] == true
	end



end

class ConfigLDAP

	def initialize
	$stdout.reopen("ldapManifest.txt","w")
 	$stderr.reopen("ldapManifest.txt","a")
  	end


  	def config 

		config_firewall
  		config_slapd
  		config_client_LDAP
  		config_database
  		config_migrate
  		diradm
  		config_ldap_start
  	end

	#Configure iptables to allow traffic for ldap on ports 389 and 636 for TCP and UDP, and restart iptables
  	def config_firewall
		`iptables -A INPUT -s 10.0.0.0/255.0.0.0 -p udp -m state --state NEW -m multiport --dports 389,636 -j ACCEPT`
		`iptables -A INPUT -s 10.0.0.0/255.0.0.0 -p tcp -m state --state NEW -m multiport --dports 389,636 -j ACCEPT`
		`service iptables save`
		`service iptables restart`
		
	end

	#Edit the slapd.conf file
	def config_slapd
		slapd_conf = File.read('/etc/openldap/slapd.conf')

		# Disable LDAPv2 connections
		slapd_conf = slapd_conf.gsub(/allow bind_v2/,"#allow bind_v2")
		# Configure the suffix, rootdn, rootpw
		slapd_conf = slapd_conf.gsub(/suffix\t\t\"dc=my-domain,dc=com\"/,"suffix          \"dc=cit470_Team_4,dc=nku,dc=edu\"")
		slapd_conf = slapd_conf.gsub(/rootdn\t\t\"cn=Manager,dc=my-domain,dc=com\"/,"rootdn          \"cn=Manager,dc=cit470_team_4,dc=nku,dc=edu \"") 
		slapd_conf = slapd_conf.gsub(/# rootpw\t\t\{crypt\}ijFYNcSNctBYg/,"\nrootpw                  \{SSHA\}3YGEc7Na9bdBANZ6nahRKhYxn3XCJED4")

		# Write the slapd.conf file
		File.open('/etc/openldap/slapd.conf','w'){|file| file.puts slapd_conf}

	end

	# Edit the client LDAP config file on the server
	def config_client_LDAP
		ldap_conf = File.read('/etc/openldap/ldap.conf')

		# Set the BASE suffix to match the BASE suffix from the slapd conf file
		ldap_conf = ldap_conf.gsub(/#BASE\tdc=example, dc=com/,"BASE dc=cit470_Team_4,dc=nku,dc=edu")

		
		# Write the ldap.conf file
		File.open('/etc/openldap/ldap.conf','w'){|file| file.puts ldap_conf}

		# Configure LDAP ACL to allow  password changes

		ldap="access to attrs=userPassword\nby self write\nby anonymous auth\nby * none\naccess to *\nby self write\nby * read"
		File.open('/etc/openldap/ldap.conf','a') {|file| file.puts ldap}
		
	end

	# Build LDAP database  
	def config_database
		migration_dir ='/usr/share/openldap/migration'

		migrate_common = File.read("#{migration_dir}/migrate_common.ph")
		migrate_common = migrate_common.gsub(/$DEFAULT_MAIL_DOMAIN = \"padl.com\";/, "$DEFAULT_MAIL_DOMAIN = \"cit470_Team_4\.nku\.edu\";")
		migrate_common = migrate_common.gsub(/$DEFAULT_BASE = \"dc=padl,dc=com\";/, "$DEFAULT_BASE = \"dc=cit470_Team_4, dc=nku, dc=edu\";")
		File.open("#{migration_dir}/migrate_common.ph",'w'){|file| file.puts migrate_common} 

		base_ldap = 
		"dn: dc=cit470_Team_4,dc=nku,dc=edu
		dc: cit470_Team_4
		objectClass: top
		objectClass: domain\n
		dn: ou=People,dc=cit470_Team_4,dc=nku,dc=edu
		ou: People
		objectClass: top
		objectClass: organizationalUnit\n
		dn: ou=Group,dc=cit470_Team_4,dc=nku,dc=edu
		ou: Group
		objectClass: top
		objectClass: organizationalUnit\n"

		File.open("#{migration_dir}/base.ldif", 'w') {|f| f.write(base_ldap)}
	end

	# Migrate account/group data to ldap server
	def config_migrate
		
		Dir.chdir("/usr/share/openldap/migration")
		#`cd /usr/share/openldap/migration`
		
		`slapadd -l /usr/share/openldap/migration/base.ldif`

		# Migrate the passwd file
		`/usr/share/openldap/migration/migrate_passwd.pl /etc/passwd >/usr/share/openldap/migration/passwd.ldif`
		`slapadd -l /usr/share/openldap/migration/passwd.ldif`

		# Migrate the group file
		`/usr/share/openldap/migration/migrate_group.pl /etc/group >/usr/share/openldap/migration/group.ldif`
		`slapadd -l /usr/share/openldap/migration/group.ldif`

		# Change ownership of files
		`chown -R ldap.ldap /var/lib/ldap`

	end


# Start LDAP service, verify it is running and have it start on boot
	def config_ldap_start

		`chkconfig --level 3 ldap on`
		`service ldap start`

		ldap_status = `service ldap status`

		if ldap_status.include? "running"
			puts "LDAP Server was started correctly"
		elsif ldap_status.include? "stopped"
			puts "LDAP server is not started or is not working correctly"
		else
			puts "Error processing LDAP status"
		end
	end

	# Download and move diram to the local directory
	def diradm
		Dir.chdir("/usr/local")
		#`cd /usr/local`
		`wget http://www.hits.at/diradm/diradm-1.3.tar.gz`
		`tar zxvf diradm-1.3.tar.gz`
	end




end

obj = ConfigLDAP.new
obj.config


