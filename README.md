# Powershell script to block Windows telemetry

Run the *[current powershell script](https://github.com/Keigun-Spark/Windows-Telemetry/releases)* to automatically block Windows telemetry.

The script changes registry entries, deletes files and adds new firewall rules. All changes are based on the recommendation of the *Bundesamt für Sicherheit in der Informationstechnik* from Germany.

Windows updates may revert these changes, rerun the script after major Windows updates.
Changes only effective after restart.
