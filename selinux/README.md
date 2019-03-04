# SELinux

**NOTE:**
Examples are tested and created in fedora. Using different SELinux policies on other
distros might give different default ports & modules.

##### Changing boolean values:


Allow httpd to connect to other servers (such as node)
```
$ sudo setsebool -P httpd_can_network_connect on
```

Allow httpd to access home DIR:
```
$ sudo setsebool -P httpd_enable_homedirs on
```

##### Context changing:

Change the context of the files in directory as httpd servable content (e.g. certificaticates & assets).

Declare context:
```
$ sudo chcon -Rt httpd_sys_content_t /home/user/Workspace
```
Use reference context:
```

$ sudo chcon -R --reference=/var/www /home/user/Workspace
```

Restore to original context

```
$ sudo restorecon -Rv /home/user/www
```

##### Troubleshooting

###### 1. Using audit2why & changing values

A simple fix for actions not permitted by SELinux.

```
$ sudo tail -f /var/log/audit/audit.log

type=AVC msg=audit(1545650286.394:331): avc:  denied  { name_connect } for  pid=1049 comm="nginx" dest=3500 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

$ sudo grep 1545650286.394:331 /var/log/audit/audit.log | audit2why

type=AVC msg=audit(1545650286.394:331): avc:  denied  { name_connect } for  pid=1049 comm="nginx" dest=3500 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

    Was caused by:
    One of the following booleans was set incorrectly.
    Description:
    Allow httpd to can network connect

    Allow access by executing:
    # setsebool -P httpd_can_network_connect 1
    Description:
    Allow nis to enabled

    Allow access by executing:
    # setsebool -P nis_enabled 1
```

###### 2. DIR not writeable/unlinkable

Check the owner of the file by `ls -laZ`
```
$ ls -laZ

drwxrwxr-x.  3 user    user    unconfined_u:object_r:httpd_sys_content_t:s0  4096 Dec 26 23:08 .
drwxrwxr-x. 10 user    user    unconfined_u:object_r:httpd_sys_content_t:s0  4096 Dec 23 16:24 ..
-rw-rw-r--.  1 user    user    unconfined_u:object_r:httpd_sys_content_t:s0  8982 Dec 27 00:45 index.php
drwxrwxr-x.  2 user    user    unconfined_u:object_r:httpd_sys_content_t:s0  4096 Dec 27 00:46 sessions

```

In some instances, A software (e.g. PHP-FPM) cannot write on a dir like `sessions`
but the `audit` doesn't show any problems. If this happens it may be an issue of
ownership. You can view the ownership by executing:

```
$ getent passwd | grep php-fpm
$ getent group | grep php-fpm
```

If `getent` doesn't show results, you can also check the processes and ports. In this
instance PHP-FPMs pools are owned by `nobody:nobody`. You can change the ownership
by executing the `chown` command. It is also not suggested to always run webservers
as root.

```
$ sudo chown -R nobody:nobody sessions
$ ls -laZ

drwxrwxr-x.  3 user    user    unconfined_u:object_r:httpd_sys_content_t:s0  4096 Dec 26 23:08 .
drwxrwxr-x. 10 user    user    unconfined_u:object_r:httpd_sys_content_t:s0  4096 Dec 23 16:24 ..
-rw-rw-r--.  1 user    user    unconfined_u:object_r:httpd_sys_content_t:s0  8982 Dec 27 00:45 index.php
drwxrwxr-x.  2 nobody nobody unconfined_u:object_r:httpd_sys_content_t:s0  4096 Dec 27 01:53 sessions
```

###### 3. Module Creation
**NOTE:**
Some modules might get allowed accidentally due to your choice of port number. To view the list of reserved ports, execute the command below:
```
$ sudo semanage port -l | grep -w http_port_t

http_port_t    tcp    80, 81, 443, 488, 8008, 8009, 8443, 9000
```

If this is the result of audit2why, better create a module:

```
type=AVC msg=audit(1545655683.003:398): avc:  denied  { read } for  pid=1 comm="systemd" name="nginx" dev="tmpfs" ino=271189 scontext=system_u:system_r:init_t:s0 tcontext=system_u:object_r:httpd_tmp_t:s0 tclass=dir permissive=0

    Was caused by:
        Missing type enforcement (TE) allow rule.

        You can use audit2allow to generate a loadable module to allow this access.
```

Creating a policy
```
$ sudo grep nginx /var/log/audit/audit.log | audit2allow -m custom-nginx-module > custom-nginx-module.te
```

Sample policy content will be:
```
module custom-nginx-module 1.0;

require {
    type http_port_t;
    type httpd_t;
    type httpd_tmp_t;
    type init_t;
    type unreserved_port_t;
    class capability sys_resource;
    class dir { read rmdir };
    class process setrlimit;
    class tcp_socket { name_bind name_connect };
}

#============= httpd_t ==============

##### Used by NGINX;
#!!!! This avc can be allowed using one of the these booleans:
#     httpd_run_stickshift, httpd_setrlimit
allow httpd_t self:capability sys_resource;

##### Used by NGINX;
#!!!! This avc can be allowed using the boolean 'httpd_setrlimit'
allow httpd_t self:process setrlimit;

##### Allow NGINX connection on http_ports:9000;
#!!!! This avc can be allowed using one of the these booleans:
#     httpd_can_network_connect, httpd_graceful_shutdown, httpd_can_network_relay, nis_enabled
allow httpd_t http_port_t:tcp_socket name_connect;

##### Allow NGINX connection on unreserved ports (e.g. 11061-11069);
#!!!! This avc can be allowed using one of the these booleans:
#     httpd_can_network_connect, nis_enabled
allow httpd_t unreserved_port_t:tcp_socket name_connect;

##### Allow NGINX binding on unreserved ports (e.g. 11061-11069);
#!!!! This avc can be allowed using the boolean 'nis_enabled'
allow httpd_t unreserved_port_t:tcp_socket name_bind;

#============= init_t ==============

##### Allow init system to read and delete NGINX's tmp dir
allow init_t httpd_tmp_t:dir { read rmdir };
```

Generate policy:
Requirement: `selinux-policy-devel`

```
$ sudo checkmodule -M -m -o custom-nginx-module.mod custom-nginx-module.te
$ sudo semodule_package -o custom-nginx-module.pp -m custom-nginx-module.mod
```
Install policy

```
$ sudo semodule -i custom-nginx-module.pp
```

Check if policy loaded:
```
$ sudo semodule -l | grep custom-nginx-module
```

To remove:
```
semodule -r custom-nginx-module
```




