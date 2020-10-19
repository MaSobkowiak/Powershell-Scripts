# Backup
Backup is a simple powershell script for making backups of given directory. It copies new files, checks for changes based on date modified, and removes remains. After each run u get separate log.txt with list of all operations that have been done. U can exclude specific files or extensions from backup.
#### filter
```powershell
$exclude = @("*.bak", "*.lck", "*.lic", "*.TMP", "*.tmp", ".run", "cert.pem")
```
#### log
```txt
| Date:               | Type:  | Base file:                     | Backup file:                   |
| 10/17/2020 23:58:39 | COPY   | Y:\a.txt                       |  X:\a.txt                      |
| 10/17/2020 23:58:40 | COPY   | Y:\test\b.png                  |  X:\test\b.png                 |
| 10/17/2020 23:58:39 | UPDATE | Y:\c.txt                       |  X:\c.txt                      |
| 10/17/2020 23:58:40 | DELETE | Y:\test\b.png                  |  X:\test\b.png                 |
```
