--[[
        Copyright © 2020, SirEdeonX, Akirane, Technyze
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of xivhotbar nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX OR Akirane BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local action_manager = require('lib/action_manager')
local player = {}

player.name = ''
player.main_job = ''
player.sub_job = ''

player.main_job_level = 0
player.sub_job_level = 0
player.vitals = {}
player.vitals.mp = 0
player.vitals.tp = 0
player.id = 0
player.current_weapon = 0
player.current_range_weapon = 0

local debug = false

function player:get_current_weapontype()
    return current_weaponskill
end

function player:get_hotbar_info()
    local hotbar = action_manager.hotbar
    local active_environment = action_manager.hotbar_settings.active_environment
    local vitals = windower.ffxi.get_player().vitals
    return hotbar, active_environment, vitals
end

-- initialize player
function player:initialize(windower_player, theme_options)
    self.name           = windower_player.name
    self.main_job       = windower_player.main_job
    self.sub_job        = windower_player.sub_job
    self.main_job_level = windower_player.main_job_level
    self.sub_job_level  = windower_player.sub_job_level
    self.buffs          = windower_player.buffs
    self.id             = windower_player.id
    self.vitals.mp      = windower_player.vitals.mp
    self.vitals.tp      = windower_player.vitals.tp
    action_manager:initialize(theme_options)
    action_manager:update_file_path(player.name, player.main_job)
    for _, id in pairs(windower_player.buffs) do
        print(id)
        if id == 358 then
            action_manager:update_stance(211)
        elseif id == 359 then
            action_manager:update_stance(212)
        end
    end
end

function player:remove_action(remove_table)
    action_manager:remove_action(self, remove_table)
end

-- update player jobs
function player:update_job(main, sub)
    self.main_job = main
    self.sub_job = sub
    action_manager:update_file_path(player.name, player.main_job)
end

-- update player level
function player:update_level(main_level, sub_level)
    self.main_job_level = main_level
    self.sub_job_level = sub_level
end

function player:get_main_job_level()
    return windower_player.main_job_level
end

-- load hotbar for current player and job combination
function player:load_hotbar()
    action_manager:reset_hotbar()
    action_manager:load(self)
end

function player:swap_actions(swap_table)
    action_manager:swap_actions(player, swap_table)
end

function player:update_weapon_type(skill_type)
    player.current_weapon = skill_type
end

function player:update_range_weapon_type(skill_type)
    player.current_range_weapon = skill_type
end

function player:load_job_ability_actions(buff_id)
    action_manager:update_stance(buff_id)
    action_manager:load(self)
end

-- toggle bar environment
function player:toggle_environment()
    action_manager:toggle_environment()
end

-- set bar environment to battle
function player:set_battle_environment(in_battle)
    local environment = 'field'
    if in_battle then environment = 'battle' end

    action_manager.hotbar_settings.active_environment = environment
end

-- change active hotbar
function player:change_active_hotbar(new_hotbar)
    action_manager:change_active_hotbar(new_hotbar)
end

function player:insert_action(args)
    action_manager:insert_action(player.sub_job, args)
end

function player:determine_summoner_id(pet_name)
    for buff_id, buff_name in pairs(buff_table) do
        if buff_name == pet_name then
            return buff_id
        end
    end
    return 0
end

function player:get_active_hotbar()
    return action_manager.hotbar_settings.active_hotbar
end

-- execute action from given slot
function player:execute_action(slot)
    action = action_manager:get_action(slot)
    if not action then return end

    local command = windower.to_shift_jis(action.action)
    command = command:gsub(string.char(0x5C), string.char(0x5C, 0x5C, 0x5C))
    if action.type == 'ct' then
        local command = '/' .. action.action
        if action.target ~= nil and action.target ~= "" then
            command = command .. ' <' .. action.target .. '>'
        end
        windower.chat.input(command)
        return
    elseif action.type == 'macro' then -- Single line macro in the JOB.lua file. Seperated by semicolons.
        windower.chat.input('//' .. command)
    elseif action.type == 'gs' then -- Gear Swap
        windower.chat.input('//gs ' .. command)
    elseif action.type == 's' then
        windower.chat.input('//send ' .. command)
    elseif action.type == 'input' then
        windower.chat.input('//input ' .. command)
    else
        windower.chat.input('/' ..
        action.type .. ' "' .. command .. '" <' .. action.target .. '>')                            -- This is for JA, WS and MA
    end
end

return player
