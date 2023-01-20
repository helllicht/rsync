# helllicht/rsync

## Introduction
This action uses rsync to deploy code to a remote system via ssh. 
Authorization can be done via password or ssh-key.

## Requirements
The host system needs to allow ssh connections and support rsync.
If you want to authorize by ssh-key, make sure that the key is **not** protected by a passphrase since `helllicht/rsync` does not support passphrase protected ssh-keys.

## Example `workflow.yml`:
The step to sync data in your `.github/workflows/workflow.yml` could look like this:

```yml
- name: Run rsync
  uses: helllicht/rsync@v1
  with:
    remote_server: ${{ secrets.HELLLICHT_IO_SERVER_HOST }}
    remote_user: ${{ secrets.HELLLICHT_IO_SERVER_USER }}
    local_directory: ./
    remote_directory: ./example-directory/
    dry_run: false
    private_key: ${{ secrets.HELLLICHT_IO_PRIVATE_KEY }}
    exclude_file: .syncignore
    remote_port: "22"
    delete_from_remote_directory: false
```

## Parameters
### Required parameters

| Parameter | Description
| :--- | :--- |
| `remote_server` | Host to deploy on
| `remote_user` | User to use for connection
| `local_directory` | Local directory to be synced
| `remote_directory` | Target directory on the host system
| `dry_run` | Perform a dry run instead of actually syncing files

---

### Authorization parameters
**Either set `remote_password` OR `private_key`. If none or both are set, job will fail.**

| Parameter | Description
| :--- | :--- |
| `remote_password` | Password for the host system. Don't set if authorizing by ssh-key
| `private_key` | Private key to an authorized public key on the host system. Don't set if authorizing by password. When set, must include the entire private key file - including begin-line and end-line

---

### Optional parameters
| Parameter | Description | Default
| :--- | :--- | :--- |
| `remote_port` | Port to use for connection | `22`
| `delete_from_remote_directory` | Delete files from remote_dir, that are not in the local_dir | `false`
| `exclude_file` | Path to a syncignore file (further information below) | _no exclude file_


## exclude_file

Extract from rsync docs about exclude file: https://download.samba.org/pub/rsync/rsync.1#opt--exclude-from

> _Blank lines in the file are ignored, as are whole-line comments that start with ';' or '#' (filename rules that contain those characters are unaffected)._
> 
> _If a line begins with "- " (dash, space) or "+ " (plus, space), then the type of rule is being explicitly specified as an exclude or an include (respectively). Any rules without such a prefix are taken to be an exclude._
> 
> _If a line consists of just "!", then the current filter rules are cleared before adding any further rules._
> 
> _If FILE is '-', the list will be read from standard input._

**For general information about include/exclude rule see https://download.samba.org/pub/rsync/rsync.1#FILTER_RULES**

