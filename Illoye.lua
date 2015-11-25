if myHero.charName ~= "Illaoi" then return end

require 'VPrediction'


local version = .01
local SCRIPT_NAME = "Illoye"




-------------------------------------------------

local ts
local target
local menu
local VP = nil
local Qrange, Wrange, Erange, Rrange = 800, 1, 900, 450
local Qready, Wready, Eready, Rready = false


function OnLoad()
   
    jungleMinions = minionManager(MINION_JUNGLE, Qrange, myHero, MINION_SORT_MAXHEALTH_DEC)
    EnemyMinions = minionManager(MINION_ENEMY, Qrange, myHero, MINION_SORT_MAXHEALTH_DEC)
    print("<font color=\"#f44d5e\"><b>" .."-- Illoye has been loaded --")
    print("<font color=\"#b6fcd5\"><b>" .."ALPHA: PLEASE REPORT BUGS TO FREEZIEPOPZ. Enjoy!")
    ts = TargetSelector(TARGET_NEAR_MOUSE, 1000, DAMAGE_PHYSICAL)
    
    menu = scriptConfig("Illoye", "Illoye")
    VP = VPrediction()
  
    
    
    
    menu:addSubMenu("Illoye: Combo", "Combo")
      menu.Combo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
      menu.Combo:addParam("useQ", "Use Q-Spell", SCRIPT_PARAM_ONOFF, true)
      menu.Combo:addParam("useW", "Use W-Spell", SCRIPT_PARAM_ONOFF, true)
      menu.Combo:addParam("useE", "Use E-Spell", SCRIPT_PARAM_ONOFF, true)
	  menu.Combo:addParam("combo1", "Combo", SCRIPT_PARAM_LIST, 2, { "Q>W>E", "E>W>Q" })
	
    menu:addSubMenu("Illoye: Harass", "Harass")
      menu.Harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
      menu.Harass:addParam("autoharass", "Auto Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("Z"))
      menu.Harass:addParam("percenthp", "Don't Harass lower than %HP", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
    
    menu:addSubMenu("Illoye: Lane Clear", "lane")
      menu.lane:addParam("lanekey", "Lane Clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
      menu.lane:addParam("useQ", "Use Q-Spell", SCRIPT_PARAM_ONOFF, true)
      menu.lane:addParam("useW", "Use W-Spell", SCRIPT_PARAM_ONOFF, true)
    
    
    menu:addSubMenu("Illoye: Jungle Clear", "jungle")
      menu.jungle:addParam("junglekey", "Lane Clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
      menu.jungle:addParam("useQ", "Use Q-Spell", SCRIPT_PARAM_ONOFF, true)
      menu.jungle:addParam("useW", "Use W-Spell", SCRIPT_PARAM_ONOFF, true)
      
    
    menu:addSubMenu("Illoye: MISC", "extra")
      menu.extra:addParam("KS", "Killsteal using Q", SCRIPT_PARAM_ONOFF, true)
      menu.extra:addParam("Qrange", "Q Range Slider", SCRIPT_PARAM_SLICE, 800, 1, 800, 0)
	  menu.extra:addParam("Erange", "E Range Slider", SCRIPT_PARAM_SLICE, 900, 1, 900, 0)
      menu.extra:addParam("ultset", "Use Ult in Combo", SCRIPT_PARAM_ONOFF, true) 
      menu.extra:addParam("numchamps", "Cast When _ Champs", SCRIPT_PARAM_SLICE, 2, 0, 5, 0) 
     
    
    menu:addSubMenu("Illoye: Drawing", "drawings")
      menu.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, false)
      menu.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	  menu.drawings:addParam("drawCircleE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
      
    menu:addSubMenu("Illoye: Target Selector", "targetSelector")
      menu.targetSelector:addTS(ts)

end

function OnTick()
    ts:update()
    target = ts.target
    EnemyMinions:update()
    jungleMinions:update()
    
    
   
    
   
    
    if menu.extra.KS then
        Killsteal()
    end
    
    if menu.Combo.combo then
		if menu.Combo.combo1 == 2 then
		Combo2()
		else
	
        Combo()
		end
    end
    
    if menu.Harass.harass then
        Harass()
    end
    
    if menu.jungle.junglekey then
        JungleClear()
    end
    
    if menu.lane.lanekey then
        LaneClear()
    end
    
    if menu.Harass.autoharass and not menu.Combo.combo then
        AutoHarass()
    end
    
 
	
    

    Qready = (myHero:CanUseSpell(_Q) == READY)
    Wready = (myHero:CanUseSpell(_W) == READY)
    Eready = (myHero:CanUseSpell(_E) == READY)
    Rready = (myHero:CanUseSpell(_R) == READY)
end

function Killsteal()
    for i, enemy in pairs (GetEnemyHeroes()) do
        if Qready and ValidTarget(enemy, Qrange, true) and enemy.health < getDmg("Q",enemy,myHero) + 30 then
            if menu.extra.prediction then
                local pos, info = VP.GetPrediction(target, menu.extra.Qrange, 1500, 0.5, 75)
                if pos and info.hitchance >= 2 and GetDistance(pos) < Qrange then
                    CastSpell(_Q, pos.x, pos.z)
                end
            else
                local CastPosition, HitChance, Position = VP:GetLineCastPosition(target, 0.5, 75, menu.extra.Qrange, 1500, myHero, true)
                if GetDistance(CastPosition) < Qrange and HitChance >= 2 then
                    CastSpell(_Q, CastPosition.x, CastPosition.z)
                end
            end
        end
    end
	
end

function Harass()
    if ValidTarget(target, Qrange) and Qready then
        for i, target in pairs(GetEnemyHeroes()) do
            if menu.extra.prediction then
                local pos, info = VP.GetPrediction(target, menu.extra.Qrange, 1500, 0.5, 75)
                if pos and info.hitchance >= 2 and GetDistance(pos) < Qrange then
                    CastSpell(_Q, pos.x, pos.z)
                end
            else
                local CastPosition, HitChance, Position = VP:GetLineCastPosition(target, 0.5, 75, menu.extra.Qrange, 1500, myHero, true)
                if GetDistance(CastPosition) < Qrange and HitChance >= 2 then
                    CastSpell(_Q, CastPosition.x, CastPosition.z)
                end
            end
        end
    end
	if menu.Combo.useW and Wready and CountEnemies(Wrange, myHero) ~= nil and target ~= nil then     
	   CastSpell(_W, target)
		
     end
end

function AutoHarass()
    if ValidTarget(target, Qrange) and Qready then
      if myHero.health < (myHero.maxHealth*(menu.Harass.percenthp*0.01)) then return end
        for i, target in pairs(GetEnemyHeroes()) do
            if menu.extra.prediction then
                local pos, info = VP.GetPrediction(target, menu.extra.Qrange, 1500, 0.5, 75)
                if pos and info.hitchance >= 2 and GetDistance(pos) < Qrange then
                    CastSpell(_Q, pos.x, pos.z)
                end
            else
                local CastPosition, HitChance, Position = VP:GetLineCastPosition(target, 0.5, 75, menu.extra.Qrange, 1500, myHero, true)
                if GetDistance(CastPosition) < Qrange and HitChance >= 2 then
                    CastSpell(_Q, CastPosition.x, CastPosition.z)
                end
            end
        end
    end
	if menu.Combo.useW and Wready and CountEnemies(Wrange, myHero) ~= nil and target ~= nil then     
	   CastSpell(_W, target)
		
     end
end
function Combo2()
	if ValidTarget(target, Erange) and Eready and menu.Combo.useE then
        for i, target in pairs(GetEnemyHeroes()) do
            if menu.extra.prediction then
                local pos, info = VP.GetPrediction(target, menu.extra.Erange, 1500, 0.5, 75)
                if pos and info.hitchance >= 2 and GetDistance(pos) < Erange then
                    CastSpell(_E, pos.x, pos.z)
                end
            else
                local CastPosition, HitChance, Position = VP:GetLineCastPosition(target, 0.5, 75, menu.extra.Erange, 1500, myHero, true)
                if GetDistance(CastPosition) < Erange and HitChance >= 2 then
                    CastSpell(_E, CastPosition.x, CastPosition.z)
                end
            end
        end
    end
	if menu.Combo.useW and Wready and CountEnemies(Wrange, myHero) ~= nil and target ~= nil then     
	   CastSpell(_W, target)
		
     end
   if ValidTarget(target, Qrange) and Qready and menu.Combo.useQ then
        for i, target in pairs(GetEnemyHeroes()) do
            if menu.extra.prediction then
                local pos, info = VP.GetPrediction(target, menu.extra.Qrange, 1500, 0.5, 75)
                if pos and info.hitchance >= 2 and GetDistance(pos) < Qrange then
                    CastSpell(_Q, pos.x, pos.z)
                end
            else
                local CastPosition, HitChance, Position = VP:GetLineCastPosition(target, 0.5, 75, menu.extra.Qrange, 1500, myHero, true)
                if GetDistance(CastPosition) < Qrange and HitChance >= 2 then
                    CastSpell(_Q, CastPosition.x, CastPosition.z)
                end
            end
        end
    end
    
if menu.extra.ultset and Rready and CountEnemies(Rrange, myHero) >= menu.extra.numchamps and target ~= nil then
	
	CastSpell(_R)
	end
end	

function Combo()
    if ValidTarget(target, Qrange) and Qready and menu.Combo.useQ then
        for i, target in pairs(GetEnemyHeroes()) do
            if menu.extra.prediction then
                local pos, info = VP.GetPrediction(target, menu.extra.Qrange, 1500, 0.5, 75)
                if pos and info.hitchance >= 2 and GetDistance(pos) < Qrange then
                    CastSpell(_Q, pos.x, pos.z)
                end
            else
                local CastPosition, HitChance, Position = VP:GetLineCastPosition(target, 0.5, 75, menu.extra.Qrange, 1500, myHero, true)
                if GetDistance(CastPosition) < Qrange and HitChance >= 2 then
                    CastSpell(_Q, CastPosition.x, CastPosition.z)
                end
            end
        end
    end
    
	if menu.Combo.useW and Wready and CountEnemies(Wrange, myHero) ~= nil and target ~= nil then     
	   CastSpell(_W, target)
		
     end
  
	
    if ValidTarget(target, Erange) and Eready and menu.Combo.useE then
        for i, target in pairs(GetEnemyHeroes()) do
            if menu.extra.prediction then
                local pos, info = VP.GetPrediction(target, menu.extra.Erange, 1500, 0.5, 75)
                if pos and info.hitchance >= 2 and GetDistance(pos) < Erange then
                    CastSpell(_E, pos.x, pos.z)
                end
            else
                local CastPosition, HitChance, Position = VP:GetLineCastPosition(target, 0.5, 75, menu.extra.Erange, 1500, myHero, true)
                if GetDistance(CastPosition) < Erange and HitChance >= 2 then
                    CastSpell(_E, CastPosition.x, CastPosition.z)
                end
            end
        end
    end

if menu.extra.ultset and Rready and CountEnemies(Rrange, myHero) >= menu.extra.numchamps and target ~= nil then
	
	CastSpell(_R)
	end
end

function LaneClear()
    if jungleMinion == nil then
        for i, minion in ipairs(EnemyMinions.objects) do
            if minion ~= nil then
                if GetDistance(minion) < Qrange and menu.lane.useQ then
                    if menu.extra.prediction then
                        local pos, info = VP.GetPrediction(minion, menu.extra.Qrange, 1500, 0.5, 75)
                        if pos and info.hitchance ~= 0 and GetDistance(pos) < menu.extra.Qrange then
                            CastSpell(_Q, pos.x, pos.z)
                        end
                    else
                        local CastPosition, HitChance, Position = VP:GetLineCastPosition(minion, 0.5, 75, menu.extra.Qrange, 1500, myHero, true)
                        if GetDistance(CastPosition) < Qrange and HitChance >= 2 then
                            CastSpell(_Q, CastPosition.x, CastPosition.z)
                        end
                    end
                end
                if menu.lane.useW and GetDistance(minion) < Wrange and Wready  then
                    CastSpell(_W)
                end
                
            end
        end
    end
end

function CountEnemies(range, unit)
    local Enemies = 0
    for _, enemy in ipairs(GetEnemyHeroes()) do
        if ValidTarget(enemy) and GetDistance(enemy, unit) < (range or math.huge) then
            Enemies = Enemies + 1
        end
    end
    return Enemies
end


function JungleClear()
    for i, jungleMinion in pairs(jungleMinions.objects) do
        if jungleMinion ~= nil then
            if GetDistance(jungleMinion) < Qrange and menu.jungle.useQ then
                if menu.extra.prediction then
                    local pos, info = VP.GetPrediction(jungleMinion, menu.extra.Qrange, 1500, 0.5, 75, true)
                    if pos and info.hitchance >= 2 and GetDistance(pos) < Qrange then
                        CastSpell(_Q, pos.x, pos.z)
                    end
                else
                    local CastPosition, HitChance, Position = VP:GetLineCastPosition(jungleMinion, 0.5, 75, menu.extra.Qrange, 1500, myHero, true)
                    if GetDistance(CastPosition) < Qrange and HitChance >= 2 then
                        CastSpell(_Q, CastPosition.x, CastPosition.z)
                    end
                end
            end
            if menu.jungle.useW and GetDistance(jungleMinion) < Wrange and not WActive and Wready then
                CastSpell(_W)
            end
            if menu.jungle.useE and Eready and GetDistance(jungleMinion) < Erange then CastSpell(_E) end 
        end
    end
end


function UnitAtTower(unit,offset)
  for i, turret in pairs(GetTurrets()) do
    if turret ~= nil then
      if turret.team == myHero.team then
        if GetDistance(unit, turret) <= turret.range+offset then
          return true
        end
      end
    end
  end
  return false
end




function OnDraw()
  if myHero.dead then return end
  
  if menu.drawings.drawCircleAA then
    DrawCircle(myHero.x, myHero.y, myHero.z, 125, ARGB(255, 0, 255, 0))
  end

  if menu.drawings.drawCircleQ then
    DrawCircle(myHero.x, myHero.y, myHero.z, menu.extra.Qrange, 0x111111)
  end
   if menu.drawings.drawCircleE then
    DrawCircle(myHero.x, myHero.y, myHero.z, menu.extra.Erange, 581047)--0x111111
  end
end



