# Examples for using the Unix CLI with HP Cloud Services

The Unix Command Line Interface is a tool which allows Unix or Mac users to manage their
HP Cloud Services from the command line. The Unix CLI binary is named 'hpcloud' and it runs
within your favorite terminal. To execute the following examples, please start a terminal window.

## Usage and Help

To be able to get an overall idea of what the Unix CLI features, we run the following commands/tasks:

### Version information

        $ hpcloud info             # => version: 0.0.13

### List of available commands/tasks

        $ hpcloud

### Getting help for a particular command/task

To see detailed help about usage, examples and aliases for a command, use

        $ hpcloud help <TASK>

## Account Setup

To be able to interact with the HP Cloud Services using the Unix CLI, we have to setup the account. To setup
your account you will need the account details from the HP Cloud Services web site API Keys page.

        $ hpcloud account:setup

        ****** Setup your HP Cloud Services account ******
        Account ID: <enter your account key>
        Account Key: <enter your secret key>
        Auth Uri: [https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/]
        Tenant Id: <enter your tenant id>
        Verifying your HP Cloud Services account...
        Account credentials for HP Cloud Services have been set up.

If you get an error, then re-run the account setup again with the correct account details. If you get
message that one of your services is not activated, please make sure that at least one HP Cloud service
is activated.

## Interacting with the Storage Service

The following list of commands or tasks, let you interact with the HP Cloud Storage service:

        hpcloud acl <object/container>                                                             # view the ACL for an object or container
        hpcloud acl:set <resource> <acl>                                                           # set a given resource to a canned ACL
        hpcloud containers                                                                         # list available containers
        hpcloud containers:add <name>                                                              # add a container
        hpcloud containers:remove <name>                                                           # remove a container
        hpcloud copy <resource> <resource>                                                         # copy files from one resource to another
        hpcloud get <object>                                                                       # fetch an object to your local directory
        hpcloud list <container>                                                                   # list container contents
        hpcloud location <object/container>                                                        # display the URI for a given resource
        hpcloud move <object> <object>                                                             # move objects inside or between containers
        hpcloud remove <object/container>                                                          # remove an object or container

Let us look at each command/task in detail. Remember that you can get detailed help for any command/task by:

        $ hpcloud help <TASK>

To add a new container:

        $ hpcloud containers:add demorama
        # => Created container 'demorama'.

To list available containers:

        $ hpcloud list
        # => demorama
        # => demorama2
or

        $ hpcloud containers
        # => demorama
        # => demorama2

To add or copy objects to a container:

        $ hpcloud copy simple.txt :demorama
        # => Copied simple.txt => :demorama/simple.txt

To copy objects from a container to the local file system:

        $ hpcloud copy :demorama/simple.txt ./simple.txt
        # => Copied :demorama/simple.txt => ./simple.txt

To copy objects between container:

        $ hpcloud copy :demorama/simple.txt :demorama2
        # => Copied :demorama/simple.txt => :demorama2/simple.txt

        $ hpcloud copy :demorama/simple.txt :demorama2/simpler.txt
        # => Copied :demorama/simple.txt => :demorama2/simpler.txt

To list the contents of a container:

        $ hpcloud list demorama
        # => simple.txt

To get an object to the local file system:

        $ hpcloud get :demorama2/simpler.txt
        # => Copied :demorama2/simpler.txt => simpler.txt

To move objects from a container to the local file system:

        $ hpcloud move :demorama/simple.txt ./simple.txt
        # => Moved :demorama/simple.txt => ./simple.txt

To move objects between container:

        $ hpcloud move :demorama2/simpler.txt :demorama
        # => Moved :demorama2/simple.txt => :demorama

        $ hpcloud move :demorama/simple.txt :demorama2/even_simpler.txt
        # => Moved :demorama/simple.txt => :demorama2/even_simpler.txt

To get ACLs for an existing container:

        $ hpcloud acl :demorama
        # => private

To get ACLs for an existing object:

        $ hpcloud acl :demorama/simple.txt
        # => private

To set an ACL for an existing container:

        $ hpcloud acl:set :demorama public-read
        # => ACL for :demorama updated to public-read.

To set an ACL for an existing object:

        $ hpcloud acl:set :demorama/simple.txt public-read
        # => ACL for :demorama/simple.txt updated to public-read.

To get a location for an existing container:

        $ hpcloud location demorama
        # => http://127.0.0.1/v1/AUTH_ea2007cf-5c74-4936-b381-743b438b45e8/demorama

To get a location for an existing object:

        $ hpcloud location demorama/simple.txt
        # => http://127.0.0.1/v1/AUTH_ea2007cf-5c74-4936-b381-743b438b45e8/demorama/simple.txt

To remove an object from a container:

        $ hpcloud remove :demorama2/even_simpler.txt
        # => Removed object ':demorama2/even_simpler.txt'.

To remove a container if empty:

        $ hpcloud containers:remove :demorama2
        # => Removed container 'demorama2'.

