> `README`

## Scripts for using with Applications, Packages or any automation software.

RestoreNetwork.ps1 - Powershell Script to verify network configs and try to fix.

### Developed by: Fábio Leitão

### Last Update:

01/25/2022 - Add-Script File (RestoreNetwork.ps1)
01/25/2022 - Add-Batch File (DownRestoreNetwork.bat)
In soon - Script (IntelvPROProvisioning.py) upload to Github 

## RestoreNetwork SCCM Package Offline -- see how to use here

#### usage: 

Using the SCCM (System Center Configuration Manager) or MECM (Microsoft Endpoint Configuration Manager) it is possible to create a package to send the script to a local directory defined by IT, so that it can later be activated and used by the end user via software center to restore a local network.

#### Case 1: 

Restore local internet connection in case of third-party software locking IP/DNS/WINS settings in network adapter

#### Case 2:

Enable or re-enable a network adapter that is disabled or stuck due to an error in the operating system or third-party software.

#### Case 3:

Check network settings and third-party antivirus software or network tools needed on the computer.

#### Case 4:

Generate individual logs or all the resources mentioned above, being possible to save in a local directory and later moved to the network after the script is finished or through a windows scheduled task.

#### ~For all Cases:

You can use all the features together or edit, split and use parts of the script as needed for your environment and modify it to your liking.

## IntelvPROProvisioning SCCM Application -- see how to use here

DownRestoreNetwork
#### usage:

Script to copy the powershell script to a new path location for use by Application created by SCCM/MECM in Software Center

### Developing...

## IntelvPROProvisioning SCCM Application -- see how to use here

IntelvPROProvisioning
#### usage:

### Developing...


