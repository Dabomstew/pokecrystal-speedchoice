CheckBadgeItems::
        readvar VAR_BADGES
        ifequal 7, .RadioTowerRockets
        ifequal 6, .GoldenrodRockets
        end

.GoldenrodRockets:
        jumpstd GoldenrodRocketsScript
	end

.RadioTowerRockets:
        jumpstd RadioTowerRocketsScript	
	end
