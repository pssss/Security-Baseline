@Rem 20180116 发现【启用并正确配置WSUS】部分配置不生效，添加部分注册表配置，配置完重启生效，不过组策略里还是显示未配置，暂未找到原因。
@Rem 20180122 在“正确配置WSUS”项中新增了一项配置：对于有已登录用户的计算机，计划的自动更新安装不执行重新启动。
@Rem 20180208 更新关于组策略不显示自动更新相关配置的解释：组策略的修改结果会保存在两个地方：1. 注册表  2. 组策略历史文件（C:\WINDOWS\system32\GroupPolicy\Machine\Registry)注册表里的结果是给应用对象读取来生效的；组策略历史文件是组策略读取的，只是组策略的状态记录，所以组策略里显示“未配置”。

@echo off
title Windows 安全加固脚本

echo [Unicode]>win.inf
echo Unicode=yes>>win.inf
echo [System Access]>>win.inf

@Rem 启用密码复杂度策略
echo **** 启用密码复杂度策略
echo PasswordComplexity = 1 >>win.inf

@Rem 配置密码长度最小值为12
echo **** 配置密码长度最小值为12
echo MinimumPasswordLength = 12 >>win.inf

@Rem 更改管理员账户名称为admin
echo **** 更改管理员帐户名称为admin
echo NewAdministratorName = "****_admin" >>win.inf

@Rem 配置帐户锁定阈值为5（可选）
echo **** 配置帐户锁定阈值为5（可选）
echo LockoutBadCount = 5>>win.inf

@Rem 配置“强制密码历史”
echo **** 记住3次已使用的密码
echo PasswordHistorySize = 3 >>win.inf

@Rem 删除或禁用高危账户
echo **** 禁用Guest用户
echo EnableGuestAccount = 0 >>win.inf

@Rem 配置“复位帐户锁定计数器”时间
echo **** 5分钟后重置帐户锁定计数器
echo ResetLockoutCount = 5 >>win.inf

@Rem 配置帐户锁定时间
echo **** 设置帐户锁定时间为5分钟
echo LockoutDuration = 5 >>win.inf

@Rem 配置密码最长使用期限（可选）
Rem echo **** 设置180天更改密码（可选）
Rem echo MaximumPasswordAge = 180 >>win.inf

echo [Event Audit]>>win.inf
@Rem 配置日志审核策略
echo **** 配置日志审核策略
echo AuditSystemEvents = 3 >>win.inf
echo AuditLogonEvents = 3 >>win.inf
echo AuditObjectAccess = 3 >>win.inf
echo AuditPrivilegeUse = 3 >>win.inf
echo AuditPolicyChange = 3 >>win.inf
echo AuditAccountManage = 3 >>win.inf
echo AuditProcessTracking = 3 >>win.inf
echo AuditDSAccess = 3 >>win.inf
echo AuditAccountLogon = 3 >>win.inf

@Rem 正确配置Windows日志
echo **** 正确配置Windows日志（当日志文件大于128M时按需覆盖事件）
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\System" /v MaxSize /t REG_DWORD /d 0x8000000 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\System" /v Retention /t REG_DWORD /d 0x00000000 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Application" /v MaxSize /t REG_DWORD /d 0x8000000 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Application" /v Retention /t REG_DWORD /d 0x00000000 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Security" /v MaxSize /t REG_DWORD /d 0x8000000 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Security" /v Retention /t REG_DWORD /d 0x00000000 /f



echo [Privilege Rights]>>win.inf
@Rem 限制可关闭系统的帐户和组
echo **** 配置仅“Administrators”用户组可关闭系统
echo SeShutdownPrivilege = *S-1-5-32-544 >>win.inf

@Rem 限制可从远端关闭系统的帐户和组
echo **** 配置仅“Administrators”用户组可从远端关闭系统
echo SeRemoteShutdownPrivilege = *S-1-5-32-544 >>win.inf

@Rem 限制“取得文件或其它对象的所有权”的帐户和组
echo **** 配置仅“Administrators”用户组可取得文件或其它对象的所有权
echo SeTakeOwnershipPrivilege = *S-1-5-32-544 >>win.inf

@Rem 配置“允许本地登录”策略
echo **** 配置仅“Administrators”和“Users”用户组可本地登录
echo SeInteractiveLogonRight = *S-1-5-32-544,*S-1-5-32-545 >>win.inf

@Rem 配置“从网络访问此计算机”策略
echo **** 配置仅“Administrators”和“Users”用户组可从网络访问此计算机
echo SeNetworkLogonRight = *S-1-5-32-544,*S-1-5-32-545 >>win.inf

@Rem 删除可匿名访问的共享和命名管道
echo **** 将“网络访问: 可匿名访问的共享”、“网络访问: 可匿名访问的命名管道”，配置为空
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v NullSessionShares /t REG_MULTI_SZ /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v NullSessionPipes /t REG_MULTI_SZ /f

@Rem 限制匿名用户连接
echo **** 将“网络访问: 不允许 SAM 帐户和共享的匿名枚举”、“网络访问: 不允许 SAM 帐户的匿名枚举”，配置为“启用”
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v restrictanonymoussam /t REG_DWORD /d 0x00000001 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v restrictanonymous /t REG_DWORD /d 0x00000001 /f

