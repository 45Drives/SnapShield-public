# Honey-files

This guide is for administrators who want to use decoy files to catch ransomware and data theft early. It covers what honey-files are, turning them on, how many to use, what triggers an event, and keeping them healthy.

For the settings and the **Honey-files** page in detail, see the [dashboard guide](dashboard.md).

## What honey-files are

Honey-files are decoy files that SnapShield places in your shares. No legitimate user needs to open them. Ransomware and data-theft tools work through folders and open everything they find, so they reach a honey-file early.

When a client opens a honey-file:

- SnapShield creates a **Honeyfile** event on **Events**.
- In ban mode, it bans the client's IP address straight away.

Clients on **White List IPs** or **White List Users** are not checked. See [Bans and allowlists](bans-and-allowlists.md).

Honey-files are off by default.

## Turn honey-files on

1. Open **Settings** and scroll to **Data Exfiltration - Honey-Files**.
2. Tick **Enable Honey-file**.
3. Set **Number of honey-files to keep per share**.
4. Under **Honey-file Excluded Folders**, list folders where decoys must never go, one per line, relative to the share. For example, folders used by applications or by backup software.
5. Optionally add **Honey-file Definitions (static)**. Click **Add definition** and enter a **Name**, **Extension** and **Size (KiB)**. These files always exist, in addition to the number above.
6. Click **Save**, then **Restart**. SnapShield places the files when the detection service starts.
7. Open **Honey-files** and click **Refresh**. The new files should be listed with **Status** **Present**.

## How many to use

Three to five per share is a good start. More decoys mean an attacker reaches one sooner, but also more files your users might stumble on.

For static definitions, use realistic names that an attacker would want, such as `Q4_Financial_Summary` with extension `xlsx`, or `Employee_Directory` with `csv`.

## Tell your users

Users browsing a share can see honey-files. Opening one raises an event and, in ban mode, cuts off their machine. Let staff know not to open unfamiliar files, without telling them which files are decoys.

## Check on them

Open **Honey-files** regularly.

- **Present** means SnapShield verified the file recently. The **Verified** column shows when.
- **Missing** (red row) means the file was deleted or moved. This can be a sign of an attack. Check **Events** straight away for a Honeyfile event and investigate the user and IP address. See [Responding to alerts](responding-to-alerts.md).

SnapShield checks every honey-file about once a minute.

## Maintain them

- **Replace missing files:** once you've investigated, click **Restart** on **Settings**. SnapShield recreates missing honey-files when the detection service starts.
- **Change the count:** change **Number of honey-files to keep per share**, then **Save** and **Restart**. Lowering it removes extra decoys.
- **Keep decoys out of a folder:** add the folder to **Honey-file Excluded Folders**, then **Save** and **Restart**. This applies to new placements only. Decoys already in that folder stay.
- **Stop placing decoys:** untick **Enable Honey-file**, then **Save** and **Restart**. Honey-files already on the shares stay in place and are still watched.

Don't move or rename honey-files by hand. SnapShield tracks them by path and will report them as **Missing**.

## Related

- [Responding to alerts](responding-to-alerts.md)
- [Bans and allowlists](bans-and-allowlists.md)
- [Fire drills](fire-drills.md)
- [Dashboard guide: Honey-files](dashboard.md#honey-files)
- [Troubleshooting: honey-files aren't appearing](troubleshooting.md#honey-files-arent-appearing)
