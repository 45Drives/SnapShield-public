# Responding to alerts

This guide is for administrators who have just seen a new SnapShield event. It covers triage, investigation, deciding whether the event is real, recovering files, unbanning and resolving.

For what each dashboard page shows, see the [dashboard guide](dashboard.md).

## How you find out

- A new row appears on the **Events** page.
- **New Events Detected** and **Estimated Files Affected** on the **Overview** page go up and turn red.
- In ban mode, the client's IP address appears on the **Quarantine** page.
- If email alerts are set up, you get an email.

## 1. Triage

1. Open **Events**. Reload the page to see the latest rows.
2. For each event, note the **Username**, **IP Address**, **Start Date**, **End Date**, **Estimated Files Affected** and **Event Type**.
3. Deal with the most serious first:
   - **Encrypting** and **Honeyfile** events need attention straight away.
   - The "Alert" types (**StaticRateAlert**, **HourlySpikeAlert**, **FileTypeSpikeAlert**) can trigger a ban. Check them promptly.
   - **AccessWarning** and the "Warning" types only report. Check them the same day.

The event types are listed in [Getting started](getting-started.md#5-what-a-detection-looks-like).

## 2. Investigate the user and IP address

1. On the event row, click **View**. The **Restore** page opens, filtered to that user, IP address and time range.
   - For **Encrypting** events you can restore or quarantine files here.
   - For other event types the page opens in a files-only view. It lists the affected files, and restore actions are turned off.
2. Look at the paths. Are they spread across a share, renamed, or in places this user doesn't normally work?
3. Identify the machine behind the IP address and who was using it.
4. If you run the Control Panel, open **Users & Activity** and search for the username or IP address. The expanded user shows their hourly activity against their normal baseline and their file history across all servers. See [Control Panel guide](control-panel.md#users--activity).

## 3. Decide: real attack or false positive

Treat it as **real** if any of these apply:

- File contents look encrypted, files have new extensions, or ransom notes appear.
- A honey-file was opened by someone with no reason to open it.
- The user or machine owner doesn't recognise the activity.

It is likely a **false positive** if the activity matches known work, such as a backup job, a migration, a bulk export or a script that rewrites many files.

If you're not sure, treat it as real until you've checked the client.

## 4a. If it is real

1. Disconnect the affected client from the network.
2. In ban mode, confirm its IP address is on **Quarantine**. In report mode, ban it yourself: enter the address in **Enter Ban Ip** and click **Ban**.
3. Clean or rebuild the client before it reconnects.
4. Recover the affected files. See [Restoring files](restoring-files.md).
5. Check **Events** for related events from the same user or other IP addresses.

## 4b. If it is a false positive

1. If the client was banned, open **Quarantine** and click **Unban** next to its address.
2. Stop it happening again: allowlist the client or add an ignore rule. See [Bans and allowlists](bans-and-allowlists.md).

## 5. Resolve the event

When the client is clean and files are recovered, go back to **Events** and click **Resolve** on the event.

Resolving only marks the event as handled. It doesn't unban the client or change any files. Unban separately on **Quarantine** when it's safe.

## Ban mode and report mode

The event action is chosen during setup.

| | Ban mode | Report mode |
|---|---|---|
| Serious detections | Event created and client IP address banned | Event created only |
| Your first step | Check whether the ban was justified | Decide quickly whether to ban by hand |
| After a false positive | Unban, then allowlist | Allowlist or tune; nothing to unban |

In report mode nothing stops an attacker automatically, so check events promptly. To change the mode, run **Manage → Setup / change installation** again.

## Related

- [Restoring files](restoring-files.md)
- [Bans and allowlists](bans-and-allowlists.md)
- [Honey-files](honeyfiles.md)
- [Dashboard guide](dashboard.md)
- [Control Panel guide](control-panel.md#respond-to-a-ransomware-alert)
