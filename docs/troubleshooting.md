# Troubleshooting

This guide is for administrators who hit a problem installing or running SnapShield or the Control Panel. Each entry lists the symptom, the likely cause and the fix.

- [Setup wizard](#setup-wizard)
- [Cockpit plugin](#cockpit-plugin)
- [SnapShield services](#snapshield-services)
- [Detection and scoring](#detection-and-scoring)
- [Control Panel](#control-panel)
- [Licensing](#licensing)
- [Logs and log levels](#logs-and-log-levels)

## Setup wizard

### Cockpit shows "Limited access" and setup can't save or check permissions

**Cause:** Cockpit is running without administrator rights. The wizard needs them to read configuration, check packages and save settings.

**Fix:** Click **Limited access** in Cockpit's top bar and turn on **Administrative access**. Then retry the same step. Your answers are kept. If your account can't get administrative access, ask a host administrator.

### "Check setup permissions" fails with a sudo error

**Symptom:** The check, or the run, reports that sudo needs a password, for example `sudo: a password is required`.

**Cause:** Setup runs Ansible as your Cockpit user. That account needs sudo without a password prompt on every target host, including the local one. A SnapShield or Control Panel admin login does not grant this.

**Fix:** Configure passwordless sudo for the account on each target host, then click **Check setup permissions** again. Remote hosts must also accept SSH from this host with the key you entered on the **Hosts** step.

### Packages step: "This host's package manager cannot find …"

**Cause:** The 45Drives repository is not set up on this host, or setup can't reach it.

**Fix:** Rerun the setup script from [Installation](installation.md) to configure the repository, then click **Retry repository access**. Your answers are kept.

### Packages step: GPG or signature error

**Cause:** The package manager could not verify the repository's signature. Setup never turns off signature checks to work around this.

**Fix:** Rerun the setup script from [Installation](installation.md), which installs the 45Drives signing key. Then click **Retry repository access**.

### Configuration step can't read the existing configuration

**Cause:** Administrative access is off, or the saved configuration file is invalid.

**Fix:** Turn on **Administrative access** and click **Reload existing configuration from this host**. If the error says the file is invalid, contact support with the error text.

### Setup fails with "Destination directory /etc/prometheus/alerting does not exist"

**Cause:** Seen on some older Ceph clusters, where a metrics node is missing this folder.

**Fix:** On each node named in the error, run `sudo mkdir -p /etc/prometheus/alerting`, then run setup again.

### Setup finished but the dashboard doesn't work

**Cause:** **Setup completed** means the deployment ran without errors. It does not test that you can sign in.

**Fix:** Check the [services](#snapshield-services) below. If you set up a remote host, open Cockpit on that host instead of this one.

## Cockpit plugin

### SnapShield doesn't appear in the Cockpit menu

**Cause:** Cockpit hasn't picked up the plugin yet, or the package isn't installed.

**Fix:**

1. Sign out of Cockpit and sign back in.
2. Hard reload the page (**Ctrl+Shift+R**).
3. Check the plugin is installed: `ls /usr/share/cockpit/snapshield/`.
4. Restart Cockpit: `sudo systemctl restart cockpit`.

Cockpit 250 or later is required. Check with `cockpit --version`.

### Blank page or loading error after an upgrade

**Cause:** Your browser or Cockpit session still has files from the old version.

**Fix:** Sign out of Cockpit and sign back in. If that doesn't help, hard reload (**Ctrl+Shift+R**). If it still fails, reinstall the `cockpit-snapshield` package and sign in again.

### The dashboard says it can't reach SnapShield

**Cause:** The SnapShield web service on this host isn't running, or the connection settings were changed.

**Fix:**

1. Check the service: `systemctl status snapshield-webd`.
2. Read recent messages: `journalctl -u snapshield-webd -n 50`.
3. Open **Manage → Connection settings** and click **Use default** if the address was changed.

A connection failure does not mean SnapShield is uninstalled. Don't rerun setup until you've checked the service.

### "Connection settings" won't save

**Cause:** Saving changes the setting for every Cockpit user on the host, so it needs **Administrative access**.

**Fix:** Turn on **Administrative access** and save again.

### Certificate warning when opening the standalone dashboard (port 45677 or 9045)

**Cause:** The standalone interfaces use a self-signed certificate by default.

**Fix:** Confirm you're connecting to the right server, then accept the certificate in your browser. Or use the dashboard inside Cockpit, which only needs Cockpit's certificate.

## SnapShield services

### Services aren't running

**Symptom:** The dashboard doesn't load, shows no data, or events stop appearing.

**Fix:** Check each service:

```bash
systemctl status snapshield-radar      # detection engine
systemctl status snapshield-webd       # dashboard API
systemctl status snapshield-ui         # dashboard web interface
systemctl status snapshield-exporter   # metrics
systemctl status snapshield-ipban      # IP banning
systemctl status snapshield-postgres   # database
systemctl status snapshield-redis      # cache
```

Start any that are stopped with `sudo systemctl start <service>`. If one keeps failing, read its log with `journalctl -u <service> -n 100` and include it in your bug report.

It may be necessary to reboot the server after the first installation.

### Dashboard cards show "No data"

**Cause:** There's no activity to report yet.

**Fix:** None needed. Copy some files to a protected share and the cards fill in.

## Detection and scoring

### No files are being scored

**Cause:** The share doesn't load SnapShield's Samba module, or there are no snapshots.

**Fix:**

1. Check the share has `vfs objects = snapshield`. See [Getting started](getting-started.md#2-turn-snapshield-on-for-your-shares).
2. Check SnapShield can see snapshots (next entry).

### SnapShield can't find snapshots

**Symptom:** `journalctl -u snapshield-radar | grep "No snapshots found."` shows recent matches. SnapShield checks every 30 seconds.

**Cause:** There are no snapshots, or their names don't match the expected date format.

**Fix:**

1. Make sure snapshots are being taken on each pool or filesystem.
2. In **Settings**, check **ZFS Snapshot Datestamp Format** or **Ceph Snapshot Datestamp Format** matches your snapshot names.
3. Click **Save**, then **Restart**.
4. Run `journalctl -u snapshield-radar | grep -E "Found [0-9]+ snapshots\."` to confirm.

### Backup jobs or other trusted clients get banned

**Cause:** Bulk copying looks like ransomware or data theft.

**Fix:** Unban the address on **Quarantine**. Then add the client to **Settings → White List IPs** (or **White List Users**) and click **Save**.

### Too many false positives

**Fix:** Raise the multipliers or limits under **Settings → Data Exfiltration - Behavior**, or raise **Minimum Profile Age (days)**. Allowlist known heavy users. To watch for a while without banning, set the event action to **report** in **Manage → Setup / change installation**.

### Honey-files aren't appearing

**Cause:** Honey-files are turned off, or the service hasn't reloaded.

**Fix:** Tick **Enable Honey-file** in **Settings**, click **Save**, then **Restart**.

### A honey-file shows "Missing"

**Cause:** The decoy was deleted or moved. This can be a sign of an attack.

**Fix:** Check **Events** for a matching Honeyfile event and investigate the user and IP address straight away.

### Database size warning on the Overview page

**Cause:** **Data Base Size** turns red above 3000 MB.

**Fix:** Check free disk space on the server. If the database keeps growing, open a bug report or contact support for tuning advice.

## Control Panel

### A server shows "Unreachable"

**Cause:** The Control Panel can't reach the server's API.

**Fix:**

1. Check the server's IP address and **API Port** (default `43678`) under **Edit Instance**.
2. Make sure that port is open from the Control Panel host to the server.
3. Check `snapshield-webd` is running on the server.
4. Click **Refresh Health**.

### A server is listed but can't be managed

**Cause:** Central management needs the server to be on Enterprise. A Community server stays listed so you can license or remove it.

**Fix:** Apply an Enterprise trial or license to that server. See [Licensing](licensing.md).

### Licensing page shows "Upgrade needed"

**Cause:** The server's SnapShield is too old for per-server licensing.

**Fix:** [Upgrade](upgrading.md) that server.

### Control Panel services aren't running

**Fix:** Check them on the Control Panel host:

```bash
systemctl status snapshield-cp-backend
systemctl status snapshield-cp-ui
systemctl status snapshield-cp-postgres
```

Read errors with `journalctl -u snapshield-cp-backend -n 50`.

### "short-name resolution" error during Control Panel setup

**Cause:** The Control Panel's container image comes from the `snapshield-control-panel` package, not from the internet. The package is missing.

**Fix:** Make sure `snapshield-control-panel` is installed, then run setup again.

## Licensing

### Only one admin can sign in

**Cause:** The server is on Community. Only the primary admin can sign in until Enterprise is active.

**Fix:** Sign in as the primary admin, or apply an Enterprise license. See [Licensing](licensing.md).

### Red "local license" error on the License page

**Cause:** The page couldn't read this server's license file. It does not mean Enterprise has expired, and protection keeps running.

**Fix:** Check `snapshield-webd` is running, then reload the page. If it persists, open a bug report.

### "Last license-server check failed"

**Cause:** The server couldn't reach the license server.

**Fix:** Nothing urgent. The stored license and expiry are unchanged. Check the server's internet access if you expect it to connect.

### Portal says "Export a new server request from an upgraded SnapShield server."

**Cause:** The server's SnapShield is too old.

**Fix:** [Upgrade](upgrading.md) the server, then export a new activation request.

## Logs and log levels

The detection engine writes these logs:

| File | Contents |
|------|----------|
| `journalctl -u snapshield-radar` | General messages, such as snapshot discovery |
| `/usr/share/snapshield/radar-score.log` | File scoring |
| `/usr/share/snapshield/radar-general.log` | General operations and errors |
| `/usr/share/snapshield/radar-event.log` | Ransomware event detection |
| `/usr/share/snapshield/radar-audit.log` | Audit trail |

Log levels, from most to least detail: `trace`, `debug`, `info`, `warn`, `error`. Each level includes everything less detailed than itself.

### Change the log level

1. Edit `/usr/share/snapshield/config/logger.yaml`.
2. Set `level:` under `root` (console messages) or under a named logger (`score`, `general`, `event`, `audit`).
3. Restart detection: `sudo systemctl restart snapshield-radar`.

### Too much log output

**Symptom:** The journal fills with one line per snapshot every 30 seconds.

**Fix:** Set the `root` level to `info`. You keep the summary line ("Found 1523 snapshots.") without one line per snapshot.

Recommended production settings:

```yaml
root:
  level: info
  appenders:
    - stdout

loggers:
  score:
    level: info
    appenders:
      - score_ap
  general:
    level: info
    appenders:
      - general_ap
  event:
    level: debug
    appenders:
      - event_ap
  audit:
    level: debug
    additive: false
    appenders:
      - audit_ap
```

### Collect detail for a bug report

Set every logger to `debug`, restart `snapshield-radar`, reproduce the problem, and attach the logs. Set the levels back to `info` afterwards to save disk space.

## Still stuck?

Ask on the [45HomeLab Forum](https://forum.45homelab.com/) — someone may have seen it before. Enterprise customers can email [info@45drives.com](mailto:info@45drives.com).

If you think you've found a bug, [open a bug report](https://github.com/45Drives/SnapShield-public/issues/new/choose). Include:

- Your operating system and SnapShield version.
- What you did, what you expected, and what happened.
- Relevant log output, with passwords and private details removed.
