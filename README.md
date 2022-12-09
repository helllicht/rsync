# helllicht/rsync

## requirements
The host system needs to allows ssh connections and supports rsync.
If you want to authorize by ssh key, make sure that the key is **not** protected by a passphrase since ```helllicht/rsync``` does not support passphrase protected ssh-keys.

## example `workflow.yml`:
The step to sync data in your ```.github/workflows/workflow.yml``` could look like this

```yml
- name: Run rsync
  uses: helllicht/rsync@v1
  with:
    remote_server: ${{ secrets.REMOTE_SERVER }}
    remote_user: ${{ secrets.REMOTE_USER }}
    local_directory: ./
    remote_directory: ./example-directory/
    dry_run: false
    remote_password: ${{ secrets.REMOTE_PASSWORD }}
    exclude_file: .syncignore
    remote_port: "22"
    delete_from_remote_directory: falsex
```

## parameters
### required parameters

```remote_server``` 'Host to deploy on

```remote_user``` 'The user to use for connection

```local_directory``` 'The local directory to be synced

```remote_directory``` 'The target directory on the host system

```dry_run``` 'Do you want to perform a dry run?

---
### authorization parameters
**Either set ```remote_passsword``` OR ```private_key```. If none or both are set, job will fail.**

```remote_password``` Password for the host system. Don`t set if authorizing by ssh key

```private_key``` The matching private key to the public key on the host system. Don`t set if authorizing by password. When set, must equal the entire private key file - including begin-line and end-line

---
### optional parameters
```remote_port``` The port to use for connection - default is 22

```delete_from_remote_directory``` Do you want to delete files from remote_dir, that are not in the local_dir - default is false

```exclude_file``` path to a syncignore file (further information below) - default is ***no exclude file***


## exclude_file

Extract from rsync docs about exclude file: https://download.samba.org/pub/rsync/rsync.1#opt--exclude-from

```
Blank lines in the file are ignored, as are whole-line comments that start with ';' or '#' (filename rules that contain those characters are unaffected).

If a line begins with "- " (dash, space) or "+ " (plus, space), then the type of rule is being explicitly specified as an exclude or an include (respectively). Any rules without such a prefix are taken to be an exclude.

If a line consists of just "!", then the current filter rules are cleared before adding any further rules.

If FILE is '-', the list will be read from standard input.
```

**For general information about include/exclude rule see https://download.samba.org/pub/rsync/rsync.1#FILTER_RULES**

