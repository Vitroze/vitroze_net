local VitrozeNet = {}

net = net or {}
VitrozeNet.fCallBackNetIncoming = VitrozeNet.fCallBackNetIncoming or net.Incoming
VitrozeNet.fCallBackNetReceive = VitrozeNet.fCallBackNetReceive or net.Receive
VitrozeNet.NetSpam = VitrozeNet.NetSpam or {}
VitrozeNet.NetConfig = VitrozeNet.NetSpam or {}

CreateConVar( "sv_vitroze_net_logger", 0, FCVAR_ARCHIVE, "0 : Disable, 1 : Enable All ; 2 : Enable only under a certain time games")
CreateConVar( "sv_vitroze_net_logger_time", 0, FCVAR_ARCHIVE, "Time in seconds to enable the logger")

local function Print(sText)
    MsgC( Color( 255, 0, 0 ), "[VitrozeNet] " .. sText .. "\n" )
end

local function GetTimePLAYER(pPlayer)
    if SAM then
        

    elseif ULX then
        

    elseif uTime then
        

    end

end

function net.ModifyTimeCooldown(sName, iTime)
    VitrozeNet.NetConfig[sName] = iTime

    file.Write("vitroze_net_config.txt", util.TableToJSON(VitrozeNet.NetConfig))
end

function net.Incoming( iLen, pPlayer )

    local iID = net.ReadHeader()
    local sName = util.NetworkIDToString( iID )

    local iInt = GetConVar( "sv_vitroze_net_logger" ):GetInt()

    if iInt == 1 then
        Print( " --------------------------------------------------------- ")
        Print( "NetIncoming (Incoming) : " .. sName )
        Print( "Info Player : " .. pPlayer:Nick() .. " - " .. pPlayer:SteamID() )
        Print( " --------------------------------------------------------- ")
    elseif iInt == 2 then
        local iTime = GetConVar( "sv_vitroze_net_logger_time" ):GetInt()
        if GetTimePLAYER(pPlayer) > iTime then
            Print( " --------------------------------------------------------- ")
            Print( "NetReceive (Incoming) : " .. sName )
            Print( "Info Player : " .. pPlayer:Nick() .. " - " .. pPlayer:SteamID() )
            Print( "Time Player : " .. GetTimePLAYER(pPlayer) )
            Print( "Time Net : " .. VitrozeNet.NetConfig[sName] .. "s" )
            Print( " --------------------------------------------------------- ")
        end
    end

    if VitrozeNet.NetSpam and VitrozeNet.NetSpam[pPlayer:SteamID64()] > CurTime() then
        Print(" --------------------------------------------------------- ")
        Print( "NetReceive (Incoming) : " .. sName .. " - " .. pPlayer:Nick() .. " - " .. pPlayer:SteamID() )
        Print( "Time Player : " .. VitrozeNet.NetSpam[pPlayer:SteamID64()] - CurTime() )
        Print(" Time Net : " .. VitrozeNet.NetConfig[sName] .. "s" )
        Print(" --------------------------------------------------------- ")
        return
    end

    VitrozeNet.NetSpam[pPlayer:SteamID64()] = CurTime() + VitrozeNet.NetConfig[sName] or 0.5

    VitrozeNet.fCallBackNetIncoming( iLen, pPlayer )
end