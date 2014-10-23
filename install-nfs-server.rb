require 'optparse'

class ConfigNFS
  def initialize
    #currently does nothing, probably will be set for logging.
  end

  #Main method - runs program.
  def config
    config_firewall
    mount_and_export
    config_nfs_startup
  end

  #configure the mountd service port as static and allow udp/tcp via iptables
  def config_firewall
    File.open("/etc/sysconfig/network", "a") { |f| f.write("MOUNTD_PORT=4002") }
    `service nfs restart`

    ports = 4002, 2049, 111
    ports.each do |port|
      `iptables -I INPUT 1 -s 10.0.0.0/8 -p tcp -m tcp --dport #{port} -j ACCEPT`
      `iptables -I INPUT 1 -s 10.0.0.0/8 -p udp -m udp --dport #{port} -j ACCEPT`
    end
    `service iptables save`
    `service iptables restart`
  end

  def mount_and_export
    #File.open("/etc/fstab", "a") { |f| f.write("/home /dev/sda5 ext3 defaults 0 0") }
    File.open("/etc/exports", "a") { |f| f.write("/home 10.0.0.0/255.0.0.0(rw)") }

    `exportfs -a`
  end

  #starts services and registers with chkconfig at run level 3
  def config_nfs_startup
    `chkconfig --level 3 nfs on`
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on_tail("-h", "--help", "Configures NFS for a server") do
    puts opts
    exit
  end
end.parse!

nfs = ConfigNFS.new
nfs.config

p options
p ARGV
