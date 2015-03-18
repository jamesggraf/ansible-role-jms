SOACONFIG
=========
This role provided the following functionality:
* soa patching (b2b)
* soa schema creationing using Repository Creation Utility (RCU)
* domain creation with machine/server/cluster configurations

Playbooks for patching the B2B instances, creating the B2B database schema, creating Weblogic B2B domains, and copying the domains to added nodes.

Local Testing and Execution
---------------------------
This role requires the use of a scratch database. Until we streamline the process, you will need the following boxes:
* opscode-sps-ol6-6 - s3://sps-build-deploy/vagrant/SPS-OL6-6-x86_64.vbox.box
* db-sps-ol5-ora11gR1 - s3://sps-vagrant-boxen/slalom.ol5.ora11gR1.scratch.box

TODO: create a rake task for starting both vagrant boxes and executing tests. For now use the following steps:

1. Download vagrant boxes above and make sure ol6 box is named `opscode-sps-ol6-6`
2. Create vagrant file for db-sps-ol5-ora11gR1 (refer to below)
3. Pull dependencies using ansible sdk. `ansible-sdk dependencies`
4. Execute test kitchen tests using `bundle exec kitchen converge #(or test)`

```
# vagrant box for db-sps-ol5-ora11gR1
Vagrant.configure(2) do |config|
  config.vm.box = "https://s3.amazonaws.com/sps-vagrant-boxen/slalom.ol5.ora11gR1.scratch.box"
  config.vm.network "forwarded_port", guest: 1521, host: 1521
  config.vm.network "private_network", ip: "192.168.33.10"
end
```

Requirements
------------

This role utilizes a local S3_file module, and requires boto. By default, this role will install the required package if it is missing. You can then either use the required ENV variables, or set s3_key and s3_secret.

Requires the olprep role, jrockit role, weblogic roles, and the SOA role.

olprep
https://github.com/SPSCommerce/ansible-role-olprep

jrockit
https://github.com/SPSCommerce/ansible-role-jrockit

weblogic
https://github.com/SPSCommerce/ansible-role-weblogic

SOA
https://github.com/SPSCommerce/ansible-role-soa

Role Variables
--------------