To force removal of a container even there are files in it:

        $ hpcloud containers:remove :demorama --force
        # => Removed container 'demorama'.


## Interacting with the CDN Service

The following list of commands or tasks, let you interact with the HP Cloud CDN service:

        hpcloud cdn:containers                                                                     # list of available containers on the CDN
        hpcloud cdn:containers:add <name>                                                          # add a container to the CDN
        hpcloud cdn:containers:get <name> <attribute>                                              # get the value of an attribute on a CDN container.
        hpcloud cdn:containers:location <name>                                                     # get the location of a container on the CDN.
        hpcloud cdn:containers:remove <name>                                                       # remove a container from the CDN
        hpcloud cdn:containers:set <name> <attribute> <value>                                      # set attributes on a CDN container.

Let us look at each command/task in detail. Remember that you can get detailed help for any command/task by:

        $ hpcloud help <TASK>

To list available containers on the CDN:

        $ hpcloud cdn:containers
        # => demorama

To add an existing container to the CDN:

        $ hpcloud cdn:containers:add demorama2
        # => Added container 'demorama2' to the CDN.

To get the location of an existing container on the CDN:

        $ hpcloud cdn:containers:location demorama2
        # => http://ha7828c283acdf403a69c74a35b5f8d97.cdn.hpcloudsvc.com

To get the value of an attribute of a container on the CDN:

        $ hpcloud cdn:containers:get demorama2 X-Ttl
        # => 86400

To set the value of an attribute of a container on the CDN:

        $ hpcloud cdn:containers:set demorama2 X-Ttl 900
        # => The attribute 'X-Ttl' with value '900' was set on CDN container 'demorama2'.

To remove an existing container from the CDN:

        $ hpcloud cdn:containers:remove demorama2
        # => Removed container 'demorama2' from the CDN.


## Interacting with the Compute Service

The following list of commands or tasks, let you interact with the HP Cloud Compute service:

        hpcloud addresses                                                                          # list of available addresses
        hpcloud addresses:add                                                                      # add or allocate a new public IP address
        hpcloud addresses:associate <public_ip> <server_name>                                      # associate a public IP address to a server instance
        hpcloud addresses:disassociate <public_ip>                                                 # disassociate any server instance associated to the publ...
        hpcloud addresses:remove <public_ip>                                                       # remove or release a public IP address
        hpcloud config:set                                                                         # set the value for a setting
        hpcloud flavors                                                                            # list of available flavors
        hpcloud images                                                                             # list of available images
        hpcloud images:add <name> <server_name>                                                    # add an image from an existing server
        hpcloud images:remove <name>                                                               # remove an image by name
        hpcloud keypairs                                                                           # list of available keypairs
        hpcloud keypairs:add <key_name>                                                            # add a key pair
        hpcloud keypairs:import <key_name> <public_key_data>                                       # import a key pair
        hpcloud keypairs:remove <key_name>                                                         # remove a key pair by name
        hpcloud securitygroups                                                                     # list of available security groups
        hpcloud securitygroups:add <name> <description>                                            # add a security group
        hpcloud securitygroups:remove <name>                                                       # remove a security group
        hpcloud securitygroups:rules <sec_group_name>                                              # list of rules for a security group
        hpcloud securitygroups:rules:add <sec_group_name> <ip_protocol> <port_range> <ip_address>  # add a rule to the security group
        hpcloud securitygroups:rules:remove <sec_group_name> <rule_id>                             # remove a rule from the security group
        hpcloud servers                                                                            # list of available servers
        hpcloud servers:add <name> <image_id> <flavor_id>                                          # add a server
        hpcloud servers:password <server_name> <password>                                          # change password for a server
        hpcloud servers:reboot <name>                                                              # reboot a server by name
        hpcloud servers:remove <name>                                                              # remove a server by name

Let us look at each command/task in detail. Remember that you can get detailed help for any command/task by:

        $ hpcloud help <TASK>

### Flavors

To list available flavors:

        $ hpcloud flavors

### Images

To list available images:

        $ hpcloud images

To add a new snapshot image based on a server:

        $ hpcloud images:add myimage myserver
        # => Created image 'myimage' with id '111'.

To remove an existing snapshot image:

        $ hpcloud images:remove myimage
        # => Removed image 'myimage'.

### Servers

To list servers:

        $ hpcloud servers

To add a new server, by specifying an image and a flavor:

        $ hpcloud servers:add myserver 227 100
        # => Created server 'myserver' with id '111'.

To add a new server, by specifying an image, a flavor, a keyname and a security group:

        $ hpcloud servers:add myserver 227 100 -k mykey -s mysecgroup
        # => Created server 'myserver' with id '222'.

To change password of an existing server:

        $ hpcloud servers:password myserver new_password
        # => Password changed for server 'myserver'.

To soft or hard reboot an existing server:

        $ hpcloud servers:reboot myserver
        # => Soft rebooting server 'myserver'.

        $ hpcloud servers:reboot myserver --hard
        # => Hard rebooting server 'myserver'.

