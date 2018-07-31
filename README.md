# sftp_copy

The script connects to SFTP server and copy needed access log files (zipped) to remote destination.
Access log files are then unzipped and stored in a single file on a different folder.
Access logs older than 2 days will then be deleted for cleanup.
