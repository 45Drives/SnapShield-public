# FAQ

This page is for anyone evaluating or running SnapShield. It gives short answers to common questions and links to the full guides.

## General

**What does SnapShield protect?**
Samba (SMB) file shares on Linux file servers. It scores file activity, watches decoy honey-files, and can ban the client IP address behind an attack. Snapshots let you restore affected files.

**Do I need to install anything on client computers?**
No. SnapShield runs only on the file server.

**Which filesystems are supported?**
ZFS, Ceph and Cephadm-managed Ceph. You choose one during setup.

**Which operating systems are supported?**
See [Installation](installation.md).

**Does SnapShield need snapshots?**
Yes. Snapshots are SnapShield's reference copy for scoring files and restoring them. See [Getting started](getting-started.md#3-make-sure-snapshots-exist).

**What's the difference between "ban" and "report"?**
In **ban** mode, a serious detection creates an event and bans the client's IP address. In **report** mode it only creates an event. You choose this during setup, and can change it by running **Manage → Setup / change installation** again.

**What's the difference between an Alert and a Warning event?**
Warning thresholds only create an event. Alert (upper-limit) thresholds create an event and trigger a ban, unless you're in report mode.

**Will a fire drill harm my data?**
The **Test Bench** fire drill works in its own new folder on the share and runs from a container with its own IP address, so SnapShield bans the container and not your server. Click **Cleanup** when you're done.

## Access and accounts

**Is my Cockpit login the same as my SnapShield login?**
No. Cockpit and SnapShield have separate logins. Sign in to Cockpit first, then sign in to the SnapShield dashboard with the UI account you created during setup.

**Why do I need "Administrative access" in Cockpit?**
Setup, package checks and **Connection settings** change system configuration. Cockpit only allows that with **Administrative access** turned on. Day-to-day use of the dashboard doesn't need it.

**Why can only one admin sign in?**
In Community, only the primary admin can sign in to the dashboard. Multiple admins need Enterprise. See [Licensing](licensing.md).

**Which ports does SnapShield use?**

| Port | Used by |
|------|---------|
| 9090 | Cockpit |
| 45677 | SnapShield standalone dashboard |
| 43678 | SnapShield API (used by the Control Panel) |
| 9045 | Control Panel standalone interface |

## Control Panel

**Do I need the Control Panel?**
No. Each SnapShield server has its own dashboard. The Control Panel is for managing several servers from one place.

**Does the Control Panel need a license?**
No. But each server you manage through it must be on Enterprise. See [Control Panel guide](control-panel.md).

**Does the Control Panel have to run on a SnapShield server?**
No. It can run on one of your SnapShield servers or on a separate host.

## Licensing

**What happens when my trial or subscription expires?**
The server moves to Community. Protection, recovery of visible events, email alerts, allowlists and fire drills keep working. Your settings are kept. See [Licensing](licensing.md#what-happens-in-community).

**Does reinstalling restart my trial?**
No. A trial never restarts, whether you reinstall, re-import or move it.

**Does SnapShield stop working if it can't reach the license server?**
No. A valid license keeps working offline and keeps its expiry date.

**I replaced a server. Do I need the old one to move its license?**
No. You only need the new server's activation request. See [Move a license](licensing.md#move-a-license-to-a-replacement-server).

## Help

**Where can I ask a question?**
On the [45HomeLab Forum](https://forum.45homelab.com/), where other users and the 45Drives team can help. Enterprise customers can also email [info@45drives.com](mailto:info@45drives.com).

**How do I report a bug or ask for a feature?**
[Open an issue](https://github.com/45Drives/SnapShield-public/issues/new/choose). For problems, check [Troubleshooting](troubleshooting.md) first.
