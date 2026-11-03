# Uninstalling

This guide is for administrators who want to remove SnapShield or the SnapShield Control Panel from a server.

> **Warning:** Removing SnapShield deletes its configuration and event history on that server. If the server has an Enterprise license you want to reuse, [move the license](licensing.md#move-a-license-to-a-replacement-server) first.

## 1. Stop protecting your shares

Remove `snapshield` from the `vfs objects` line of every protected Samba share. In Houston, edit the share under **Samba File Sharing → Advanced Settings**. If you edit `smb.conf` by hand, reload Samba afterwards.

## 2. Remove the deployed services

SnapShield's services were deployed by the setup wizard. The `snapshield-ansible` package includes cleanup playbooks that stop the services, remove the containers and delete the configuration. Run them before removing the packages.

**SnapShield**

```bash
cd /usr/share/snapshield-ansible
sudo ansible-playbook -i hosts.snapshield purge-snapshield.yml
```

**Control Panel**

```bash
cd /usr/share/snapshield-ansible
sudo ansible-playbook -i hosts.control-panel purge-control-panel.yml
```

`hosts.snapshield` and `hosts.control-panel` are the host lists the setup wizard saved. The playbook acts on every host listed in them.

## 3. Remove the packages

**Ubuntu**

```bash
sudo apt remove snapshield snapshield-ansible cockpit-snapshield
sudo apt remove snapshield-control-panel cockpit-snapshield-control-panel
```

**Rocky Linux**

```bash
sudo dnf remove snapshield snapshield-ansible cockpit-snapshield samba-vfs-snapshield
sudo dnf remove snapshield-control-panel cockpit-snapshield-control-panel
```

Skip the second command if you never installed the Control Panel. If you keep the Control Panel on this host, keep `snapshield-ansible` too.

## What is left behind

- Cockpit itself and the 45Drives repository configuration are not removed.
- The cleanup playbook deletes the SnapShield installation directory (normally `/usr/share/snapshield`). A quarantine directory outside it is left in place. Check it for files you want to keep before deleting it yourself.