| variable | description | default | mandatory
|----------|-------------|---------|----------
| `s3_key` | AWS S3 access key id | none | no
| `s3_secret` | AWS S3 secret access key | none | no
| `cfg_is_admin` | Is admin server? | true | yes
| `cfg_product` | b2b, as2, etc. | b2b | yes
| `cfg_username` | Weblogic username | weblogic | yes
| `cfg_password` | Weblogic password | password1 | yes
| `cfg_admin_server_name` | Admin server name | AdminServer | cfg_is_admim == true
| `cfg_admin_server_listen_address` | Admin server listening address | hostname.corp.spscommerce.net | cfg_is_admim == true
| `cfg_admin_server_listen_port` | Admin server listening port | 7001 | cfg_is_admim == true
| `cfg_admin_server_ssl_enabled` | Admin server ssl enabled? | false | no
| `cfg_admin_server_ssl_listen_port` | Admin server ssl port | 7101 | no
| `cfg_admin_server_log_directory` | Admin server log directory | {{ cfg_domain_path }}/{{ cfg_domain_name }}/servers/{{ cfg_admin_server_name }}/logs | no
| `cfg_admin_server_jvm_args` | Admin server jvm args | -XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Dweblogic.Stdout={{ cfg_admin_server_log_directory }}/{{ cfg_admin_server_name }}.out -Dweblogic.Stderr={{ cfg_admin_server_log_directory }}/{{ cfg_admin_server_name }}_err.out | no
| `cfg_servers` | List of servers (Refer to server variables below) | [ ] | cfg_is_admim == true
| `cfg_machines` | List of servers (Refer to server variables below) | [ ] | cfg_is_admim == true
| `cfg_clusters` | List of servers (Refer to server variables below) | [ ] | cfg_is_admim == true
| `cfg_oracle_home` | Oracle user home directory | /home/oracle | yes
| `cfg_wl_home` | Weblocic middleware base directory | /u01/app/oracle/middleware | yes
| `cfg_working_dir` | Config working directory | {{ cfg_oracle_home }}/config | yes
| `cfg_wls_user` | Weblogic system user | oracle | yes
| `cfg_wls_group` | Weblogic system group | oinstall | yes
| `cfg_wlst_bin_dir` | WLST bin directory | {{ cfg_wl_home }}/soa/common/bin | yes
| `cfg_logging_file_count` | Logging file count | 10 | yes
| `cfg_logging_file_min_size` | Logging minimum file size | 5000 | yes
| `cfg_logging_rotation_type` | Logging rotation type | byTime | yes
| `cfg_logging_file_time_span` | Logging file time span | 24 | yes
| `cfg_nm_use_secure_listener` | Set node mangager SecureListener value (true|false) | false | yes
| `cfg_domain_name` | Domain name | soa_domain | yes
| `cfg_override_domain` | Override domain cofigurations | true | yes
| `cfg_domain_path` | Domains path | {{ cfg_wl_home }}/user_projects/domains | yes
| `cfg_apps_path` | Applications path | {{ cfg_wl_home }}/user_projects/applications | yes
| `cfg_init_logs_dir` | init.d log directory | /u01/wl_start_logs/ | yes
| `cfg_development_mode` | Is development mode? | false | cfg_is_admim == true
| `cfg_wls_template` | WLS Template | {{ cfg_wl_home }}/wlserver_10.3/common/templates/domains/wls.jar | cfg_is_admim == true
| `cfg_template_applcore` | WLS ApplCore template | {{ cfg_wl_home }}/oracle_common/common/templates/applications/oracle.applcore.model.stub.11.1.1_template.jar | cfg_is_admim == true
| `cfg_template_jrf` | WLS JRF template | {{ cfg_wl_home }}/oracle_common/common/templates/applications/jrf_template_11.1.1.jar | cfg_is_admim == true
| `cfg_template_wsmpm` | WLS WSMPM template | {{ cfg_wl_home }}/oracle_common/common/templates/applications/oracle.wsmpm_template_11.1.1.jar | cfg_is_admim == true
| `cfg_template_soa` | WLS SOA template | {{ cfg_wl_home }}/soa/common/templates/applications/oracle.soa_template_11.1.1.jar | cfg_is_admim == true
| `cfg_template_em` | WLS EM template | {{ cfg_wl_home }}/oracle_common/common/templates/applications/oracle.em_11_1_1_0_0_template.jar | cfg_is_admim == true
| `cfg_java_vendor` | Java vendor | JRockit | cfg_is_admim == true
| `cfg_java_home` | Java home | /u01/app/oracle/jrockit | cfg_is_admim == true
| `cfg_soa_s3_bucket` | SOA S3 bucket | sps-build-deploy | cfg_product == "b2b"
| `cfg_soa_base_dir` | SOA base directory | {{ cfg_wl_home }}/soa | cfg_product == "b2b"
| `cfg_soa_media_dir` | SOA media directory | /u01/media | cfg_product == "b2b"
| `cfg_soa_inventory_loc` | SOA inventory location | {{ cfg_oracle_home }}/oraInventory | cfg_product == "b2b"
| `cfg_b2b_s3_base` | B2B s3 base path | /non-sps/oracle/b2b/ | cfg_product == "b2b"
| `cfg_db_driver` | DB driver | jdbc:oracle:thin: | cfg_is_admim == true
| `cfg_db_hostname` | DB hostname | database.corp.spscommerce.net | cfg_is_admim == true
| `cfg_db_port` | DB port | 1521 | cfg_is_admim == true
| `cfg_db_dbms_name` | DB DBMS name | scratch | cfg_is_admim == true
| `cfg_db_dbuser_prefix` | DB user prefix | B2BAWS | cfg_is_admim == true
| `cfg_db_schema_password` | DB Schema password | change_on_install | cfg_is_admim == true
| `cfg_db_sys_password` | DB system password | change_on_install | cfg_is_admim == true
| `cfg_db_sys_user` | DB system user | sys | cfg_is_admim == true
| `cfg_db_role` | DB system role | SYSDBA | cfg_is_admim == true
| `cfg_rca_s3_base` | RCA S3 base path | /non-sps/oracle/rca/ | cfg_is_admim == true
| `cfg_rcu_home_dir` | RCU home directory | {{ cfg_wl_home }}/rca/rcuHome | cfg_is_admim == true
| `cfg_db_component1` | MDS DB Component | MDS | cfg_is_admim == true
| `cfg_db_component2` | SOAINFRA DB Component | SOAINFRA | cfg_is_admim == true
| `cfg_db_component3` | ORASDPM DB Component | ORASDPM | cfg_is_admim == true


### `cfg_servers` Variables

| variable | description | example | default | mandatory
|----------|-------------|---------|---------|----------
| `name` | Server name | soa_server1 | none | yes
| `listen_address` | Server listening address | hostname.corp.spscommerce.net | none | yes
| `listen_port` | Server listening port | 8001 | none | yes
| `ssl_enabled` | Server SSL enabled | false | false | no
| `ssl_listen_port` | Server SSL listening port | 8101 | {{ server.listen_port+100 }} | no
| `log_directory` | Server log directory | see default | {{ cfg_domain_path }}/{{ cfg_domain_name }}/servers/{{ server.name }}/logs | no
| `jvm_args` | Server JVM arguments | see default | -XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Dweblogic.Stdout={{ server.log_directory }}/{{ server.name }}.out -Dweblogic.Stderr={{ server.log_directory }}/{{ server.name }}_err.out | no


