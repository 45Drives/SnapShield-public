# Restoring files

This guide is for administrators recovering files after a SnapShield event. It covers restoring one or many files from snapshots, quarantining files, where quarantined files go, and what to do when no snapshot exists.

For the **Restore** page fields, see the [dashboard guide](dashboard.md#restore).

## How recovery works

SnapShield lists the files touched during an event and offers one action per file:

| Button | When it appears | What it does |
|--------|-----------------|--------------|
| **Restore File** | A snapshot copy exists from before the activity. The **Snapshot** column names it. | Moves the current file (if any) to quarantine, then copies the snapshot version back with its original owner and permissions. |
| **Quarantine File** | Only the current file exists. No snapshot copy is available. | Moves the current file to the quarantine directory. |
| No button | Shown for information only. | Nothing. Recover these by hand if needed (see below). |

SnapShield picks the most recent snapshot taken before the file's activity.

## Find the affected files

1. On **Events**, click **View** on the event. The **Restore** page opens with the user, IP address and time range filled in.
   - For **Encrypting** events, the restore actions are available.
   - For other event types, the page opens as a files-only view with actions turned off. To act on those files, open **Restore** from the sidebar and set the filters yourself.
2. To search by hand, fill in **Username**, **IP Address**, **Start Date** and **End Date**. Use **File Path Search** to narrow by path.
3. Leave **Restorable** and **Quarantinable** ticked to see both kinds of row, or untick one to hide it.
4. Click **Filter**.

## Restore or quarantine one file

1. Find the file in the list.
2. Click **Restore File** or **Quarantine File** on its row.
3. A message confirms the result, and the row disappears from the list.

## Restore or quarantine many files

1. Tick the files you want, or tick the box in the header row to select all.
2. If the list has files to quarantine, click **Quarantine Selected** first.
3. Click **Filter** to refresh the list.
4. Select the files again and click **Restore Selected**.
5. When the batch finishes, the message shows how many succeeded and how many failed. Failed files stay in the list. Retry them one at a time to see the error.

If you click **Restore Selected** while files still need quarantining, SnapShield asks you to select all and quarantine first.

## Where quarantined files go

Quarantined files are moved to the **Quarantine directory** chosen in the setup wizard.

- The file's original folder path is recreated inside the quarantine directory.
- A random suffix is added to the file name, so repeated quarantines don't overwrite each other.
- Nothing is deleted. Quarantined files stay until you remove them.

Keep the quarantine directory off your shares, so users can't open quarantined files. Check it for anything you need, then delete what you don't. To recover a quarantined file, copy it back to its share and remove the suffix from its name.

## If no snapshot exists

If a file has no snapshot copy, SnapShield can't restore it. You can still quarantine it to get it out of users' reach.

Then:

1. Check other copies: backups, replicas, or the user's own copies.
2. For rows with no button, look in the snapshot folder by hand. On ZFS, snapshots are under `.zfs/snapshot/` at the root of the dataset. On CephFS, they are under `.snap/`. Copy the file back to its original location.
3. Make sure snapshots are being taken so the next event is recoverable. See [Routine checks](routine-checks.md).

## After recovery

1. Ask users to check the restored files open correctly.
2. Resolve the event on **Events**.
3. Unban the client on **Quarantine** once it is clean. See [Responding to alerts](responding-to-alerts.md).

## Related

- [Responding to alerts](responding-to-alerts.md)
- [Dashboard guide](dashboard.md#restore)
- [Getting started: make sure snapshots exist](getting-started.md#3-make-sure-snapshots-exist)
- [Troubleshooting: SnapShield can't find snapshots](troubleshooting.md#snapshield-cant-find-snapshots)
