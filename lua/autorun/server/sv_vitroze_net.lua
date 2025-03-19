net = net or {}

VitrozeNet = VitrozeNet or {}
VitrozeNet.fCallBackNetIncoming = VitrozeNet.fCallBackNetIncoming or net.Incoming
VitrozeNet.fCallBackNetReceive = VitrozeNet.fCallBackNetReceive or net.Receive
VitrozeNet.NetSpam = VitrozeNet.NetSpam or {}
VitrozeNet.NetConfig = VitrozeNet.NetConfig or {}

CreateConVar( "sv_vitroze_net_logger", 1, FCVAR_ARCHIVE, " Activate only the logger when it has a spam or when the game time is less than the convar: sv_vitroze_net_logger_time")
CreateConVar( "sv_vitroze_net_saveallloger", 2, FCVAR_ARCHIVE, "0 : Disable, 1 : Enable All ; 2 : Enable only under a certain time games and Spam Protection")
CreateConVar( "sv_vitroze_net_timecooldown", 0.5, FCVAR_ARCHIVE, "Time in seconds to enable the cooldown")
CreateConVar( "sv_vitroze_net_logger_time", 60, FCVAR_ARCHIVE, "Time in minutes to enable the logger (only if sv_vitroze_net_logger is set to 2)")

local function fileLogs( sText )
    local sPath = "vitroze_net_logs.txt"

    local sRead = file.Read( sPath, "DATA" )

    if not sRead then
        file.Write( sPath, sText .. "\n" )
        return
    end

    file.Write( sPath, sRead .. sText .. "\n" )
end

local function Print( ... )
    local sText = ""

    local tMessage = { ... }
    for _, sArg in pairs( tMessage ) do
        sText = sText .. tostring( sArg ) .. " "
    end

    MsgC( Color( 255, 0, 0 ), "[VitrozeNet] " .. sText .. "\n" )

end 

local function saveLogs( sNameNet, iIDNet, pPlayer, iTime )

    local sFormatMessage = string.format([[---------------------------------------------------------
    NetReceive (Incoming) : %s - %s
    Info Player : %s - %s - %s
    Cooldown Net : %s
    Date : %s
    ]], sNameNet, iIDNet, pPlayer:Nick(), pPlayer:SteamID(), pPlayer:SteamID64(), iTime, os.date( "%H:%M:%S - %d/%m/%Y" ) )

    fileLogs( sFormatMessage )

end

local function GetTimePLAYER(pPlayer)
    if sam then
        return pPlayer:GetUTime()
    end
end

function net.ModifyTimeCooldown(sName, iTime)
    VitrozeNet.NetConfig[sName] = iTime
end

function net.Incoming( iLen, pPlayer )

    local iID = net.ReadHeader()
    local sName = util.NetworkIDToString( iID )

    if not sName or not pPlayer:IsValid() or sName:len() == 0 then
        return
    end

    local iInt = GetConVar( "sv_vitroze_net_logger" ):GetInt()
    local iIDFile = GetConVar( "sv_vitroze_net_saveallloger" ):GetInt()
    local iTime = VitrozeNet.NetConfig and isnumber(VitrozeNet.NetConfig[sName]) and VitrozeNet.NetConfig[sName] or GetConVar( "sv_vitroze_net_timecooldown" ):GetFloat()
    
    if iInt == 1 then
        Print( " --------------------------------------------------------- ")
        Print( "NetReceive (Incoming) : ", sName, " - ", iID )
        Print( "Info Player : ", pPlayer:Nick(), " - ", pPlayer:SteamID(), " - ", pPlayer:SteamID64() )
        Print( "Cooldown Net : ", tostring(iTime).."s" )
        Print( "Date : ", os.date( "%H:%M:%S - %d/%m/%Y" ) )

        if iIDFile == 1 then
            saveLogs(sName, iID, pPlayer, iTime)
        end

    elseif iInt == 2 then
        local iTime = GetConVar( "sv_vitroze_net_logger_time" ):GetInt()
        if GetTimePLAYER(pPlayer) > iTime then
            Print( " --------------------------------------------------------- ")
            Print( "NetReceive (Incoming) : ", sName, " - ", iID, "ALERT TIMER" )
            Print( "Info Player : ", pPlayer:Nick(), " - ", pPlayer:SteamID(), " - ", pPlayer:SteamID64() )
            Print( "Time Player : ", GetTimePLAYER(pPlayer) )
            Print( "Cooldown Net : ", tostring(iTime).."s" )
            Print( "Date : ", os.date( "%H:%M:%S - %d/%m/%Y" ) )

            if iIDFile != 0 then
                saveLogs(sName, iID, pPlayer, iTime)
            end
        end
    end

    if VitrozeNet.NetSpam and VitrozeNet.NetSpam[pPlayer:SteamID64()] and VitrozeNet.NetSpam[pPlayer:SteamID64()][sName:lower()] and VitrozeNet.NetSpam[pPlayer:SteamID64()][sName:lower()] > CurTime() then
        Print("--------------------------------------------------------- ")
        Print( "NetReceive (Incoming) : ", sName, " - ", iID, "SPAM PROTECTION")
        Print( "Info Player : ", pPlayer:Nick(), " - ", pPlayer:SteamID(), " - ", pPlayer:SteamID64() )
        Print( "Time Player (Cooldown Net): ", math.Round(VitrozeNet.NetSpam[pPlayer:SteamID64()][sName:lower()] - CurTime(), 2), "s" )
        Print( "Cooldown Net : ", tostring(iTime).."s" )
        Print( "Date : ", os.date( "%H:%M:%S - %d/%m/%Y" ) )

        if iIDFile != 0 then
            saveLogs(sName, iID, pPlayer, iTime)
        end

        return
    end


    VitrozeNet.NetSpam[pPlayer:SteamID64()] = VitrozeNet.NetSpam[pPlayer:SteamID64()] or {}
    VitrozeNet.NetSpam[pPlayer:SteamID64()][sName:lower()] = CurTime() + iTime

    local fCallback = net.Receivers[ sName:lower() ]

    iLen = iLen - 16

    if fCallback then
        fCallback( iLen, pPlayer )
    end

end

function net.Receive( sName, fCallback, iCooldown )
    VitrozeNet.fCallBackNetReceive( sName, fCallback )

    if iCooldown then
        net.ModifyTimeCooldown(sName, iCooldown)
    end
end