cls;$cd = $PSScriptRoot;if ($psise){$cd = ($psise.CurrentFile.FullPath | split-path -Parent);cls};cd $cd;$v=1.2
while (!$Quit) {cls;start-sleep -milliseconds 100;
    #region UI
        "Sky3ds+ Navigation Aid $v" | Write-host -f Cyan -NoNewline;"`t`tBy Mcgrog [2020]" | Write-host -f DarkCyan;
        "  Operation Instructions:`n`t - Enter`n`t`t- Get Directions`n`t - Type 'R' + Enter to:`n`t`t - Create New/Refresh '02_Games.xml'`n`t`t - Then Get Directions`n`t - Type 'Q' + Enter to:`n`t`t - Quit"|Write-host -f DarkGray
        if ($LeftClicksMessage -or $RightClicksMessage) {
            "`nShortest Path From: $($CurrentGame.Position) To: $($DestinationGame.Position) Of: $($Games.Count)" | Write-host -f Gray
            $LeftClicksMessage | write-host -f Yellow
            $RightClicksMessage | write-host -f Green
        } elseif ($WarningMessage) {Write-Warning $WarningMessage}
        $LeftClicksMessage = $RightClicksMessage = $WarningMessage = $null
        $Input = Read-Host "`nType Modifier/Hit Enter to Continue"
    #endregion
    
    switch -w ($Input) {
        q {$Quit=$true;break}
        r { # Get Rom List from FAT32 USB Device
            $TargetDrive = @(gwmi Win32_logicaldisk | ? {$_.drivetype -eq 2 -and $_.filesystem -eq 'FAT32'} | select 'VolumeName','DeviceID',@{n='Capacity';e={($_.size/1gb).tostring('0.00 GB')}},@{n='Free Space';e={($_.freespace/1gb).tostring('0.00 GB')}},@{n='% Full';e={((1-($_.freespace/$_.size))*100).tostring('0.00')}} | ogv -t "Select Drive To Create New 02_Games.xml or Close To Use Existing 02_Games.xml" -PassThru)[0]
            if($TargetDrive){
                $Games = gci $TargetDrive.DeviceID | ? {$_.name -like "*.3ds"} | select * | sort Name
                # Format with For Use In Navigation & Save File for later use
                if($Games){
                    $Games = $Games | select `
                         @{n='Position'        ;e={[array]::indexof($Games,$_)+1}} `
                        ,@{n='Name'            ;e={$_.BaseName}} `
                        ,@{n='Trimmed'         ;e={$_.length % 0.125gb -ne 0}} `
                        ,@{n='Size (MB)'       ;e={[int]$(($_.length/1MB).tostring('0'))}} `
                        ,@{n='ConfigCreated'   ;e={test-path "$($TargetDrive.DeviceID)\$($_.BaseName).cfg"}} `
                        ,@{n='SaveCreated'     ;e={test-path "$($TargetDrive.DeviceID)\$($_.BaseName).sav"}} `
                        | select *, `
                         @{n='Save Size (KB)'  ;e={if ($_.SaveCreated  ){((get-item "$($TargetDrive.DeviceID)\$($_.Name).sav" -ea ig).Length/1KB).tostring('0')}}} `
                        ,@{n='Config Size (B)' ;e={if ($_.ConfigCreated){((get-item "$($TargetDrive.DeviceID)\$($_.Name).cfg" -ea ig).Length).tostring('0')}}} `
                        ,@{n='CART_ID'         ;e={if ($_.ConfigCreated){((gc "$($TargetDrive.DeviceID)\$($_.Name).cfg").split("`r`n") | ? {$_ -like 'CART_ID*'     }).split('=')[1]}}} `
                        ,@{n='ENC_TYPE'        ;e={if ($_.ConfigCreated){((gc "$($TargetDrive.DeviceID)\$($_.Name).cfg").split("`r`n") | ? {$_ -like 'ENC_TYPE*'    }).split('=')[1]}}} `
                        ,@{n='ENC_SEED'        ;e={if ($_.ConfigCreated){((gc "$($TargetDrive.DeviceID)\$($_.Name).cfg").split("`r`n") | ? {$_ -like 'ENC_SEED*'    }).split('=')[1]}}} `
                        ,@{n='FLASH_ID'        ;e={if ($_.ConfigCreated){((gc "$($TargetDrive.DeviceID)\$($_.Name).cfg").split("`r`n") | ? {$_ -like 'FLASH_ID*'    }).split('=')[1]}}} `
                        ,@{n='GAMESAVE_KEY'    ;e={if ($_.ConfigCreated){((gc "$($TargetDrive.DeviceID)\$($_.Name).cfg").split("`r`n") | ? {$_ -like 'GAMESAVE_KEY*'}).split('=')[1]}}} 
                    $Games | Export-Clixml .\02_Games.xml -Force
                }
            }
        }
        * { try{# Import Existing Data if None
                if (!$Games){$Games = Import-Clixml .\02_Games.xml -ea stop}
                #region Calculate Shortest Path Between Two Roms
                    $CurrentGame     = @($Games | ogv -PassThru -t "Select Current Game")[0]
                    if ($CurrentGame) {
                        $DestinationGame = @($Games | ? {$_ -ne $CurrentGame} | ogv -PassThru -t "Select Destination - Current Game$CurrentGame")[0]
                        if ($DestinationGame.Position -gt $CurrentGame.Position) {
                            $LeftClicks  = $Games.Count - $DestinationGame.Position + $CurrentGame.Position
                            $RightClicks = $DestinationGame.Position - $CurrentGame.Position
                            switch((@($LeftClicks,$RightClicks) | Measure-Object -Minimum).minimum) {
                                $LeftClicks  {$LeftClicksMessage = "$LeftClicks Left Clicks"}
                                $RightClicks {$RightClicksMessage = "$RightClicks Right Clicks"}
                            }
                        } elseif ($DestinationGame.Position -lt $CurrentGame.Position) {
                            $LeftClicks  = $CurrentGame.Position - $DestinationGame.Position
                            $RightClicks = $Games.Count - $CurrentGame.Position + $DestinationGame.Position
                            switch((@($LeftClicks,$RightClicks) | Measure-Object -Minimum).minimum) {
                                $LeftClicks  {$LeftClicksMessage = "$LeftClicks Left Clicks"}
                                $RightClicks {$RightClicksMessage = "$RightClicks Right Clicks"}
                            }
                        }
                    }
                #endregion
            } catch {$WarningMessage = "No '02_Games.xml' Discovered"}
        }
    }
}