@Rem 更改SNMP服务的默认public团体（需先安装SNMP服务，自定义password、IP）
echo **** 修改SNMP团体字为：password，指定管理端：*.*.*.*
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" /v password /t REG_DWORD /d 0x00000004 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers" /v 1 /t REG_SZ /d IP /f

@Rem 关闭Windows自动播放
echo **** 启用“关闭自动播放策略”且对所有驱动器生效
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0x000000ff /f
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0x000000ff /f

@Rem 禁止Windows自动登录
echo **** 禁止Windows自动登录
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 0 /f

@Rem 正确配置“锁定会话时显示用户信息”策略
echo **** 配置锁定会话时不显示用户信息
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DontDisplayLockedUserId /t REG_DWORD /d 0x00000003 /f

@Rem 正确配置“提示用户在密码过期之前进行更改”策略
echo **** 配置在密码过期前14天提示更改密码
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v PasswordExpiryWarning /t REG_DWORD /d 0x0000000e /f

@Rem 禁用Windows磁盘默认共享
echo **** 删除并禁用Windows磁盘默认共享
for /f "tokens=1 delims= " %%i in ('net share') do (
net share %%i /del ) >nul 2>nul
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\LanmanServer\Parameters" /v AutoShareServer /t REG_DWORD /d 0x00000000 /f
reg add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\LanmanServer\Parameters" /v AutoShareWks /t REG_DWORD /d 0x00000000 /f

@Rem 共享文件夹的权限设置（供运维人员参考）
echo **** 将共享文件夹中“Everyone(任何人)”权限删掉
for /f "tokens=2" %%i in ('net share') do (
cacls %%i /r "everyone" /e ) >nul 2>nul

@Rem 启用Windows数据执行保护(DEP)
echo **** 设置仅为基本Windows程序和服务启用DEP
@Rem Server 2008:
bcdedit /set nx OptIn
@Rem Server 2003:
@Rem /noexecute=optin

@Rem 启用“不显示最后用户名”策略
echo **** 配置登录屏幕上不要显示上次登录的用户名
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Currentversion\Policies\System" /v DontDisplayLastUserName /t REG_DWORD /d 0x00000001 /f

@Rem 启用并正确配置WSUS（自定义WSUS地址）
echo **** 启用并正确配置WSUS（自动下载并通知安装）
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 0x00000003 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoRebootWithLoggedOnUsers /t REG_DWORD /d 0x00000001 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 0x00000000 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v ScheduledInstallDay /t REG_DWORD /d 0x00000000 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v ScheduledInstallTime /t REG_DWORD /d 0x00000003 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v UseWUServer /t REG_DWORD /d 0x00000001 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v WUServer /t REG_SZ /d http://WSUS /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v WUStatusServer /t REG_SZ /d http://WSUS /f

@Rem 启用并正确配置屏幕保护程序
echo **** 启用屏幕保护程序，等待时间为5分钟，并设置在恢复时需要密码保护
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v SCRNSAVE.EXE /t REG_SZ /d C:\Windows\system32\scrnsave.scr /f
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaverIsSecure /t REG_SZ /d 1 /f
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d 300 /f

@Rem 禁用“登录时无须按 Ctrl+Alt+Del”策略
echo **** “交互式登录: 无须(不需要)按 Ctrl+Alt+Del”，配置为“已禁用(停用)”
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Currentversion\Policies\System" /v disablecad /t REG_DWORD /d 0x00000000 /f

@Rem 禁用不必要的服务
echo **** 禁用以下服务：Windows Internet Name Service (WINS)、Remote Access Connection Manager、Simple TCP/IP Services、Simple Mail Transport Protocol (SMTP) 、DHCP Client、DHCP Server、Message Queuing
wmic service where name="SimpTcp" call stopservice >nul 2>nul
sc config "SimpTcp" start= disabled >nul 2>nul
wmic service where name="SMTPSVC" call stopservice >nul 2>nul
sc config "SMTPSVC" start= disabled >nul 2>nul
wmic service where name="WINS" call stopservice >nul 2>nul
sc config "WINS" start= disabled >nul 2>nul
wmic service where name="RasMan" call stopservice >nul 2>nul
sc config "RasMan" start= disabled >nul 2>nul
wmic service where name="DHCPServer" call stopservice >nul 2>nul
sc config "DHCPServer" start= disabled >nul 2>nul
wmic service where name="DHCP" call stopservice >nul 2>nul
sc config "DHCP" start= disabled >nul 2>nul
wmic service where name="MSMQ" call stopservice >nul 2>nul
sc config "MSMQ" start= disabled >nul 2>nul

@Rem 安装最新补丁包和补丁
echo **** 检测是否安装补丁
wmic qfe get hotfixid >nul 2>nul || echo 尚未安装补丁，请安装！

@Rem 配置“用户下次登录时需更改密码”
echo **** 设置administrator（admin）用户下次登录必须更改密码
net user Administrator /logonpasswordchg:yes >nul 2>nul
net user ****_admin /logonpasswordchg:yes >nul 2>nul

echo [Version]>>win.inf
echo signature="$CHICAGO$">>win.inf
echo Revision=1 >>win.inf

secedit /configure /db win.sdb /cfg win.inf
del win.inf /q
del win.sdb /q

echo 配置完成，按任意键退出
pause
goto exit
