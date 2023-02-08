mt_teams = {}
local storage = minetest.get_mod_storage()
mt_teams.colors ={
    black='#2b2b2b',
    blue='#0063b0',
    brown='#8c5922',
    cyan='#07B6BC',
    dark_green='#567a42',
    dark_grey='#6d6d6d',
    green='#4ee34c',
    grey='#9f9f9f',
    magenta='#ff0098',
    orange='#ff8b0e',
    pink='#ff62c6',
    red='#dc1818',
    violet='#a437ff',
    white='#FFFFFF',
    yellow='#ffe400',
}
mt_teams.teams = {
    {
        color=mt_teams.colors.orange,
        owner='singplayer',
        name='base',
        members={},
        id=#mt_teams.teams+1
    }
}

function mt_teams.load_teams()
    mt_teams.teams = minetest.deserialize(storage:get_string('mt_teams:table'))
end
function mt_teams.save_teams()
    storage:set_string('mt_teams:table', minetest.serialize(mt_teams.teams))
end

function mt_teams.get_team_id(player)
    local meta = player:get_meta()
    return meta:get_int("mt_teams:team")
end

function mt_teams.get_team_name(player)
    local team_id = mt_teams.get_team_id(player)
    return mt_teams.get_team_name_by_id(team_id)
end

function mt_teams.get_team_name_by_id(id)
    return mt_teams.teams[id].name
end
function mt_teams.remove_player(player)--removes player and if not there returns false
    local name = player:get_player_name()
    local team = mt_teams.get_team_id(player)
    local i = 1
    local found = false
    for key, val in pairs(mt_teams.teams[team].members) do
        if val==name then
            found =true
            break
        end
        i = i+1
    end
    if found then
        table.remove(mt_teams.teams[team].members, i)
        return true
    end
    return false
end

function mt_teams.set_team(player,team)
    local meta = player:get_meta()
    if meta:get_int('mt_teams:team') ~= nil then
        -- So that's it, we just remove them... hmm
        local r = mt_teams.remove_player(player)
        if r == false then
            minetest.chat_send_player(player:get_player_name(), "Not listed in "..mt_teams.get_team_name(player).."'s members")
        --no way to get rid of members in a team so for now... no changing
        end
    end
    if mt_teams.teams[team] ~= nil then
        meta:set_int('mt_teams:team', team)
        table_insert(mt_teams.teams[team].members, player:get_player_name())
        local color = mt_teams.teams[team].color
        local name = mt_teams.teams[team].name
        minetest.chat_send_all(string.format("*** %s joined team "..minetest.colorize(color, name), minetest.colorize(color, player:get_player_name())))
    else
        minetest.chat_send_player(player:get_player_name(), "Team doesnt appear to exist")
    end
end

function mt_teams.create_team(player, name, color)
    local meta = player:get_meta()
    meta:set_int('mt_teams:team', #mt_teams.teams)
    table.insert_all(mt_teams.teams,
        {color=color,
        owner=player,
        name=name,
        id=#mt_teams.teams+1
    })
    mt_teams.save_teams()
end

minetest.register_on_mods_loaded(function()
    mt_teams.load_teams()
end)

minetest.register_on_joinplayer(function(player, last_login)
    local meta = player:get_meta()
    if meta:contains('mt_teams:team') == false then
        math.randomseed(100)
        local rand = math.ceil((math.random()*#mt_teams.teams))
        mt_teams.set_team(player, rand)
        minetest.chat_send_player(player:get_player_name(), mt_teams.teams[rand].name)
    end
end
)
