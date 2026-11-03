# Routine checks

This guide is for administrators who look after SnapShield day to day. It is a short daily, weekly and monthly checklist to confirm protection is working.

For what each page and card shows, see the [dashboard guide](dashboard.md).

## Daily

1. **Samba Connection card.** On **Overview**, the badge should read **N of M shares protected**, with N equal to M for the shares you mean to protect. If it shows a problem instead, fix that first:

   | Badge | Meaning |
   |-------|---------|
   | Samba not installed / Samba stopped | No file sharing, so nothing to protect. |
   | Module missing | The SnapShield Samba module isn't installed. |
   | Not reporting | The detection service isn't receiving file activity. |
   | No shares | No Samba shares are configured on this server. |
   | No shares protected | No share loads the SnapShield module. |
   | Shares unreadable | SnapShield couldn't read the Samba share list. |

   All three checks should be ticked: **Samba running** (with its version), **SnapShield Samba module installed** and **Detection service receiving**. In the share table, unprotected shares are listed first. Each protected share shows its sessions and last activity, or **No activity yet**. The card refreshes every 15 seconds. See [Connecting Samba](connecting-samba.md) for fixes.

2. **New events.** On **Overview**, **New Events Detected** should be 0. If not, open **Events** and work through them. See [Responding to alerts](responding-to-alerts.md).
3. **Bans.** Open **Quarantine** and check every banned address is expected.

## Weekly

1. **Snapshots.** Check new snapshots are being taken on every pool or filesystem that holds a protected share. On ZFS, the **Snapshots** page shows them. Without recent snapshots, SnapShield can't restore files. See [Troubleshooting: SnapShield can't find snapshots](troubleshooting.md#snapshield-cant-find-snapshots).
2. **Honey-files.** If you use them, open **Honey-files** and look for any **Missing** rows. See [Honey-files](honeyfiles.md).
3. **Warning events.** Review Warning-type events. Repeated warnings from a trusted client mean it is close to a ban limit. See [Bans and allowlists](bans-and-allowlists.md).
4. **Database size.** On **Overview**, the **Data Base Size** card warns above 3000 MB. If it is growing steadily, check free disk space. See [Troubleshooting](troubleshooting.md#database-size-warning-on-the-overview-page).
5. **Service health.** On the server, run:

   ```bash
   systemctl --no-pager status 'snapshield*'
   ```

   Every SnapShield service should be `active (running)`, except `snapshield-ipban`, which runs once at boot and then exits. If one has failed, see [Troubleshooting: services aren't running](troubleshooting.md#services-arent-running).

## Monthly

1. **License.** Open **License** and check **Expires**. Notices appear 30, 7 and 1 days before expiry. See [Licensing](licensing.md#renewing).
2. **Updates.** Check for a newer SnapShield release and upgrade. See [Upgrading](upgrading.md).
3. **Fire drill.** Run a drill on one share to prove detection, banning and alerts still work. See [Fire drills](fire-drills.md).
4. **Allowlists and ignore rules.** In **Settings**, remove entries for clients or folders that no longer need them. Every entry is activity SnapShield doesn't watch.
5. **Quarantine directory.** Delete quarantined files you no longer need. See [Restoring files](restoring-files.md#where-quarantined-files-go).

## Managing many servers

With the Control Panel, the **Dashboard** shows every server's health, active events and banned IP addresses on one page. Use it for the daily checks, then open each server's own dashboard for the Samba Connection card and snapshots. See [Control Panel guide](control-panel.md#dashboard).

## Related

- [Dashboard guide](dashboard.md)
- [Connecting Samba](connecting-samba.md)
- [Responding to alerts](responding-to-alerts.md)
- [Upgrading](upgrading.md)
- [Troubleshooting](troubleshooting.md)
