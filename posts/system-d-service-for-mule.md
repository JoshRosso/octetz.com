# systemd Service for Mule

[ [WTFP License](http://www.wtfpl.net) | [Improve this reference](http://github.com/joshrosso/octetz.com) | [View all references](../index.html) ]

---

This article describes setting up a [systemd](https://www.freedesktop.org/wiki/Software/systemd/) service unit to control Mule instances. This is not an exhaustive systemd guide, rather a reference to get started.

## Why systemd for controlling Mule

It's rare I find teams using systemd to control their Mule instances. I often find groups using [sysVinit](https://en.wikipedia.org/wiki/Init#SYSV) or starting the Mule process manually by running `$MULE_HOME/bin/mule`. Scary, I know! 

Considering [most distros are focusing on or fully migrated to systemd](https://en.wikipedia.org/wiki/Systemd#Adoption_and_reception), this guide details setting up Mule for use with systemd. If systemd and init systems are new to you, consider a few of the following benefits to gain.

- Ensure consistency in how Mule starts
- Define dependencies on Mule's ability to start
- Define a Mule instance's available resource footprint
- Run Mule on events such as system startup, timers, or socket connections

## Prepare the Mule instance

To start, you'll need a Mule standalone instance. The community Mule instance can be downloaded from the [MuleSoft Nexus Repository](https://repository-master.mulesoft.org/nexus/content/repositories/public/org/mule/distributions/mule-standalone/). The following command downloads the runtime and places it in `/opt`.

```bash
curl -o \
  ~/Downloads/mule-3.8.1.tar.gz \
  https://repository-master.mulesoft.org/nexus/content/repositories/public/org/mule/distributions/mule-standalone/3.8.1/mule-standalone-3.8.1.tar.gz > ~/Downloads/mule-standalone-3.8.1.tar.gz && \
tar xf ~/Downloads/mule-3.8.1.tar.gz -C /opt
```
Once Mule is downloaded, [verify it starts successfully](https://docs.mulesoft.com/mule-user-guide/v/3.7/starting-and-stopping-mule-esb). After you've verified the server starts, ensure it is shutdown.

```
**********************************************************************
*              - - + DOMAIN + - -               * - - + STATUS + - - *
**********************************************************************
* default                                       * DEPLOYED           *
**********************************************************************
```

Create a service user responsible for running Mule. This user will not have a home directory, be unable to login, and not have access to a shell.


```
useradd -M mule --shell /bin/false
usermode -L mule
```

Give ownership of the Mule directory to the new user.

```
chown -R mule:mule /opt/mule-standalone-3.8.1
```

## Create a Mule unit file

Create a file named `mule.service` in `/etc/systemd/system`. Details on unit file locations can be found [here](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#Unit File Load Path).

```
touch /etc/systemd/system/mule.service
```

Add a [[Unit] section](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#[Unit] Section Options) with details around the Mule service.

```
[Unit]
Description=Mule Runtime 3.8.1
Documentation=https://docs.mulesoft.com
```

Add a [[Service] section](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#[Unit] Section Options) providing instructions on how to start, stop, and reload (restart) Mule. We'll also set the [service type](https://www.freedesktop.org/software/systemd/man/systemd.service.html#Options) to `forking` so Mule doesn't capture systemd's [SIGTERM](http://www.gnu.org/software/libc/manual/html_node/Termination-Signals.html) and kill itself. Lastly, specify the service user who should own the Mule processes.

```
[Service]
Type=forking
User=mule
ExecStart=/opt/mule-standalone-3.8.1/bin/mule start
ExecStop=/opt/mule-standalone-3.8.1/bin/mule stop
ExecReload=/opt/mule-standalone-3.8.1/bin/mule restart
```

Add an [[Install] section](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#%5BInstall%5D%20Section%20Options) used later in enabling Mule to run at system startup. Set the WantedBy target to [multi-user.target to ensure startup occurs during set up of the system](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/sect-Managing_Services_with_systemd-Targets.html).

```
[Install]
WantedBy=multi-user.target
```

## Controlling Mule with systemctl

[systemctl](https://www.freedesktop.org/software/systemd/man/systemctl.html) controls the systemd system and service manager. It allows us to control the Mule instance along with alter its behavior.

First, make sure the systemctl daemon is reloaded with our newest unit file.

```
systemctl daemon-reload
```

Start the Mule instance through systemctl.

```
systemctl start mule
```

After the startup completes, check the status of the running Mule service.

```
systemctl status mule
```

From here, we can see the [slice](https://www.freedesktop.org/software/systemd/man/systemd.slice.html) owning the group of processes. Specifically, in the output below, the [wrapper](http://wrapper.tanukisoftware.com/doc/english/properties.html) process can be seen as `3696` and the Mule process, run from the wrapper, is `3698`.

```
mule.service - Mule Runtime 3.8.1.
   Loaded: loaded (/etc/systemd/system/mule.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2016-10-12 08:31:11 PDT; 29s ago
     Docs: https://docs.mulesoft.com
  Process: 3471 ExecStop=/opt/mule-standalone-3.8.1/bin/mule stop (code=exited, status=0/SUCCESS)
  Process: 3629 ExecStart=/opt/mule-standalone-3.8.1/bin/mule start (code=exited, status=0/SUCCESS)
 Main PID: 3696 (wrapper-linux-x)
    Tasks: 26 (limit: 4915)
      CPU: 24.120s
   CGroup: /system.slice/mule.service
           |-3696 /opt/mule-standalone-3.8.1/lib/boot/exec/wrapper-linux-x86-64 /opt/mule-standalone-3.8.1/conf/wra
           |-3698 java -Dmule.home=/opt/mule-standalone-3.8.1 -Dmule.base=/opt/mule-standalone-3.8.1 -Djava.net.pre

Oct 12 08:30:52 node0 systemd[1]: Starting Mule Runtime 3.8.0...
Oct 12 08:30:52 node0 mule[3629]: MULE_HOME is set to /opt/mule-standalone-3.8.1
Oct 12 08:31:10 node0 mule[3629]: Starting Mule...
Oct 12 08:31:11 node0 systemd[1]: Started Mule Runtime 3.8.0.`
```

Stop the Mule instance and check its status again.

```
systemctl stop mule
systemctl status mule
```

To run Mule during system startup, enable the unit.

```
systemctl enable mule
```

This creates a symlink in `/etc/systemd/system/multi-user.wants` ensuring when the `multi-user.target` starts up, Mule does as well. Restart the machine as desired and check the status of Mule once logged in.

## Expanding systemd's control

systemd provides tons of configuration options from here. We can automate when Mule starts. For example, when a socket connection is opened or on a timer. We can also limit the resource footprint available to ththeule process. In this final section, we'll modify a few simple parameters and see the service impact based on some systemd tooling.

To alter the existing unit, use `systemctl edit`. The `--full` flag edits the unit directly, rather than the default which is to create an [override file](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#id-1.11.3). Note the edtior used to alter the file is defined by what resolves as `$SYSTEMD_EDITOR` or `$EDITOR`. Alternatively, you can alter the `.service` file directly. However, that method requires reloading the systemctl daemon for changes to be seen.

```
systemctl edit mule.service --full
```

Limit the Mule process to half the capacity of a single core by setting [CPUQuota](https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#CPUQuota=) to `50%` under the `[Service]` section.

```
CPUQuota=50%
```

Start the Mule service again using `systemctl start mule`. During startup, run [systemd-cgtop](https://www.freedesktop.org/software/systemd/man/systemd-cgtop.html) in order to see the resource usage of top control groups. 

```
systemctl-cgtop
```

In the cgtop output, the Mule service is limiting itself to 50% of CPU. This applies to the mule.serivce slice, which contains both the Java Service Wrapper and Mule. To allow Mule to span multiple cores, set the [CPUQuota](https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#CPUQuota=) to a value greater than `100%`.

```
Control Group                        Tasks   %CPU   Memory
/                                        -   57.8     3.2G
/system.slice                           48   49.4     1.1G
/system.slice/mule.service              26   49.4     1.1G
/user.slice                            169    7.9        -
/init.scope                              1      -     2.5M
/system.slice/NetworkManager.service     3      -   160.0K
/system.slice/dbus.service               1      -   160.0K
```

In the `[Service]` section of the Mule unit file, set the [MemoryMax](https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#MemoryMax=bytes) to `5M`. In the same section, let's set a [TimeoutSec](https://www.freedesktop.org/software/systemd/man/systemd.service.html#TimeoutSec=) of `15`, ensuring if Mule doesn't signal start-up completion in that time, the service will be shutdown. Additionally, if Mule is requested to stop and doesn't complete in 15 seconds, a [SIGKILL](http://www.gnu.org/software/libc/manual/html_node/Termination-Signals.html) will be sent to the process.

```
MemoryMax=5M
TimeoutSec=15
```

Stop and start the Mule service and using cgtop, observe Mule is now limited to 5MB of Memory.

```
Control Group              Tasks   %CPU   Memory
/                              -   51.8     2.1G
/system.slice                 39   36.6     8.9M
/system.slice/mule.service    17   36.6     4.9M
```

After 15 seconds, it should also be reported that Mule failed to start.

```
Job for mule.service failed because a timeout was exceeded.
See "systemctl status mule.service" and "journalctl -xe" for details.
```

Use [journalctl](https://www.freedesktop.org/software/systemd/man/journalctl.html) to get insight on what happened with the process. Specifically, use `-xe` to get details at the page end of the journal and `-u mule` to limit the result to the Mule unit.

```
journalctl -xe -u mule
```

The journal output will reiterate the root cause of failure, which was timeout.

```
Oct 12 16:44:06 node0 systemd[1]: Starting Mule Runtime 3.8.0...
-- Subject: Unit mule.service has begun start-up
-- Defined-By: systemd
-- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel
-- 
-- Unit mule.service has begun starting up.
Oct 12 16:44:07 node0 mule[12358]: MULE_HOME is set to /opt/mule-standalone-3.
Oct 12 16:44:21 node0 systemd[1]: mule.service: Start operation timed out. Ter
Oct 12 16:44:21 node0 systemd[1]: Failed to start Mule Runtime 3.8.0.
-- Subject: Unit mule.service has failed
-- Defined-By: systemd
-- Support: http://lists.freedesktop.org/mailman/listinfo/systemd-devel
-- 
-- Unit mule.service has failed.
-- 
-- The result is failed.
Oct 12 16:44:21 node0 systemd[1]: mule.service: Unit entered failed state.
Oct 12 16:44:21 node0 systemd[1]: mule.service: Failed with result 'timeout'
```

There are many more [resource-related options](https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#) to explore and [many other directives](https://www.freedesktop.org/software/systemd/man/index.html) providing granular control over Mule process(s). You can view the final unit file, with more sensible values, at TODO:GITHUBLINKHERE

---

*Last updated: 10/13/2016*

[ [WTFP License](http://www.wtfpl.net) | [Improve this reference](http://github.com/joshrosso/octetz.com) | [View all references](../index.html) ]