To remove an existing server:

        $ hpcloud servers:remove myserver
        # => Removed server 'myserver'.

### Keypairs

To list keypairs:

        $ hpcloud keypairs

To add a new keypair:

        $ hpcloud keypairs:add mykeypair
        # =>
        # => -----BEGIN RSA PRIVATE KEY-----
        # => MIICXgIBAAKBgQC18ljyebY0GGKxLY6DHcKv1xXw3MCFaRhtXse7zgGjBejMjOz/
        # => wLOMmxH51ZHmx4c01jRLa7nSNIK8Nf8CPB4TJXbZlMXl0jokRcKq4aIOYc3CPdf1
        # => wLOMmxH51ZHmx4c01jRLa7nSNIK8Nf8CPB4TJXbZlMXl0jokRcKq4aIOYc3CPdf1
        # => wLOMmxH51ZHmx4c01jRLa7nSNIK8Nf8CPB4TJXbZlMXl0jokRcKq4aIOYc3CPdf1
        # => wLOMmxH51ZHmx4c01jRLa7nSNIK8Nf8CPB4TJXbZlMXl0jokRcKq4aIOYc3CPdf1
        # => Ks7HJQseX1/bpQZveqeie5pNT3taJmvjE22dctp4mxFQg9FhAkEA4QugvG023ccn
        # => Ks7HJQseX1/bpQZveqeie5pNT3taJmvjE22dctp4mxFQg9FhAkEA4QugvG023ccn
        # => Ks7HJQseX1/bpQZveqeie5pNT3taJmvjE22dctp4mxFQg9FhAkEA4QugvG023ccn
        # => Ks7HJQseX1/bpQZveqeie5pNT3taJmvjE22dctp4mxFQg9FhAkEA4QugvG023ccn
        # => /Fb5Ikzrhop4HukT/RoXeAlLegLtsLEhSJFw4W4HB/83/qsXB0/IXyG46T0FAkEA
        # => /Fb5Ikzrhop4HukT/RoXeAlLegLtsLEhSJFw4W4HB/83/qsXB0/IXyG46T0FAkEA
        # => /Fb5Ikzrhop4HukT/RoXeAlLegLtsLEhSJFw4W4HB/83/qsXB0/IXyG46T0FAkEA
        # => /Fb5Ikzrhop4HukT/RoXeAlLegLtsLEhSJFw4W4HB/83/qsXB0/IXyG46T0FAkEA
        # => -----END RSA PRIVATE KEY-----
        # => Created key pair 'mykeypair'.

To add a new keypair and save it to a file:

        $ hpcloud keypairs:add mykeypair2 --output
        # => Created key pair 'mykeypair2' and saved it to a file at './mykeypair2.pem'.

To add a new keypair by importing public key data:

        $ hpcloud keypairs:import mykeypair3 <public key data>
        # => Imported key pair 'mykeypair3'.

To remove an existing keypair:

        $ hpcloud keypairs:remove mykeypair
        # => Removed key pair 'mykeypair'.

### Security Groups

To list security groups:

        $ hpcloud securitygroups

To add a new security group:

        $ hpcloud securitygroups:add mysecgroup "my sec group desciption"
        # => Created security group 'mysecgroup'.

To remove an existing security group:

        $ hpcloud securitygroups:remove mysecgroup
        # => Removed security group 'mysecgroup'.

### Security Group Rules

To list rules for an existing security group:

        $ hpcloud securitygroups:rules mysecgroup

To add a new rule to an existing security group:

        $ hpcloud securitygroups:rules:add mysecgroup icmp
        # => Created rule '1111' for security group 'mysecgroup'.

        $ hpcloud securitygroups:rules:add mysecgroup tcp 22..22
        # => Created rule '1112' for security group 'mysecgroup'.

        $ hpcloud securitygroups:rules:add mysecgroup tcp 80..80 "111.111.111.111/1"
        # => Created rule '1113' for security group 'mysecgroup'.

To remove an existing rule from a security group:

        $ hpcloud securitygroups:rules:remove mysecgroup 1111
        # => Removed rule '1111' for security group 'mysecgroup'.

### Addresses or Floating IPs

To list addresses:

        $ hpcloud addresses

To add or allocate a new address:

        $ hpcloud addresses:add
        # => Created a public IP address '11.11.11.11'.

To associate an existing address to an existing server:

        $ hpcloud addresses:associate "11.11.11.11" myserver
        # => Associated address '11.11.11.11' to server 'myserver'.

To disassociate an existing address to an existing server:

        $ hpcloud addresses:associate "11.11.11.11" myserver
        # => Disassociated address '11.11.11.11' from any server instance.

To remove or release an existing address:

        $ hpcloud addresses:remove "11.11.11.11"
        # => Removed address '11.11.11.11'.

### Configuration

To set availability zone and save it to the configuration file:

        $ hpcloud config:set -z az2                # sets availability zone to az2
        # => Configuration setting have been saved to the config file.

