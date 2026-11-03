# Fire drills

This guide is for administrators who want to prove SnapShield works end to end. It covers running a safe simulated ransomware attack from **Test Bench**, what a successful drill looks like, and cleaning up afterwards.

For the **Test Bench** page in detail, see the [dashboard guide](dashboard.md#test-bench).

## How the drill stays safe

- The drill runs inside a container on the server with its own IP address. SnapShield bans the container, not your server or your workstation.
- It only touches a new test folder, `testing_deleteme`, that it creates on the share. Your existing files are not changed.
- **Decrypt** reverses the simulated encryption.

## Before you start

1. Pick a share that is protected. On **Overview**, the **Samba Connection** card should show it as **Protected**. See [Connecting Samba](connecting-samba.md).
2. Have a Samba username and password that can write to the share.
3. Check the drill user is not on **White List Users** in **Settings**. Allowlisted activity is not scored, so the drill would not be detected.
4. Make sure snapshots are being taken, so the drill also tests recovery.
5. Run the drill at a quiet time and tell anyone watching email alerts.

## Run the drill

1. Open **Test Bench**.
2. Under **Fire Drill (Containerized)**, fill in:
   - **Server IP:** leave empty to test this server.
   - **Share Name:** the Samba share name.
   - **Username** and **Password:** the share account.
3. Click **Mount**. The button changes to **Unmount** when the share is mounted.
4. Click **Initialize Data** to create test files. The button disappears once there is enough data.
5. Click **Encrypt** to start the simulated attack.
6. Watch the ban status line under the buttons. In ban mode it changes from **Not Banned** to **BANNED** within moments. The page checks every few seconds.

## What success looks like

- **Test Bench** shows the container IP as **BANNED** (ban mode only).
- **Events** shows a new **Encrypting** event for the drill user.
- **Overview** shows **New Events Detected** and **Estimated Files Affected** going up.
- **Quarantine** lists the container's IP address (ban mode only).
- An alert email arrives, if email alerts are set up.

In report mode you get the event but no ban. That is the expected result.

To test recovery as well, click **View** on the event and check that the drill's files appear on **Restore**. See [Restoring files](restoring-files.md).

## If nothing is detected

1. Check the **Samba Connection** card. The share must be **Protected** and **Detection service receiving** must be ticked.
2. Check the drill user is not on **White List Users**.
3. Check there is no **Ignore Rules** entry covering the share.
4. See [Troubleshooting: detection and scoring](troubleshooting.md#detection-and-scoring).

## Clean up

1. Click **Decrypt** to reverse the simulated encryption.
2. Click **Unban Container**. The status returns to **Not Banned**.
3. Click **Cleanup** to stop and remove the drill container.
4. Click **Unmount** if the share is still mounted.
5. Delete the `testing_deleteme` folder from the share. SnapShield doesn't remove it for you.
6. On **Events**, click **Resolve** on the drill's event.

## Load Test

The **Load Test** section on the same page generates steady file activity on a mounted share. Use it to see how SnapShield behaves under load. Click **Stop** when you're done. It is not a substitute for a fire drill.

## Related

- [Responding to alerts](responding-to-alerts.md)
- [Restoring files](restoring-files.md)
- [Bans and allowlists](bans-and-allowlists.md)
- [Routine checks](routine-checks.md)
- [Dashboard guide: Test Bench](dashboard.md#test-bench)
