# Upgrading

This guide is for administrators moving an existing SnapShield or Control Panel installation to a newer release. Your configuration and licensing are kept.

## Recommended: upgrade with the setup wizard

The guided setup wizard updates SnapShield's own packages to the latest version in your 45Drives repository and redeploys the services. It only updates SnapShield packages, not the rest of the operating system.

1. Sign in to Cockpit at `https://<server>:9090`.
2. Turn on **Administrative access** if Cockpit shows **Limited access**.
3. Open **Snapshield Dashboard** (or **Snapshield Control Panel**).
4. Select **Manage → Setup / change installation**.
5. Choose the component to upgrade. Your existing configuration loads automatically. Passwords are kept unless you enter new ones.
6. Step through to **Packages**. It shows installed versions and confirms the newer packages are available.
7. On **Review & Run**, click **Check setup permissions**, tick the confirmation, and run setup.
8. Check **Results** for **Setup completed**.

Setup never restarts an Enterprise trial or replaces your license.

## Upgrade the packages first (optional)

If you prefer to update the packages yourself, do this first, then run the wizard as above so the services are redeployed.

**Ubuntu**

```bash
sudo apt update
sudo apt install --only-upgrade snapshield snapshield-ansible cockpit-snapshield
```

For the Control Panel:

```bash
sudo apt install --only-upgrade snapshield-control-panel cockpit-snapshield-control-panel
```

**Rocky Linux**

```bash
sudo dnf upgrade snapshield snapshield-ansible cockpit-snapshield samba-vfs-snapshield
```

For the Control Panel:

```bash
sudo dnf upgrade snapshield-control-panel cockpit-snapshield-control-panel
```

## After upgrading

- **Sign out of Cockpit and sign back in.** A plugin update can add new files that Cockpit only picks up on a fresh sign-in.
- If the page still looks old or blank, do a hard reload (**Ctrl+Shift+R**).
- Upgrade every server you manage from the Control Panel. Older servers show **Upgrade needed** on the Control Panel's **Licensing** page.

If something goes wrong, see [Troubleshooting](troubleshooting.md).
