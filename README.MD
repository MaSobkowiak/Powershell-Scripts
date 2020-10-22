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

# Processor boost

This script can help you easily enable or disable processor turbo boost option. When you don't need extra processing power you can turn it off, and make your fans spin slower, decreasing loudness of the device.

### Power plan option
```powershell
# Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e (Balanced)
# Power Scheme GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c (High performance)
# Power Scheme GUID: a1841308-3541-4fab-bc81-f71556f20b4a (Power saver)

$GUID  =  "381b4222-f694-41f0-9685-ff5bb260df2e"
```
Depending on what power plan option you are currently running, you have to set GUID variable to match your settings.
### Usage
Copy repository to your machine, in root project director is all set up shortcut that can be used e.g. to pin quick toogle to taskbar. When clicked, message box will show up information if boost is on or off.

![on](https://raw.githubusercontent.com/MaSobkowiak/Powershell-Scripts/master/Processor%20boost/assets/ON.png)
![off](https://raw.githubusercontent.com/MaSobkowiak/Powershell-Scripts/master/Processor%20boost/assets/OFF.png)

To make it look nicer, you can add custom shortcut icon from icons folder, so when you pin it to your taskbar you will know what this shortcut is for.
<p align="center">
  <img src="https://raw.githubusercontent.com/MaSobkowiak/Powershell-Scripts/master/Processor%20boost/assets/gray.png" width="200" height="200"> 
  <img src="https://raw.githubusercontent.com/MaSobkowiak/Powershell-Scripts/master/Processor%20boost/assets/navy.png" width="200" height="200">
  <img src="https://raw.githubusercontent.com/MaSobkowiak/Powershell-Scripts/master/Processor%20boost/assets/green.png" width="200" height="200">
  <img src="https://raw.githubusercontent.com/MaSobkowiak/Powershell-Scripts/master/Processor%20boost/assets/pink.png" width="200" height="200">
</p>
