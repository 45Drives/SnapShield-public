# Bans and allowlists

This guide is for administrators who manage which clients SnapShield blocks. It covers how banning works, unbanning, allowlisting trusted clients, ignore rules for noisy paths, and avoiding false positives.

For the **Quarantine** and **Settings** pages in detail, see the [dashboard guide](dashboard.md).

## How banning works

In ban mode, SnapShield bans a client's IP address when it detects:

- ransomware-like encryption,
- a honey-file being opened, or
- a behaviour **Alert** threshold being crossed (files per minute, hourly spike or file-type spike).

**Warning** thresholds only create an event. In report mode, nothing is banned automatically and every detection only creates an event.

A ban is a firewall rule on the file server that drops all traffic from that IP address. The banned client can't reach the server at all, including its shares and the dashboard. Bans stay in place after a reboot until you unban the address.

Banned addresses are listed on the **Quarantine** page (titled **Quarantined Users**).

## Ban an address by hand

1. Open **Quarantine**.
2. Type the IPv4 address in **Enter Ban Ip**.
3. Click **Ban**.

Don't ban the address you're using to reach the dashboard. You'll lose access from that machine.

## Unban an address

1. Make sure the client is clean, or that the event was a false positive.
2. Open **Quarantine**.
3. Click **Unban** next to the address.

Unbanning doesn't resolve the event. Resolving an event doesn't unban. Do both. With the Control Panel you can unban an address on many servers at once with **Bulk Action → Unban IP Address**. See [Control Panel guide](control-panel.md#bulk-actions).

## Allowlist trusted clients

Use allowlists for clients that legitimately touch many files, such as backup servers, migration tools and antivirus scanners.

1. Open **Settings**.
2. Under **Overrides Rules**, find **White List IPs** or **White List Users**.
3. Click **+** and enter the IP address or username.
4. Click **Save**, then **Restart** so the detection service picks up the change.

SnapShield skips all activity from an allowlisted IP address or user. Their files aren't scored, and they can't raise events or bans, including for honey-files. Only allowlist clients you trust. Prefer a specific IP address to a username where you can.

## Ignore noisy paths

Use ignore rules for folders whose contents change constantly and are expected to, such as application caches, build output or folders full of compressed files.

1. Open **Settings**.
2. Under **Ignore Rules**, click **+**.
3. Enter the **Share Name** and the **Relative Base Path** (the folder, relative to the share).
4. Click **Save**, then **Restart**.

Files on that share whose path starts with the base path are not scored. Activity there is unprotected, so keep each rule as narrow as you can.

## Avoid false positives

1. **Start in report mode** if you're unsure, and watch events for a week or two before turning on bans.
2. **Allowlist** backup servers and other bulk clients before they run.
3. **Add ignore rules** for folders that always look busy or encrypted.
4. **Set Warning limits below Alert limits** under **Data Exfiltration - Behavior**, so you see a warning before a ban.
5. **Raise thresholds** if normal work keeps crossing them. You can turn individual thresholds off with their checkbox.
6. **Raise Minimum Profile Age (days)** if new users trigger spike alerts too early. Until a user has this many days of history, only the files-per-minute limits apply to them.
7. **Review StaticRateWarning events** to spot heavy users before they reach a ban limit. The Control Panel's **Users & Activity** page helps here.

Click **Save**, then **Restart** after any change.

## Related

- [Responding to alerts](responding-to-alerts.md)
- [Honey-files](honeyfiles.md)
- [Dashboard guide: Settings](dashboard.md#settings)
- [Troubleshooting: backup jobs get banned](troubleshooting.md#backup-jobs-or-other-trusted-clients-get-banned)
- [Control Panel guide](control-panel.md)
