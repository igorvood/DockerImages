# Running an Oracle Real Application Clusters Database using Podman

This project offers sample container files for Oracle Grid Infrastructure (GI) and Oracle Real Application Clusters (Oracle RAC):

* Oracle Database 21c Oracle Grid Infrastructure (21.7) for Linux x86-64
* Oracle Database 21c (21.7) for Linux x86-64

IMPORTANT: To access the Oracle RAC database on your network either use the Podman  MACVLAN driver, or use Oracle Connection Manager. To run Oracle RAC containers on Multi-Host, you must use the Podman MACVLAN driver, and your network must be reachable on all the nodes for Oracle RAC containers.

## Using this Image

To create an Oracle RAC environment, execute the steps in the following sections:

- [Running an Oracle Real Application Clusters Database using Podman](#running-an-oracle-real-application-clusters-database-using-podman)
  - [Using this Image](#using-this-image)
  - [Section 1: Prerequisites for running Oracle RAC with Podman](#section-1-prerequisites-for-running-oracle-rac-with-podman)
    - [Notes](#notes)
  - [Section 2: Building Oracle RAC Database Container Images](#section-2-building-oracle-rac-database-container-images)
    - [Notes](#notes-1)
  - [Section 3: Creating the Oracle Grid Infrastructure and Oracle RAC Container](#section-3-creating-the-oracle-grid-infrastructure-and-oracle-rac-container)
    - [Password management](#password-management)
    - [Notes](#notes-2)
    - [Prepare the envfile](#prepare-the-envfile)
      - [Edit `/opt/containers/envfile` file and make required changes](#edit-optcontainersenvfile-file-and-make-required-changes)
    - [Deploying Oracle RAC on a Container with Block Devices](#deploying-oracle-rac-on-a-container-with-block-devices)
    - [Deploying Oracle RAC on Container With Oracle RAC Storage Container](#deploying-oracle-rac-on-container-with-oracle-rac-storage-container)
    - [Assign networks to Oracle RAC containers](#assign-networks-to-oracle-rac-containers)
    - [Start the first container](#start-the-first-container)
    - [Connect to the Oracle RAC Container](#connect-to-the-oracle-rac-container)
  - [Section 4: Adding an Oracle RAC Node Using a Container](#section-4-adding-an-oracle-rac-node-using-a-container)
    - [Password Management](#password-management-1)
    - [Notes](#notes-3)
    - [Prepare the envfile](#prepare-the-envfile-1)
    - [Deploying with Block Devices](#deploying-with-block-devices)
    - [Deploying Oracle RAC on Container with Oracle RAC Storage Container](#deploying-oracle-rac-on-container-with-oracle-rac-storage-container-1)
    - [Assign Networks to Additional Oracle RAC Container](#assign-networks-to-additional-oracle-rac-container)
    - [Start Oracle RAC container](#start-oracle-rac-container)
    - [Connect to the Oracle RAC container](#connect-to-the-oracle-rac-container-1)
  - [Section 5: Connecting to Oracle RAC Database](#section-5-connecting-to-oracle-rac-database)
  - [Section 6: Environment Variables for the first node](#section-6-environment-variables-for-the-first-node)
  - [Section 7: Environment Variables for the second and subsequent nodes](#section-7-environment-variables-for-the-second-and-subsequent-nodes)
  - [Sample Container Files for Older Releases](#sample-container-files-for-older-releases)
  - [Section 9 : Support](#section-9--support)
  - [Section 10 : License](#section-10--license)
  - [Section 11 : Copyright](#section-11--copyright)

## Section 1: Prerequisites for running Oracle RAC with Podman

**IMPORTANT:** You must make the changes specified in this section (customized for your environment) before you proceed to the next section.

You must install and configure [Podman release 4.0.2 or later](https://docs.oracle.com/en/operating-systems/oracle-linux/Podman/) on Oracle Linux 8.5 or later to run Oracle RAC on Podman. Each container that you will deploy as part of your cluster must satisfy the minimum hardware requirements of the Oracle RAC and Oracle Grid Infrastructure software. An Oracle RAC database is a shared-everything database.

All data files, control files, redo log files, and the server parameter file (`SPFILE`) used by the Oracle RAC database must reside on shared storage that is accessible by all the Oracle RAC database instances.

You must provide block devices shared across the hosts.  If you don't have shared block storage, then you can use an NFS volume. The Podman host must meet the requirements specified in the documentation:

[Real Application Clusters Installation Guide for Podman Oracle Linux x86-64](https://docs.oracle.com/en/database/oracle/oracle-database/21/install-and-upgrade.html/) 

Ensure that your environment meets all the listed prerequisites.

Complete configuration as follows: 

1. Configure the following addresses manually in your DNS.
   * Public IP address for each container
   * Private IP address for each container
   * Virtual IP address for each container
   * Three single client access name (SCAN) addresses for the cluster.
2. If you are planning to use block devices for shared storage, then allocate block devices for Oracle Cluster Registry (OCR) and voting and database files.
3. If you are planning to use NFS storage for OCR, voting and database files, then configure NFS storage, and export at least one NFS mount. For testing purposes only, use the Oracle `rac-storage-server` image to deploy a container providing NFS-based sharable storage. This applies also to the domain name server (DNS) server.
4. If you are planning to use a `DNSServer` container for SCAN, IPs, VIPs resolution, then configure the DNSServer. For testing purposes only, use the Oracle `DNSServer` image to deploy a container providing DNS resolutions.
5. Verify you have enough memory and CPU resources available for all containers. Each container for Oracle RAC requires 8 GB memory and 16 GB swap.
6. For Oracle RAC, you must set the following parameters at the host level in `/etc/sysctl.conf`:

  ```INI
  fs.file-max = 6815744
  net.core.rmem_max = 4194304
  net.core.rmem_default = 262144
  net.core.wmem_max = 1048576
  net.core.wmem_default = 262144
  ```

* After the file is modified, run the following commands:

    ```bash
    # sysctl -a
    # sysctl -p
    ```

7. Before you start the installation, you must plan your private and public network. You can create a network bridge on every host so containers running within that host can communicate with each other.  For example, create `rac_pub1_nw` for the public network (`172.16.1.0/24`) and `rac_priv1_nw` (`192.168.17.0/24`) for a private network. You can use any network subnet for testing. In this document we reference the public network on `172.16.1.0/24` and the private network on `192.168.17.0/24`.

  ```bash
  # Podman network create --driver=bridge --subnet=172.16.1.0/24 rac_pub1_nw
  # Podman network create --driver=bridge --subnet=192.168.17.0/24 rac_priv1_nw 
  ```

* To run Oracle RAC using Podman on multiple hosts, you must create a [Podman `macvlan` network](https://docs.Podman.io/en/latest/markdown/Podman-network-create.1.html), using the following commands:

    ```bash
    # Podman network create -d macvlan --subnet=172.16.1.0/24 --gateway=172.16.1.1 -o parent=eth0 rac_pub1_nw
    # Podman network create -d macvlan --subnet=192.168.17.0/24 -o parent=eth1 rac_priv1_nw
    ```

8. Oracle RAC must run certain processes in real-time mode. To run processes inside a container in real-time mode, populate the real-time CPU budgeting on machine restarts. create oneshot systemd service as mentioned following:

* Create a file `/etc/systemd/system/Podman-rac-cgroup.service`
* Append the following lines:

    ```INI
    [Unit]
     Description=Populate Cgroups with real time chunk on machine restart
     After=Podman-restart.service
    [Service]
     Type=oneshot
     ExecStart=/bin/bash -c “/bin/echo 950000 > /sys/fs/cgroup/cpu,cpuacct/machine.slice/cpu.rt_runtime_us && /bin/systemctl restart Podman-restart.service”
     StandardOutput=journal
     CPUAccounting=yes
     Slice=machine.slice
    [Install]
     WantedBy=multi-user.target
    ```

* After creating the file `/etc/systemd/system/Podman-rac-cgroup.service` with the above contents, execute following steps:

    ```bash
    # systemctl daemon-reload
    # systemctl enable Podman-rac-cgroup.service
    # systemctl enable Podman-restart.service 
    # systemctl start Podman-rac-cgroup.service
    ```

10. To resolve VIPs and SCAN IPs, we are using a dummy DNS container in this guide. Before proceeding to the next step, create a [DNS server container](../OracleDNSServer/README.md). If you have a preconfigured DNS server in your environment, then you can replace `-e DNS_SERVERS=172.16.1.25`, `--dns=172.16.1.25`, `-e DOMAIN=example.com`  and `--dns-search=example.com` parameters in **Section 2: Building Oracle RAC Database Podman Install Images** with the `DOMAIN_NAME' and 'DNS_SERVER' based on your environment. You must ensure that you have the`Podman-docker` package installed on your OL8 Podman host to run the command using the `docker` utility.

11. The Oracle RAC `Dockerfile` does not contain any Oracle software binaries. Download the following software from the [Oracle Technology Network](https://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html) and stage them under `<GITHUM_REPO_CLONED_PATH>/docker-images/OracleDatabase/RAC/OracleRACStorageServer/dockerfiles` folder.

* Oracle Database 21c Grid Infrastructure (21.3) for Linux x86-64
* Oracle Database 21c (21.3) for Linux x86-64

* Because Oracle RAC on Podman is supported on Release 21c (21.7) or later, you must download the grid release update (RU) from [support.oracle.com](https://support.oracle.com/portal/). In this case, we downloaded RU `34155589`.

* Download the following one-off patches for release 21.7 from [support.oracle.com](https://support.oracle.com/portal/)
  * `34339952`
  * `32869666`

12. If SELINUX is enabled on the Podman host, then you must create a RAC on Podman SELINUX policy. For details, refer to `How to Configure Podman for SELinux Mode` in the section [Real Application Clusters Installation Guide for Podman Oracle Linux x86-64](https://docs.oracle.com/en/database/oracle/oracle-database/21/install-and-upgrade.html) in Oracle RAC on Podman documentation.

### Notes

* If the Podman bridge network is not available outside your host, you can use the Oracle Connection Manager (CMAN) image to access the Oracle RAC Database from outside the host.

## Section 2: Building Oracle RAC Database Container Images

**IMPORTANT :** This section assumes that you have gone through all the prerequisites in Section 1 and completed all the steps, based on your environment. Do not uncompress the binaries and patches.

To assist in building the images, you can use the [`buildContainerImage.sh`](https://github.com/oracle/docker-images/blob/master/OracleDatabase/RAC/OracleRealApplicationClusters/dockerfiles/buildContainerImage.sh) script. See the following for instructions and usage.

* Before starting the next step, you must edit `docker-images/OracleDatabase/RAC/OracleRealApplicationClusters/dockerfiles/21.3.0/Dockerfile`, change `oraclelinux:7-slim` to `oraclelinux:8`, and save the file.

  ```bash
  ./buildContainerImage.sh -v <Software Version>
  #  for example ./buildContainerImage.sh -v 21.3.0
  ```

For detailed usage of the command, execute the following command:

  ```bash
  #  ./buildContainerImage.sh -h
  ```

* After the `21.3.0` Oracle RAC on Podman image is built, start building a patched image with the download 21.7 RU and one-offs. To build the patch image, refer [Example of how to create a patched database image](https://github.com/oracle/docker-images/tree/main/OracleDatabase/RAC/OracleRealApplicationClusters/samples/applypatch).

### Notes

* The resulting images will contain the Oracle Grid Infrastructure Binaries and Oracle RAC Database binaries.
* If you are behind a proxy wall, then you must set the `https_proxy` environment variable based on your environment before building the image.

## Section 3: Creating the Oracle Grid Infrastructure and Oracle RAC Container

All containers will share a host file for name resolution.  The shared host file must be available to all containers. Create the shared host file (if it doesn't exist) at `/opt/containers/rac_host_file`. 

For example:

  ```bash
  # mkdir /opt/containers
  # touch /opt/containers/rac_host_file
  ```

**Note:** Do not modify `/opt/containers/rac_host_file` from the host running Oracle Podman. It will be managed from within the containers.

If you are using the Oracle Connection Manager for accessing the Oracle RAC Database from outside the host, then you must add the following variable in the container creation command.

  ```bash
  -e CMAN_HOSTNAME=(CMAN_HOSTNAME) -e CMAN_IP=(CMAN_IP)
  ```

**Note:** You must replace `CMAN_HOSTNAME` and `CMAN_IP` with values based on your environment settings.

### Password management

Specify the secret volume for resetting the grid, oracle, and database password during node creation or node addition. The volume can be can be a shared volume among all the containers

  ```bash
  mkdir /opt/.secrets/
  openssl rand -hex -out /opt/.secrets/pwd.key
  ```

Edit the `/opt/.secrets/common_os_pwdfile` and seed the password for grid, oracle and database with the same password. Run the following commands:

  ```bash
  openssl enc -aes-256-cbc -salt -in /opt/.secrets/common_os_pwdfile -out /opt/.secrets/common_os_pwdfile.enc -pass file:/opt/.secrets/pwd.key
  rm -f /opt/.secrets/common_os_pwdfile
  chmod 400 /opt/.secrets/common_os_pwdfile.enc
  chmod 400 /opt/.secrets/pwd.key
  ```

### Notes

* If you want to specify different passwords for each of the accounts, then create three different files and encrypt them under `/opt/.secrets`.  Next, pass the file name to the container by using the `env` parameter. Environment variables are `ORACLE_PWD_FILE` for `oracle` user, `GRID_PWD_FILE` for `grid` user, and `DB_PWD_FILE` for the database password.
* If you want a common password for the `oracle`, `grid`, and `database` users, then assign a password file name to `COMMON_OS_PWD_FILE` environment variable.
* After the Oracle RAC environment setup is completed, you must change the `oracle`, `grid` and database passwords to meet any corporate or other requirements. Oracle strongly recommends that you follow security best practices.

### Prepare the envfile

To run Oracle RAC on Podman, you must create an envfile,  which will be mounted inside the container. For the details of environment variables, refer to `section 6`.  You must change the parameters as described in the following section, `Parameters need to be changed`, based on your environment . Save the file in `/opt/containers/envfile` on Podman host.

**Note**: If you are planning to use the `RAC Storage Container` for shared storage, then change following parameters in the `Parameters need to be changed` section: 

```bash
 export ASM_DISCOVERY_DIR=/oradata
 export ASM_DEVICE_LIST=/oradata/asm_disk01.img,/oradata/asm_disk02.img,/oradata/asm_disk03.img,/oradata/asm_disk04.img,/oradata/asm_disk05.img
```

#### Edit `/opt/containers/envfile` file and make required changes

```INI
 ### Parameters need to be changed###
 export HOSTNAME=racnode1 
 export DNS_SERVERS=172.16.1.25 
 export OP_TYPE=INSTALL 
 export COMMON_OS_PWD_FILE=common_os_pwdfile.enc 
 export ORACLE_SID=ORCLCDB 
 export NODE_VIP=172.16.1.160 
 export VIP_HOSTNAME=racnode1-vip 
 export PRIV_HOSTNAME=racnode1-priv 
 export SCAN_NAME=racnode-scan 
 export PWD_KEY=pwd.key 
 export PRIV_IP=192.168.17.150 
 export PUBLIC_HOSTNAME=racnode1 
 export DOMAIN=example.com 
 export CMAN_HOSTNAME=racnode-cman1 
 export CMAN_IP=172.16.1.15 
 export DEFAULT_GATEWAY=172.16.1.1 
 export PUBLIC_IP=172.16.1.150 
 export ASM_DEVICE_LIST=/dev/asm-disk1,/dev/asm-disk2 
 export ASM_DISCOVERY_DIR=/dev 

 #### DO Not Change Following #### 
 export PATH=/bin:/usr/bin:/sbin:/usr/sbin 
 export TERM=xterm 
 export ContainerType=RAC
 export SETUP_LINUX_FILE=setupLinuxEnv.sh
 export INSTALL_DIR=/opt/scripts
 export GRID_BASE=/u01/app/grid
 export GRID_HOME=/u01/app/21.3.0/grid
 export INSTALL_FILE_1=LINUX.X64_213000_grid_home.zip
 export GRID_INSTALL_RSP=gridsetup_21c.rsp
 export GRID_SW_INSTALL_RSP=grid_sw_install_21c.rsp
 export GRID_SETUP_FILE=setupGrid.sh
 export INSTALL_GRID_BINARIES_FILE=installGridBinaries.sh
 export INSTALL_GRID_PATCH=applyGridPatch.sh
 export INVENTORY=/u01/app/oraInventory
 export CONFIGGRID=configGrid.sh
 export ADDNODE=AddNode.sh
 export DELNODE=DelNode.sh
 export ADDNODE_RSP=grid_addnode_21c.rsp
 export SETUPSSH=setupSSH.expect
 export DOCKERORACLEINIT=dockeroracleinit
 export GRID_USER_HOME=/home/grid
 export SETUPGRIDENV=setupGridEnv.sh
 export RESET_OS_PASSWORD=resetOSPassword.sh
 export MULTI_NODE_INSTALL=MultiNodeInstall.py
 export DB_BASE=/u01/app/oracle
 export DB_HOME=/u01/app/oracle/product/21.3.0/dbhome_1
 export INSTALL_FILE_2=LINUX.X64_213000_db_home.zip
 export DB_INSTALL_RSP=db_sw_install_21c.rsp
 export DBCA_RSP=dbca_21c.rsp
 export DB_SETUP_FILE=setupDB.sh
 export PWD_FILE=setPassword.sh
 export RUN_FILE=runOracle.sh
 export STOP_FILE=stopOracle.sh
 export ENABLE_RAC_FILE=enableRAC.sh
 export CHECK_DB_FILE=checkDBStatus.sh
 export USER_SCRIPTS_FILE=runUserScripts.sh
 export REMOTE_LISTENER_FILE=remoteListener.sh
 export INSTALL_DB_BINARIES_FILE=installDBBinaries.sh
 export GRID_HOME_CLEANUP=GridHomeCleanup.sh
 export ORACLE_HOME_CLEANUP=OracleHomeCleanup.sh
 export FUNCTIONS=functions.sh
 export COMMON_SCRIPTS=/common_scripts
 export CHECK_SPACE_FILE=checkSpace.sh
 export RESET_FAILED_UNITS=resetFailedUnits.sh
 export SET_CRONTAB=setCrontab.sh
 export CRONTAB_ENTRY=crontabEntry
 export EXPECT=/usr/bin/expect
 export BIN=/usr/sbin
 export container=true
 export INSTALL_SCRIPTS=/opt/scripts/install
 export SCRIPT_DIR=/opt/scripts/startup
 export GRID_PATH=/u01/app/21.3.0/grid/bin:/u01/app/21.3.0/grid/OPatch/:/u01/app/21.3.0/grid/perl/bin:/usr/sbin:/bin:/sbin
 export DB_PATH=/u01/app/oracle/product/21.3.0/dbhome_1/bin:/u01/app/oracle/product/21.3.0/dbhome_1/OPatch/:/u01/app/oracle/product/21.3.0/dbhome_1/perl/bin:/usr/sbin:/bin:/sbin
 export GRID_LD_LIBRARY_PATH=/u01/app/21.3.0/grid/lib:/usr/lib:/lib
 export DB_LD_LIBRARY_PATH=/u01/app/oracle/product/21.3.0/dbhome_1/lib:/usr/lib:/lib
 export PATCH_DIR=patches
 export GRID_PATCH_FILE=applyGridPatches.sh
 export DB_PATCH_FILE=applyDBPatches.sh
 export FIXUP_PREQ_FILE=fixupPreq.sh
 export DB_USER=oracle
 export GRID_USER=grid
 export PATCH_INSTALL_DIR=/tmp/patches
 export HOME=/home/grid
```

### Deploying Oracle RAC on a Container with Block Devices

If you are using an NFS volume, then skip to the section "Deploying Oracle RAC on Container with NFS Volume".

Ensure the ASM devices do not have any existing file systems. To clear any other file system from the devices, use the following command:

  ```bash
  # dd if=/dev/zero of=/dev/xvde  bs=8k count=100000
  ```

Repeat for each shared block device. In the preceding example, `/dev/xvde` is a shared Xen virtual block device.

Now create the Oracle RAC container using the image. You can use the following example to create a container:

  ```bash
  # Podman create -t -i \
    --hostname racnode1 \
    --volume /boot:/boot:ro \
    --dns-search "example.com" \
    --dns 172.16.1.25 \
    --shm-size 4G \
    --device=/dev/xvdd:/dev/asm-disk1  \
    --device=/dev/xvde:/dev/asm-disk2 \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /opt/containers/envfile:/etc/rac_env_vars \
    --volume /opt/.secrets:/run/secrets:ro \
    --env ContainerType=RAC \
    --cpuset-cpus 0-1 \
    --memory 16G \
    --memory-swap 32G \
    --sysctl kernel.shmall=2097152  \
    --sysctl "kernel.sem=250 32000 100 128" \
    --sysctl kernel.shmmax=8589934592  \
    --sysctl kernel.shmmni=4096 \
    --cap-add=SYS_RESOURCE \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_NICE \
    --cap-add=AUDIT_WRITE \
    --cap-add=AUDIT_CONTROL \
    --restart=always \
    --cpu-rt-runtime=95000 \
    --ulimit rtprio=99  \
    --user 0 \
    --systemd=true \
    --name racnode1 \
   localhost/oracle/database-rac:21.3.0-21.7.0 "/usr/sbin/init"
  ```

**Note:**  Change environment variables such as `NODE_IP`, `PRIV_IP`, `PUBLIC_IP`,  `ASM_DEVICE_LIST`, `PWD_FILE`, and `PWD_KEY` based on your env in the envfile. Also, ensure you use the correct device names on each host.

### Deploying Oracle RAC on Container With Oracle RAC Storage Container

Create the Oracle RAC container using the image. You can use the following example to create a container:

  ```bash
  # 
 Podman create -t -i \
    --hostname racnode1 \
    --volume /boot:/boot:ro \
    --dns-search "example.com" \
    --dns 172.16.1.25 \
    --shm-size 4G \
    --device=/dev/xvdd:/dev/asm-disk1  \
    --device=/dev/xvde:/dev/asm-disk2 \
    --volume racstorage:/oradata \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /opt/containers/envfile:/etc/rac_env_vars \
    --volume /opt/.secrets:/run/secrets:ro \
    --env ContainerType=RAC \
    --cpuset-cpus 0-1 \
    --memory 16G \
    --memory-swap 32G \
    --sysctl kernel.shmall=2097152  \
    --sysctl "kernel.sem=250 32000 100 128" \
    --sysctl kernel.shmmax=8589934592  \
    --sysctl kernel.shmmni=4096 \
    --cap-add=SYS_RESOURCE \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_NICE \
    --cap-add=AUDIT_WRITE \
    --cap-add=AUDIT_CONTROL \
    --restart=always \
    --cpu-rt-runtime=95000 \
    --ulimit rtprio=99  \
    --user 0 \
    --systemd=true \
    --name racnode1 \
   localhost/oracle/database-rac:21.3.0-21.7.0 "/usr/sbin/init"
  ```

**Notes:**

* Change environment variables such as `NODE_IP`, `PRIV_IP`, `PUBLIC_IP`,  `ASM_DEVICE_LIST`, `PWD_FILE`, and `PWD_KEY`, based on your environment in the envfile. Also, ensure you use the correct device names on each host.
* Before creating the Oracle RAC Container, You must have created the `racstorage` volume. For details about the available environment variables, refer to section 6.

### Assign networks to Oracle RAC containers

Assign the networks created in section 1 to the containers by running the following commands:

  ```bash
  # Podman network disconnect Podman racnode1
  # Podman network connect rac_pub1_nw --ip 172.16.1.150 racnode1
  # Podman network connect rac_priv1_nw --ip 192.168.17.150  racnode1
  ```

### Start the first container

To start the first container, run the following command:

  ```bash
  # Podman start racnode1
  ```

It can take at least 40 minutes or longer to create the first node of the cluster. To check the logs, use the following command from another terminal session:

  ```bash
  # Podman exec racnode1 /bin/bash -c "tail -f /tmp/orod.log"
  ```

You should see the database creation success message at the end:

  ```text
  ####################################
  ORACLE RAC DATABASE IS READY TO USE!
  ####################################
  ```

### Connect to the Oracle RAC Container

To connect to the container execute the following command:

```bash
# Podman exec -i -t racnode1 /bin/bash
```

If the install fails for any reason, log in to the container using the preceding command and check `/tmp/orod.log`. You can also review the Grid Infrastructure logs located at `$GRID_BASE/diag/crs` and check for failure logs. If the failure occurred during the database creation then check the database logs.

## Section 4: Adding an Oracle RAC Node Using a Container

Before proceeding to the next step, ensure Oracle Grid Infrastructure is running and the Oracle RAC Database is open as per instructions in section 3. Otherwise, the node addition process will fail.

### Password Management

Specify the secret volume for resetting grid, oracle, and database passwords during node creation or node addition. It can be a shared volume among all the containers

```bash
mkdir /opt/.secrets/
openssl rand -hex -out /opt/.secrets/pwd.key
```

In this example, you edit the `/opt/.secrets/common_os_pwdfile` and seed the password for grid, oracle, and database users with the same password. Run the following command:

```bash
openssl enc -aes-256-cbc -salt -in /opt/.secrets/common_os_pwdfile -out /opt/.secrets/common_os_pwdfile.enc -pass file:/opt/.secrets/pwd.key
rm -f /opt/.secrets/common_os_pwdfile
```

### Notes

* If you want to specify different passwords for each of the accounts, then create three different files and encrypt them under `/opt/.secrets`. Next, pass the file name to the container using the following environment variables: `ORACLE_PWD_FILE` for the `oracle` user, `GRID_PWD_FILE` for the  `grid` user and `DB_PWD_FILE` for the database password.
* If you want a common password for the `oracle`, `grid`, and database users, then assign a single password file by using the `COMMON_OS_PWD_FILE` environment variable.

Reset the password on the existing Oracle RAC node for SSH setup between an existing node in the cluster and the new node. Password must be the same on all the nodes for the `grid` and `oracle` users. Execute the following command on an existing node of the cluster.

```bash
Podman exec -i -t -u root racnode1 /bin/bash
sh  /opt/scripts/startup/resetOSPassword.sh --help
sh /opt/scripts/startup/resetOSPassword.sh --op_type reset_grid_oracle --pwd_file common_os_pwdfile.enc --secret_volume /run/secrets --pwd_key_file pwd.key
```

**Note:** If you do not have a common secret volume among Oracle RAC containers, then populate the password file with the same password that you have used on the new node, encrypt the file, and run `resetOSPassword.sh` on the existing node of the cluster.

### Prepare the envfile

To perform the Oracle RAC node addition, you must create an envfile, which which will be mounted inside the container. For details about environment variables for node addition, refer to section 7.

**Note**: If you are planning to use `RAC Storage Container` for shared storage, then change following parameters in the `Parameters need to be changed` section as follows:

```bash
 export ASM_DISCOVERY_DIR=/oradata
 export ASM_DEVICE_LIST=/oradata/asm_disk01.img,/oradata/asm_disk02.img,/oradata/asm_disk03.img,/oradata/asm_disk04.img,/oradata/asm_disk05.img
```

Create `/opt/containers/envfile` as mentioned in section 3. You need to change only section `Parameters need to be changed` in `/opt/containers/envfile` based on node addition enviornment:

```INI
### Parameters need to be changed######
export HOSTNAME=racnode2
export DNS_SERVERS=172.16.1.25
export OP_TYPE=ADDNODE
export COMMON_OS_PWD_FILE=common_os_pwdfile.enc
export ORACLE_SID=ORCLCDB
export NODE_VIP=172.16.1.161
export VIP_HOSTNAME=racnode2-vip
export PRIV_HOSTNAME=racnode2-priv
export SCAN_NAME=racnode-scan
export PWD_KEY=pwd.key
export PRIV_IP=192.168.17.151
export PUBLIC_HOSTNAME=racnode2
export DOMAIN=example.com
export CMAN_HOSTNAME=racnode-cman1
export CMAN_IP=172.16.1.15
export DEFAULT_GATEWAY=172.16.1.1
export PUBLIC_IP=172.16.1.151
export ASM_DEVICE_LIST=/dev/asm-disk1,/dev/asm-disk2
export ASM_DISCOVERY_DIR=/dev
export EXISTING_CLS_NODES=racnode1
```

**Note**: Do not remove and edit the section `DO Not Change Following` in envfile `/opt/containers/envfile`.

### Deploying with Block Devices

If you are using an NFS volume, then skip to the section "Deploying with the Oracle RAC Storage Container".

To create additional nodes, use the following command:

```bash
 # Podman create -t -i \
   --hostname racnode2 \
   --volume /boot:/boot:ro \
   --dns-search "example.com" \
   --dns 172.16.1.25 \
   --shm-size 4G \
   --device=/dev/xvdd:/dev/asm-disk1  \
   --device=/dev/xvde:/dev/asm-disk2 \
   --volume /etc/localtime:/etc/localtime:ro \
   --volume /opt/containers/envfile:/etc/rac_env_vars \
   --volume /opt/.secrets:/run/secrets:ro \
   --env ContainerType=RAC \
   --cpuset-cpus 0-1 \
   --memory 16G \
   --memory-swap 32G \
   --sysctl kernel.shmall=2097152  \
   --sysctl "kernel.sem=250 32000 100 128" \
   --sysctl kernel.shmmax=8589934592  \
   --sysctl kernel.shmmni=4096 \
   --cap-add=SYS_RESOURCE \
   --cap-add=NET_ADMIN \
   --cap-add=SYS_NICE \
   --cap-add=AUDIT_WRITE \
   --cap-add=AUDIT_CONTROL \
   --restart=always \
   --cpu-rt-runtime=95000 \
   --ulimit rtprio=99  \
   --user 0 \
   --systemd=true \
   --name racnode2 \
   localhost/oracle/database-rac:21.3.0-21.7.0 "/usr/sbin/init"
```

For details of all environment variables and parameters, refer to section 6.

### Deploying Oracle RAC on Container with Oracle RAC Storage Container

If you are using physical block devices for shared storage, skip to "Assigning Network to additional Oracle RAC container"

Use the existing `racstorage:/oradata` volume when creating the additional container using the image.

For example:

```bash
  # Podman create -t -i \
    --hostname racnode2 \
    --volume /boot:/boot:ro \
    --dns-search "example.com" \
    --dns 172.16.1.25 \
    --shm-size 4G \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /opt/containers/envfile:/etc/rac_env_vars \
    --volume /opt/.secrets:/run/secrets:ro \
    --volume racstorage:/oradata \ 
    --env ContainerType=RAC \
    --cpuset-cpus 0-1 \
    --memory 16G \
    --memory-swap 32G \
    --sysctl kernel.shmall=2097152  \
    --sysctl "kernel.sem=250 32000 100 128" \
    --sysctl kernel.shmmax=8589934592  \
    --sysctl kernel.shmmni=4096 \
    --cap-add=SYS_RESOURCE \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_NICE \
    --cap-add=AUDIT_WRITE \
    --cap-add=AUDIT_CONTROL \
    --restart=always \
    --cpu-rt-runtime=95000 \
    --ulimit rtprio=99  \
    --user 0 \
    --systemd=true \
    --name racnode2 \
   localhost/oracle/database-rac:21.3.0-21.7.0 "/usr/sbin/init"
```

**Notes:**

* You must have created the **racstorage** volume before you  create the Oracle RAC container.
* You can change env variables such as IPs and ORACLE_PWD, based on your environment. For details about the environment variables, refer to section 6.

### Assign Networks to Additional Oracle RAC Container

Connect the private and public networks you created earlier to the container:

```bash
# Podman  network disconnect Podman racnode2
# Podman  network connect rac_pub1_nw --ip 172.16.1.151 racnode2
# Podman  network connect rac_priv1_nw --ip 192.168.17.151 racnode2
```

### Start Oracle RAC container

Start the container

```bash
# Podman start racnode2
```

To check the Database logs, tail the logs using the following command:

```bash
# Podman exec racnode2 /bin/bash -c "tail -f /tmp/orod.log"
```

You should see the database creation success message at the end.

```text
####################################
ORACLE RAC DATABASE IS READY TO USE!
####################################
```

### Connect to the Oracle RAC container

To connect to the container execute the following command:

```bash
# Podman exec -i -t racnode2 /bin/bash
```

If the node addition fails, log in to the container using the preceding command and review `/tmp/orod.log`. You can also review the Grid Infrastructure logs i.e. `$GRID_BASE/diag/crs` and check for failure logs. If the node creation has failed during the database creation process, then check DB logs.

## Section 5: Connecting to Oracle RAC Database

**IMPORTANT:** This section assumes that you have successfully created an Oracle RAC environment.

If you are using Connection Manager and exposed port 1521 on the host, connect from an external client using the following connection string:

```bash
system/<password>@//<podman_host>:1521/<ORACLE_SID>
```

If you are using a Podman `macvlan` network and you have configured DNS appropriately, you can connect using the public SCAN listener directly from any external client using the following connection string:

```bash
system/<password>@//<scan_name>:1521/<ORACLE_SID>
```

## Section 6: Environment Variables for the first node

**IMPORTANT:** This section provides details about the environment variables that can be used when creating the first node of a cluster.

Parameters:

```bash
OP_TYPE=###Specify the Operation TYPE. It can accept 2 values INSTALL OR ADDNODE####
NODE_VIP=####Specify the Node VIP###
VIP_HOSTNAME=###Specify the VIP hostname###
PRIV_IP=###Specify the Private IP###
PRIV_HOSTNAME=###Specify the Private Hostname###
PUBLIC_IP=###Specify the public IP###
PUBLIC_HOSTNAME=###Specify the public hostname###
SCAN_NAME=###Specify the scan name###
ASM_DEVICE_LIST=###Specify the ASM Disk lists.
SCAN_IP=###Specify this if you do not have DNS server###
DOMAIN=###Default value set to example.com###
PASSWORD=###OS password will be generated by openssl###
CLUSTER_NAME=###Default value set to racnode-c####
ORACLE_SID=###Default value set to ORCLCDB###
ORACLE_PDB=###Default value set to ORCLPDB###
ORACLE_PWD=###Default value set to generated by openssl random password###
ORACLE_CHARACTERSET=###Default value set AL32UTF8###
DEFAULT_GATEWAY=###Default gateway. You need this env variable if containers will be running on multiple hosts.####
CMAN_HOSTNAME=###Connection Manager Host Name###
CMAN_IP=###Connection manager Host IP###
ASM_DISCOVERY_DIR=####ASM disk location insdie the container. By default it is /dev######
COMMON_OS_PWD_FILE=###Pass the file name to setup grid and oracle user password. If you specify ORACLE_PWD_FILE, GRID_PWD_FILE and DB_PWD_FILE then you do not need to specify this env variable###
ORACLE_PWD_FILE=###Pass the file name to set the password for oracle user.###
GRID_PWD_FILE=###Pass the file name to set the password for grid user.###
DB_PWD_FILE=###Pass the file name to set the password for DB user i.e. sys.###
REMOVE_OS_PWD_FILES=###Set this env variable to true to remove pwd key file and password file after resetting the password.###
CONTAINER_DB_FLAG=###Default value is set to true to create container database. Set this to false if you do not want to create a container database.###
```

## Section 7: Environment Variables for the second and subsequent nodes

**IMPORTANT:** This section provides the details about the environment variables that can be used for all additional nodes added to an existing cluster.

```bash
OP_TYPE=###Specify the Operation TYPE. It can accept 2 values INSTALL OR ADDNODE###
EXISTING_CLS_NODES=###Specify the Existing Node of the cluster which you want to join.If you have 2 node in the cluster and you are trying to add third node then spcify existing 2 nodes of the clusters and separate them by comma.####
NODE_VIP=###Specify the Node VIP###
VIP_HOSTNAME=###Specify the VIP hostname###
PRIV_IP=###Specify the Private IP###
PRIV_HOSTNAME=###Specify the Private Hostname###
PUBLIC_IP=###Specify the public IP###
PUBLIC_HOSTNAME=###Specify the public hostname###
SCAN_NAME=###Specify the scan name###
SCAN_IP=###Specify this if you do not have DNS server###
ASM_DEVICE_LIST=###Specify the ASM Disk lists.
DOMAIN=###Default value set to example.com###
ORACLE_SID=###Default value set to ORCLCDB###
DEFAULT_GATEWAY=###Default gateway. You need this env variable if containers will be running on multiple hosts.####
CMAN_HOSTNAME=###Connection Manager Host Name###
CMAN_IP=###Connection manager Host IP###
ASM_DISCOVERY_DIR=####ASM disk location insdie the container. By default it is /dev######
COMMON_OS_PWD_FILE=###You need to pass the file name to setup grid and oracle user password. If you specify ORACLE_PWD_FILE, GRID_PWD_FILE and DB_PWD_FILE then you do not need to specify this env variable###
ORACLE_PWD_FILE=###You need to pass the file name to set the password for oracle user.###
GRID_PWD_FILE=###You need to pass the file name to set the password for grid user.###
DB_PWD_FILE=###You need to pass the file name to set the password for DB user i.e. sys.###
REMOVE_OS_PWD_FILES=###You need to set this to true to remove pwd key file and password file after resetting password.###
```

## Sample Container Files for Older Releases

This project offers sample container files for Oracle Grid Infrastructure and Oracle Real Application Clusters for dev and test:

* Oracle Database 19c Oracle Grid Infrastructure (19.3) for Linux x86-64
* Oracle Database 19c (19.3) for Linux x86-64
  

 **Notes:**

* Because Oracle RAC on Podman is supported on 19c from 19.16 or later, you must download the grid release update (RU) from [support.oracle.com](https://support.oracle.com/portal/). In this case, we downloaded RU `34130714`.
* Download following one-offs for 19.16 from [support.oracle.com](https://support.oracle.com/portal/)
  * `34339952`
  * `32869666`
* Before starting the next step, you must  move `docker-images/OracleDatabase/RAC/OracleRealApplicationClusters/dockerfiles/19.3.0/Dockerfile` to `docker-images/OracleDatabase/RAC/OracleRealApplicationClusters/dockerfiles/19.3.0/Dockerfile`.
* You must add `CV_ASSUME_DISTID=OEL8` inside the `Dockerfile` as an env variable.

* Once the `19.3.0` Oracle RAC on Podman image is built, start building patched image with the download 19.16 RU and one-offs. To build the patch the image, refer `[Example of how to create a patched database image](https://github.com/oracle/docker-images/tree/main/OracleDatabase/RAC/OracleRealApplicationClusters/samples/applypatch)`.

## Section 9 : Support

At the time of this release, Oracle RAC on Podman is supported for Oracle Linux 8.5 later. To see current Linux support certifications, refer [Oracle RAC on Podman Documentation](https://support.oracle.com/portal/)

## Section 10 : License

To download and run Oracle Grid and Database, regardless of whether inside or outside a container, you must download the binaries from the Oracle website and accept the license indicated on that page.

All scripts and files hosted in this repository which are required to build the container  images are, unless otherwise noted, released under UPL 1.0 license.

## Section 11 : Copyright

Copyright (c) 2014-2022 Oracle and/or its affiliates.
