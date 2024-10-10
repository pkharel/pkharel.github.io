---
title: ZFS on external JBOD HDD enclosure
slug: zfs
date: "2024-05-03T00:00:00Z"
tags:
- zfs
- external hdd enclosure
- jbod
- das
- nas
---

## Overview
I've been using a WD 8TB external desktop drive for storage on my server. I'm
starting to run out of space so wanted to upgrade the storage.

# NAS vs DAS vs JBOD
I was initially consdering getting a Network Attached Storage (NAS). My
understanding is that it's basically a low powered computer with a bunch of hard
disks on it. It connects directly to the network so is easily accessible by all
devices in the same network. It also supports features like hardware RAID etc.
It seemed like it would have been the simplest to set up but also the most
expensive. 

Eventually decided against it because of cost. Also seemed a bit redundant since
the server I have right now is pretty much a NAS.

My second option was a Direct Attached Storage (DAS). This is similar to a NAS
but connects to a computer directly (via something like USB) instead of to the
network. Pros are that it's cheaper than a NAS. Cons are it has fewer features,
not directly accessible via devices in the network etc. It still has features
like hardware RAID etc depending on the company that makes it. 

I didn't go with a DAS because it's still more expensive. I don't really care
about the hardware RAID features.

JBOD (Just a Bunch Of Disks) is like a DAS where you put in a bunch of HDDs and
connect it to a computer. The computer should recognize the disks individually.
No features like hardware RAID etc and the enclosure itself is very cheap.

This is the option I went with since I don't really care about the extra
features of a NAS/DAS. I did read up on these enclosures online and the
consensus seemed to be that reliability is an issue. Since the data I'm working
with isn't too important, I thought it'd be a fun way to experiment.

# LVM vs ZFS
Once I'd settled on the JBOD option, I had to figure out a good filesystem and
volume manager. In my previous setup (single external USB drive), this wasn't
really an issue since I just formatted it with Ext4. With the new setup, I'd
have a bunch of external HDDs that I could ideally "pool" into a single storage
unit. There are a bunch of file systems / volume managers that do this like LVM,
ZFS, Btrfs etc.

[Logial Volume Manager
(LVM)](https://en.wikipedia.org/wiki/Logical_Volume_Manager_(Linux)) does just
that for Linux. With LVM you can do stuff like create a single logical volume
with a bunch of various physical disks. This seemed like the easiest option.

[ZFS](https://en.wikipedia.org/wiki/ZFS) was the other option. It seemed like
ZFS is something that's mostly usful for managing long term storage of data in a
large scale. The focus also seemd to be on making sure data integrity is
preserved.

ZFS seemed pretty overkill for my server since the data isn't that important but
I wanted to experiment with ZFS and it's various features so I went with that.
Drawbacks of ZFS was mostly a lack of flexibility which I guess is a trade-off
for resilience. It looks like the best setup for ZFS is a bunch of drives where
all of them have the same capacity. The total usable capacity in my case
(mirrored) was just 50%. 

# Setting up ZFS on an external JBOD enclosure
Setting up ZFS was very easy on Ubuntu 22.04 server. I mostly followed the
[Oracle
docs](https://docs.oracle.com/cd/E19253-01/819-5461/6n7ht6qug/index.html) which
are very comprehensive. There are a bunch of other ZFS guides online too. 

I setup ZFS on a cheap 4 bay HDD enclosure with 2 HDDs. First, I had to install
ZFS
```
sudo apt install zfsutils-linux
```
ZFS has a concept of "pools" so the next step is to create a new pool with the
two drives. I set up a mirrored pool where I have 2 drives with the contents on
one drive mirrored on the other drive. I have 2 x 16 TB drives so I'll only have
16 TB of usable storage.

Next, we have to figure out which drives to add to the pool
```
fdisk -l
```
This is a very important step since we want to make sure the devices we're using
`sda`, `sdb` etc is the correct one. To avoid this confusion, you can use
/dev/disk/by-id/ files instead

```
sudo zpool create -o ashift=12 -m /mnt/data zpool01 mirror /dev/disk/by-id/<hdd1> /dev/disk/by-id/<hdd2>
```
This command with create a new mirrored ZFS pool `zpool01` with the two HDDs
<hdd1> and <hdd2>. The `ashift` parameter is to math the HDD physical sector
size (12 = 4096 bytes). Other online guides seem to recommend setting this value
manually. The `-m /media/data` means ZFS will automount the drive to that
location.

ZFS also has the option of automatically compressing any data you write to HDD.
It uses `lz4` by default which adds a small overhead to writes on HDD but is
recommended. You can enable compression with
```
zfs set compress=lz4 zpool01
```