### `cfg_machines` Variables

| variable | description | example | default | mandatory
|----------|-------------|---------|---------|----------
| `name` | Machine name | hostname | none | yes
| `node_manager_listen_address` | Machine name | hostname.corp.spscommerce.net | none | yes
| `node_manager_listen_port` | Machine name | 5556 | 5556 | yes
| `servers` | Server names associated with machine | "AdminServer,soa_server1" | none | yes


### `cfg_clusters` Variables

| variable | description | example | default | mandatory
|----------|-------------|---------|---------|----------
| `name` | Cluster name | soa_cluster | none | yes
| `messaging_mode` | Cluster messaging mode | unicast | unicast | no
| `servers` | Server names associated with cluster | "soa_server1,soa_server2" | none | yes


Dependencies
------------

See requirements.

Example Playbook
----------------

An example playbook is included in the test directory, but here is a rundown on typical usage.

```yaml
- hosts: all
  roles:
    - { role: olprep }
    - { role: jrockit,
        java_version: 1.6.0_45-R28.2.7-4.1.0,
        java_arch: x64,
        java_s3_bucket: sps-build-deploy,
        java_s3_base: /non-sps/oracle/java/,
        java_user: oracle, 
        java_group: oinstall,
        java_media_dir: /u01/media,
        java_response_dir: jrockit,
        java_response_basedir: /home/oracle/response, 
        java_response_file: silent.xml, 
        java_install_file: install_jrockit.sh }
    - { role: weblogic, 
        wls_version: 1035, 
        wls_s3_bucket: sps-build-deploy, 
        wls_s3_base: /non-sps/oracle/weblogic/, 
        wls_creates_file: /u01/app/oracle/middleware/wlserver_10.3/.product.properties, 
        wls_media_dir: /u01/media, 
        wls_response_dir: weblogic, 
        wls_user: oracle, 
        wls_group: oinstall }
    - { role: soa, 
        soa_version: 11.1.1.4.0, 
        soa_response_basedir: /home/oracle/response, 
        soa_response_dir: soa, 
        soa_response_file: soa11g_wls.rsp, 
        soa_user: oracle, 
        soa_group: oinstall, 
        soa_media_dir: /u01/media, 
        soa_java: /u01/app/oracle/jrockit, 
        soa_inventory_loc: '/home/oracle/oraInventory', 
        orainstloc: oraInst.loc, 
        soa_creates_file: /u01/app/oracle/middleware/soa }
    - { role: soaconfig,
        cfg_is_admin: true,
        cfg_product: "b2b",
        cfg_username: "weblogic",
        cfg_password: "password1",
        cfg_admin_server_name: "AdminServer",
        cfg_admin_server_listen_address: "machine1.corp.spscommerce.net",
        cfg_admin_server_listen_port: 7001,
        cfg_admin_server_jvm_args: "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m  -Dweblogic.Stdout=/tmp/AdminServer.out -Dweblogic.Stderr=/tmp/AdminServer_err.out",
        cfg_servers: [
          {
            name: "soa_server1",
            listen_address: "machine1.corp.spscommerce.net",
            listen_port: 8001,
            jvm_args: "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m  -Dweblogic.Stdout=/tmp/soa_server1.out -Dweblogic.Stderr=/tmp/soa_server1_err.out"
          }
        ],
        cfg_machines: [
          {
            name: "server1",
            node_manager_listen_address: "machine1.corp.spscommerce.net",
            node_manager_listen_port: 5556,
            servers: "AdminServer,soa_server1"
          }
        ],
        cfg_clusters: [
          {
            name: "soa_cluster",
            messaging_mode: "unicast",
            servers: "soa_server1" 
          }
        ],
        cfg_domain_name: "soa_domain",
        cfg_override_domain: true,
        cfg_java_vendor: "JRockit",
        cfg_java_home: "/u01/app/oracle/jrockit",
        cfg_db_hostname: "database.corp.spscommerce.net",
        cfg_db_port: 1521,
        cfg_db_dbms_name: "scratch",
        cfg_db_dbuser_prefix: "B2BAWS",
        cfg_db_schema_password: "change_on_install",
        cfg_db_sys_password: "change_on_install" }
```

Author Information
------------------

Daniel Strang (dstrang@spscommerce.com) and Robbie Burda (rburda@spscommerce.com)
