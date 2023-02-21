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
mt_teams.teams = {{color=mt_teams.colors.orange,
        owner='singleplayer',
        name='base',
        members={},
        id=mt_teams.teams_num
    }}
mt_teams.teams_num = 1
players = {}

function mt_teams.load_teams()
    local des = minetest.deserialize(storage:get_string('mt_teams:table'))
    mt_teams.teams_num = storage:get_float('mt_teams:num')
    if des ~= nil then
       mt_teams.teams = des
    end
end
function mt_teams.save_teams()
    storage:set_float('mt_teams:is_in_here_somewhere', 1)
    mt_teams.teams_num = storage:get_float('mt_teams:num')

    storage:set_string('mt_teams:table', minetest.serialize(mt_teams.teams))
end

function mt_teams.get_team(player)
    local meta = player:get_meta()
    return meta:get_float("mt_teams:team")
end
local get_team = mt_teams.get_team
function mt_teams.get_team_name(player,for_cmd)
    name = mt_teams.get_name_id(get_team(player))
    if for_cmd then
        return 'You are on the '..name..' team'
    else
        return name
    end
end
function mt_teams.get_name_id(id)
    return mt_teams.teams[id].name
end
function mt_teams.remove_player(player)--removes player and if not there returns false
    local name = player:get_player_name()
    local team = get_team(player)
    i = 1
    if team ~= 0 then
        if mt_teams.teams[team].members ~= nil then
            for key, val in mt_teams.teams[team].members do
                if val==name then mt_teams.teams[team].members.remove(i) return true
                else i = i+1 end
            end
        end
    end
    return false
end
function mt_teams.set_team(player,team)
    local meta = player:get_meta()
    if meta:get_float('mt_teams:team') ~= nil then
        --local r = mt_teams.remove_player(player)
        --if r == false then
        --    minetest.chat_send_player(player:get_player_name(), "Not listed in "..mt_teams.get_team_name(player).."'s members")
        --no way to get rid of members in a team so for now... no changing
    end 
    if mt_teams.teams[team] ~= nil then
        meta:set_float('mt_teams:team', team)

        table.insert_all(mt_teams.teams[team].members,player:get_player_name())
        minetest.chat_send_all(string.format("*** %s joined team "..minetest.colorize(mt_teams.teams[meta:get_float("mt_teams:team")].color,mt_teams.teams[team].name),minetest.colorize(mt_teams.teams[meta:get_float("mt_teams:team")].color, player:get_player_name())))
    else
        minetest.chat_send_player(player:get_player_name(), "Team doesnt appear to exist")
    end
end
function mt_teams.create_team(player, name, color)
    mt_teams.teams_num = mt_teams.teams_num+1
    local meta = player:get_meta()
    meta:set_float('mt_teams:team', mt_teams.teams_num)
    meta:set_bool('mt_teams:is_owner', true)
    meta:set_string('mt_teams:name', name)
    table.insert_all(mt_teams.teams, 
        {color=color,
        owner=player:get_player_name(),
        name=name,
        members={},
        id=mt_teams.teams_num
    })
    mt_teams.set_team(player, mt_teams.teams_num)
    mt_teams.save_teams()
    return name..' team created with '..minetest.colorize(color,color)..' color'
end
function simple_cmd(name,description,func_)
    minetest.register_chatcommand(name, {
        description=description,
        privs = {
            interact = true,
        },
        func = func_
})
end

--Chats cmds
simple_cmd('get_team','Get the name of the team you are on',function(name) 
    local player = minetest.get_player_by_name(name)
    return true, mt_teams.get_team_name(player,true)
end)
minetest.register_chatcommand('create_team', {
    description='Create a team(with a random color) and join it',
    privs={interact=true},
    params = 'name',
    func = function(name,param)
        local t_name = param
        local color = ''
        math.randomseed(100)
        local rand = math.ceil((math.random()*mt_teams.teams_num))
        color = mt_teams.colors[rand+1]
        if t_name == (nil or '') then return false, 'Need to provide a valid name'
        else return true, mt_teams.create_team(minetest.get_player_by_name(name),t_name,color) end
    end}
)
minetest.register_chatcommand('list_teams', {
    description = 'List all created teams',
    privs={interact=true},
    func = function(name)
        for val in mt_teams.teams do
            minetest.chat_send_player(name, minetest.colorize(val.color, val.name)..' owned by '..val.owner..' id: '..val.id)
        end
    end
})
minetest.register_chatcommand('list_team_members',{
    description = 'List the members a the team specified in the command',
    privs={interact=true},
    params = 'team id',
    func = function(name,param)
        local team = mt_teams.teams[tonumber(param)]
        local membs = team.members
        for key, val in membs do
            minetest.chat_send_player(name, minetest.colorize(team.color, val))
        end
    end

})
--minetest functions
function test_ls()
    --mt_teams.load_teams()
    if storage:contains('mt_teams:is_in_here_somewhere') == true then
        mt_teams.load_teams()
    else
        mt_teams.save_teams()
    end
end
minetest.register_on_joinplayer(function(player, last_login)
    local meta = player:get_meta()
    local team = meta:get_float('mt_teams:team')
    if mt_teams.teams[1] == nil then
        test_ls()
    end
    if team == 0 then
        local rand = 1
        mt_teams.set_team(player, rand)
        minetest.chat_send_player(player:get_player_name(), mt_teams.teams[rand].name)
    else
        mt_teams.set_team(player, team)
        minetest.chat_send_player(player:get_player_name(), mt_teams.teams[team].name)
    end
end
)
