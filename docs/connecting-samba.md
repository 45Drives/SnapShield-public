# Connecting Samba

This guide is for administrators connecting their Samba shares to SnapShield. It covers the SnapShield Samba module, protecting a share, and checking that SnapShield is receiving file activity.

## How SnapShield sees file activity

SnapShield watches your shares through a Samba **VFS module** called `snapshield`. When a client opens a protected share, Samba loads the module for that session, and the module sends every file operation to SnapShield's detection service on the same server.

A share is protected only when both are true:

1. The SnapShield module is installed in Samba.
2. The share's settings load it with `vfs objects = snapshield`.

Shares without the module still work normally — SnapShield just doesn't see them.

## Step 1: Use the 45Drives Samba build

The SnapShield module is built for the 45Drives build of Samba and must match its exact version. Samba from your operating system's own repositories does not include it.

The setup wizard installs the module for you, as part of the SnapShield packages:

| Operating system | Package that provides the module | Module file |
|---|---|---|
| Ubuntu | `samba-vfs-modules` from the 45Drives repository | `/usr/lib/x86_64-linux-gnu/samba/vfs/snapshield.so` |
| Rocky Linux / RHEL | `samba-vfs-snapshield` | `/usr/lib64/samba/vfs/snapshield.so` |

Installing it moves Samba to the matching 45Drives build if needed. If Samba isn't installed yet, install it after running [`setup.sh`](installation.md#step-1-run-the-setup-script), so it comes from the 45Drives repository:

```bash
# Ubuntu
sudo apt-get install samba

# Rocky Linux / RHEL
sudo dnf install samba
```

To check which Samba you have and where its modules live:

```bash
smbd -V
smbd -b | grep MODULESDIR
```

The `snapshield.so` file should be in the `vfs` folder under `MODULESDIR`.

## Step 2: Protect a share

Add `snapshield` to the share's `vfs objects`.

### In Houston

1. Open **Samba File Sharing** and edit the share.
2. Under **Advanced Settings**, add:

   ```ini
   vfs objects = snapshield
   ```

3. Save.

### In `smb.conf`

Add the line to the share's section in `/etc/samba/smb.conf`:

```ini
[projects]
   path = /tank/projects
   read only = no
   vfs objects = snapshield
```

If the share already has a `vfs objects` line, add `snapshield` to it rather than adding a second line:

```ini
   vfs objects = fruit streams_xattr snapshield
```

### Protecting every share

A `vfs objects` line in `[global]` applies to every share that doesn't set its own:

```ini
[global]
   vfs objects = snapshield
```

A share with its own `vfs objects` line ignores the global one, so add `snapshield` to that share's line as well.

### Apply the change

Check the configuration and tell Samba to reload it:

```bash
testparm -s
sudo smbcontrol all reload-config
```

Samba loads the module when a client connects to the share. Clients that were already connected start being watched the next time they reconnect — disconnect and reconnect the share, or sign the user out and back in.

## Step 3: Check the connection

Open the SnapShield dashboard. The **Samba Connection** card on the **Overview** page shows whether everything is connected. It refreshes every 15 seconds.

The badge at the top summarizes the most important problem:

| Badge | Meaning | What to do |
|---|---|---|
| **N of N shares protected** | Every share loads the module, and SnapShield is receiving. | Nothing. |
| **N of M shares protected** | Some shares are not protected. | Protect the shares marked **Not protected**, or leave them if you don't need them watched. |
| **No shares protected** | No share loads the module. | [Protect a share](#step-2-protect-a-share). |
| **Module missing** | Samba is running without the SnapShield module. | [Use the 45Drives Samba build](#step-1-use-the-45drives-samba-build). |
| **Samba stopped** / **Samba not installed** | Samba isn't running on this server. | Start it: `sudo systemctl start smbd` (Ubuntu) or `sudo systemctl start smb` (Rocky). |
| **Not reporting** | SnapShield's detection service isn't running, so nothing is being watched. | See [Troubleshooting](troubleshooting.md#samba-connection-says-not-reporting). |
| **No shares** / **Shares unreadable** | Samba has no shares, or its configuration couldn't be read. | Run `testparm -s` and fix any errors it reports. |

Below the badge, the share table lists each share with its path and protection status. For protected shares, **Activity** shows how many client sessions are connected and when SnapShield last received file activity, for example `2 sessions · last activity 12s ago`. Shares that aren't protected are listed first.

### Confirm with a test

1. On a workstation, connect to a protected share and copy a file into it.
2. Within a few seconds, the share's **Activity** shows a session and recent activity.
3. **Number Files Scored** on the Overview page goes up.

If the share shows **Protected** but no sessions while a client is connected, the client connected before the share was protected. Reconnect it.

## Related

- [Getting started](getting-started.md)
- [Troubleshooting](troubleshooting.md)
- [Dashboard guide](dashboard.md)
