# Arch Linux Package Management: What you need to know

[ [WTFP License](http://www.wtfpl.net) | [Improve this reference](http://github.com/joshrosso/octetz.com) | [View all references](../index.html) ]

---

## Motivation

Last week I helped my roommate setup Arch Linux as his first Linux desktop. Explaining the various facets of package management brought me back to when I'd first learned Arch and was discovering the use of pacman, AUR, yaourt, and more. While there's no shortage of great documentation around all these topics, I felt a clean overview of key concepts critical to a new user would have made both of our lives easier.

## pacman

[pacman](https://wiki.archlinux.org/index.php/pacman) is Arch's package manager. Like any good package manager, it provides a consistent interface for downloading, installing, updating, and removing software on your system. It's generally considered best practice to ensure all software is managed by this single utility.

## Official repositories

Throughout your Arch journey, you'll be installing common packages used by much of the Arch user base. Packages like `openssl`, `go`, and `nginx` are all readily available in the official repository. However, when you get to more specific packages, e.g. `intellij` and `matlab`, you'll need to look outside of the official repository, which will be covered later in this post.

Start by printing the `pacman` help options; get aquainted.

```bash
$ pacman -h

usage:  pacman <operation> [...]
operations:
    pacman {-h --help}
    pacman {-V --version}
    pacman {-D --database} <options> <package(s)>
    pacman {-F --files}    [options] [package(s)]
    pacman {-Q --query}    [options] [package(s)]
    pacman {-R --remove}   [options] <package(s)>
    pacman {-S --sync}     [options] [package(s)]
    pacman {-T --deptest}  [options] [package(s)]
    pacman {-U --upgrade}  [options] <file(s)>

use 'pacman {-h --help}' with an operation for available options
```

Next you'll update your local package database. `pacman` uses this database to know what repositories are available to search. Updating is not always required, but should be done every so often or after sytem upgrades. We'll use the `-S` flag representing a Sync operation. You'll also add a `-y` flag instructing that a new copy of the master package database is downloaded. You'll find a similar result can be achieved with the `-D` database operation, but you may find this appraoch convienent as it can ensure the database is upgraded and a package is installed via a single operation. 

```
$ pacman -Sy

:: Synchronizing package databases...
 core              123.2 KiB   188K/s  00:01 [###############################################] 100%
 extra             1722.0 KiB  1594K/s 00:01 [###############################################] 100%
 community         3.7 MiB     14.1M/s 00:00 [###############################################] 100%
 multilib-testing  1630.0B     0.00B/s 00:00 [###############################################] 100%
 multilib          185.9 KiB   30.3M/s 00:00 [###############################################] 100% 
```
> Each line represents an official repository that has been syncronized. Details on each official repository above can be found at https://wiki.archlinux.org/index.php/official_repositories.

Now you can install a package. Discovering whether a package is available can be done through `pacman` or through Arch package search at https://www.archlinux.org/packages. Let's search for the [sipcalc](http://www.routemeister.net/projects/sipcalc) package, used to calculate subnets. Using pacman you can add the `-s` flag, representing search, to the -S sync operation.

```
$ pacman -Ss sipcalc

community/sipcalc 1.1.6-2
    an advanced console based ip subnet calculator.
```

<img src="imgs/arch-pkg-search-sipcalc.png" width="600">

> Equivelent search via the Arch package search.

Since the package is available, let's now install it using the `-S` Sync operation.

```bash
$ pacman -S sipcalc

resolving dependencies...
looking for conflicting packages...

Packages (1) sipcalc-1.1.6-2

Total Installed Size:  0.05 MiB

:: Proceed with installation? [Y/n] Y
(1/1) checking keys in keyring                                                    [###############################################] 100%
(1/1) checking package integrity                                                  [###############################################] 100%
(1/1) loading package files                                                       [###############################################] 100%
(1/1) checking for file conflicts                                                 [###############################################] 100%
(1/1) checking available disk space                                               [###############################################] 100%
:: Processing package changes...
(1/1) installing sipcalc                                                          [###############################################] 100%
```

> Based on the output, `pacman` not only installs the package, but also ensures any depenencies needed are downloaded and that no conflicting packages exist before installation.

Now `sipcalc` is installed and managed by `pacman`! You are now able to run the binary.

```
$ sipcalc 10.0.0.0/24

-[ipv4 : 10.0.0.0/24] - 0

[CIDR]
Host address    - 10.0.0.0
Host address (decimal)  - 167772160
Host address (hex)  - A000000
Network address   - 10.0.0.0
Network mask    - 255.255.255.0
Network mask (bits) - 24
Network mask (hex)  - FFFFFF00
Broadcast address - 10.0.0.255
Cisco wildcard    - 0.0.0.255
Addresses in network  - 256
Network range   - 10.0.0.0 - 10.0.0.255
Usable range    - 10.0.0.1 - 10.0.0.254
-
```

## What's next

Once you're groking these key ideas and looking to dive deeper, consider the following resources that go in greater depth around Arch package management with pacman.

- [Digital Ocean: How to Use Arch Linux Package Management](https://www.digitalocean.com/community/tutorials/how-to-use-arch-linux-package-management)
  - A deeper dive walkthrough of pacman usage.
- [Digital Ocean: How To Use Yaourt to Easily Download Arch Linux Community Packages](https://www.digitalocean.com/community/tutorials/how-to-use-yaourt-to-easily-download-arch-linux-community-packages)
  - A deeper dive walkthrough of yaourt usage for working with packages from the Arch User Repository.


---

*Last updated: 10/13/2016*

[ [WTFP License](http://www.wtfpl.net) | [Improve this reference](http://github.com/joshrosso/octetz.com) | [View all references](../index.html) ]
