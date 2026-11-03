# Installing SnapShield

This guide is for administrators installing SnapShield on a Samba file server, and optionally the SnapShield Control Panel. It covers the setup script, the Cockpit setup wizard, manual repository setup and the steps that finish the job after the wizard.

## Before you start

- A server running **Rocky Linux / RHEL / AlmaLinux 8 or 9**, or **Ubuntu 20.04 or 22.04** (x86_64).
- Root or `sudo` access, and an account that can sign in to Cockpit as an administrator.
- Internet access to `repo.45drives.com`.
- The Samba shares you want to protect, on storage that takes regular snapshots (see [Getting started](getting-started.md)).

## How installation works

1. **`setup.sh`** adds the 45Drives package repository, installs Cockpit and the SnapShield Cockpit plugin, and turns Cockpit on.
2. **The setup wizard** in Cockpit installs the rest of SnapShield, writes its configuration and starts its services.
3. **You** point your Samba shares at SnapShield and make sure snapshots are being taken.

## Step 1: Run the setup script

On the server:

```bash
curl -sSL https://raw.githubusercontent.com/45Drives/SnapShield-public/main/setup.sh | sudo bash
```

To read the script before running it:

```bash
curl -sSLO https://raw.githubusercontent.com/45Drives/SnapShield-public/main/setup.sh
less setup.sh
sudo bash setup.sh --dry-run   # shows every change, makes none
sudo bash setup.sh
```

### Options

| Option | What it does |
|---|---|
| `--community` | Use the 45Drives Community repository. This is the default. |
| `--enterprise` | Use the 45Drives Enterprise repository. |
| `--testing` | Turn on the testing release stream as well as stable, and install the newest build from either. This is the default while SnapShield 0.3 rolls out to stable. |
| `--stable` | Use the stable release stream only. |
| `--repo-only` | Set up the repository only; don't install Cockpit or the plugin. |
| `--dry-run` | Print what would be done without changing anything. |

Pass options after `bash -s --` when piping, for example:

```bash
curl -sSL https://raw.githubusercontent.com/45Drives/SnapShield-public/main/setup.sh | sudo bash -s -- --enterprise
```

Both repositories carry the same SnapShield packages. Your **license** decides whether a server runs Community or Enterprise, not the repository — see [Licensing](licensing.md).

### What the script changes

- **Rocky / RHEL:** writes `/etc/yum.repos.d/45drives-community.repo` (or `-enterprise.repo`) from the official 45Drives repository file, with the testing stream turned on or off to match your choice.
- **Ubuntu:** installs the 45Drives signing key to `/usr/share/keyrings/45drives-archive-keyring.gpg` and writes `/etc/apt/sources.list.d/45drives-community-<codename>.list` (or `-enterprise-`).
- Moves any repository file that still points at the retired `enterprise-premium` repository to `/opt/45drives/archives/repos/`.
- Installs `cockpit` and `cockpit-snapshield` (without the SnapShield service itself — the wizard installs that), enables `cockpit.socket`, and opens port 9090 if firewalld or ufw is active.

Running the script again is safe; it rewrites the same files.

## Step 2: Run the setup wizard

1. Open `https://<your-server>:9090` and sign in with an administrator account. Your browser will warn about Cockpit's self-signed certificate the first time; that is expected.
2. If the top of the page says **Limited access**, click it and turn on **Administrative access**. The wizard needs it to install packages and write configuration.
3. Choose **Snapshield Dashboard** in the menu. On a new server, the setup wizard opens.

The wizard walks through these steps:

| Step | What happens |
|---|---|
| **Detect** | Checks what is already installed and running on this server. |
| **Hosts** | Choose this server, other servers reachable over SSH, or both. |
| **Configuration** | Loads any existing configuration and asks for the settings SnapShield needs, such as the admin account and quarantine directory. |
| **License** | Keeps the server's existing licensing. A new server starts on Community; you activate an Enterprise license or trial afterwards from the dashboard's **License** page — see [Licensing](licensing.md). |
| **Packages** | Checks automatically that this server's package manager can find every SnapShield package, and shows the version it will install. |
| **Review & Run** | Shows exactly what will be installed and changed, and checks automatically that setup has the permissions it needs. Confirm the review, then click **Run setup**. |
| **Results** | Shows whether setup finished, with any errors from the run. |

Nothing is installed or changed until you click **Run setup**.

### Installing the Control Panel

The Control Panel manages several SnapShield servers from one place. Install it on the server you want to host it — a SnapShield server or a separate one — the same way: run `setup.sh`, open Cockpit, and choose the **Control Panel** component in the setup wizard. Managing a server from the Control Panel requires that server to be on Enterprise (a trial counts). See the [Control Panel guide](control-panel.md).

## After the wizard

Check that SnapShield's services are running:

```bash
systemctl --no-pager status 'snapshield*'
```

All services should be `active (running)`. Then continue with [Getting started](getting-started.md): it covers turning SnapShield on for your Samba shares (`vfs objects = snapshield`) and making sure snapshots are being taken. SnapShield doesn't protect a share until both are done.

## Manual repository setup

If you'd rather not use the script, set up the repository yourself, then install `cockpit` and `cockpit-snapshield` and enable `cockpit.socket`. The plugin is installed without its recommended packages so that the SnapShield service itself is installed by the wizard, after you review the plan.

**Rocky / RHEL 8 and 9:**

```bash
sudo curl -sSL https://repo.45drives.com/repofiles/rocky/45drives-community.repo -o /etc/yum.repos.d/45drives-community.repo
sudo dnf config-manager --set-enabled 45drives_community_testing   # while SnapShield 0.3 rolls out to stable
sudo dnf install -y cockpit
sudo dnf install -y --setopt=install_weak_deps=False cockpit-snapshield
sudo systemctl enable --now cockpit.socket
```

`dnf config-manager` comes from the `dnf-plugins-core` package. For Enterprise, replace `community` with `enterprise` throughout.

**Ubuntu 20.04 and 22.04:**

```bash
curl -fsSL https://repo.45drives.com/key/gpg.asc | sudo gpg --dearmor -o /usr/share/keyrings/45drives-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/45drives-archive-keyring.gpg] https://repo.45drives.com/community/ubuntu $(lsb_release -sc) main testing" \
  | sudo tee /etc/apt/sources.list.d/45drives-community-$(lsb_release -sc).list
sudo apt-get update
sudo apt-get install -y cockpit
sudo apt-get install -y --no-install-recommends cockpit-snapshield
sudo systemctl enable --now cockpit.socket
```

The 45Drives repository includes a current Cockpit build, so Cockpit comes from there too. For Enterprise, replace `community` with `enterprise`. Drop `testing` from the source line once SnapShield 0.3 has finished rolling out to stable.

## Next steps

- [Getting started](getting-started.md)
- [Troubleshooting](troubleshooting.md) if anything above didn't work
