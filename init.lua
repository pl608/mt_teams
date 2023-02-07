mt_teams = {}
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
players = {}



minetest.register_on_joinplayer(function(player, last_login)
    local name_ = player:get_player_name()
    math.randomseed()
    players[name_] = mt_teams.colors[math.floor((math.random()*15))]
    minetest.chat_send_all(string.format("*** %s joined the game.",
					minetest.colorize(players[name_], name_))
				)
end
)

function mt_teams.get_team(player)

end
function mt_teams.set_team(player,team)

end