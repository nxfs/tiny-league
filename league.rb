def pause
	 # gets()
	 # sleep(1)
end

def print_score(score, ht, comment=nil)
	if (ht == 0 || score[1][0] + score[1][1] == 0)
		puts "#{score[0][0]}:#{score[0][1]} #{comment}"
	else
		puts "#{score[1][0]}:#{score[1][1]} (#{score[0][0]}:#{score[0][1]}) #{comment}"
	end
end

def game(teams, home_advantage)
	mins = (Random.rand * 8).floor + 90
	score = [[0, 0],[0 ,0]]
	ht = 0
	(1..mins).each do |min|
		attacking_team = Random.rand * (teams[0].midfield + teams[1].midfield + home_advantage) < (teams[0].midfield + home_advantage) ? 0 : 1
	  	coeff = 38 * teams[1 - attacking_team].defense / teams[attacking_team].attack
		goal = Random.rand < (1.0 / coeff)
		if goal
			score[ht][attacking_team] = score[ht][attacking_team] + 1
			print_score(score, ht, "#{min}'")
			pause
		end
		if (min == 45)
			print_score(score, ht, "HT")
			pause
			ht = 1
			score[1][0] = score[0][0]
			score[1][1] = score[0][1]
		end
	end
	print_score(score, ht, "FT")
	pause
	score[1]
end

def print_table(teams)
	rank = 1
	teams.sort do |t1, t2|
		diff = t2.pts - t1.pts
		diff = (t2.bp - t2.bc) - (t1.bp - t1.bc) if diff == 0
		diff = t2.bp - t1.bp if diff == 0
		diff
	end.each do |t|
		puts "#{sprintf("%2d", rank)}. #{sprintf("%10s", t.name)}   #{sprintf("%2d", t.w+t.d+t.l)}  #{sprintf("%2d", t.w)}-#{sprintf("%2d", t.d)}-#{sprintf("%2d", t.l)} #{sprintf("%2d", t.bp)}-#{sprintf("%2d", t.bc)} #{t.pts}"
		rank = rank + 1
	end
end

def league(teams, rounds, home_advantage)
	teams.shuffle!
	teams.each do |team|
		team.pts = 0
		team.bp = 0
		team.bc = 0
		team.w = 0
		team.d = 0
		team.l = 0
	end
	(1..rounds).each do |round|
		(0...teams.count - 1).each do |day|
			puts "=============================="
			puts "Round #{round}; day #{day + 1}"
			puts "=============================="
			(0...teams.count / 2).each do |game|
				playing_teams = []
				shift = game == 0 ? (round + day) % 2 : 0
				if (game == 0)
					playing_teams[shift] = teams[0]
				else
					playing_teams[shift] = teams[(game * 2 + day) % (teams.count - 1) + 1]
				end
				playing_teams[1 - shift] = teams[(teams.count - 1 - game * 2 + day ) % (teams.count - 1) + 1]
				puts ""
				puts "#{playing_teams[0].name}:#{playing_teams[1].name}"
				pause
				score = game([playing_teams[0], playing_teams[1]], home_advantage)
				if (score[0] > score[1])
					winner = 0
				elsif (score[1] > score[0])
					winner = 1
				else
					winner = nil
				end
				if (winner)
					playing_teams[winner].pts = playing_teams[winner].pts + 3
					playing_teams[winner].w = playing_teams[winner].w + 1
					playing_teams[1 - winner].l = playing_teams[1 - winner].l + 1
				else
				 	playing_teams[0].pts = playing_teams[0].pts + 1
				 	playing_teams[1].pts = playing_teams[1].pts + 1
					playing_teams[0].d = playing_teams[0].d + 1
					playing_teams[1].d = playing_teams[1].d + 1
				end
				playing_teams[0].bp = playing_teams[0].bp + score[0]
				playing_teams[1].bp = playing_teams[1].bp + score[1]
				playing_teams[0].bc = playing_teams[0].bc + score[1]
				playing_teams[1].bc = playing_teams[1].bc + score[0]
			end
			print_table(teams)
			pause
		end
	end
end

require 'ostruct'
def add_team(name, midfield, attack, defense)
	t = OpenStruct.new
	t.name = name
	t.midfield = midfield
	t.attack = attack
	t.defense = defense
	t
end

teams = []
teams << add_team("YB", 65, 65, 70)
teams << add_team("Basel", 60, 70, 70)
teams << add_team("Zurich", 50, 50, 50)
teams << add_team("St Gall", 50, 50, 50)
teams << add_team("Luzern", 40, 50, 50)
teams << add_team("Lugano", 45, 50, 50)
teams << add_team("Sion", 45, 45, 45)
teams << add_team("Servette", 40, 50, 40)
teams << add_team("Thun", 40, 40, 50)
teams << add_team("Xamax", 35, 45, 55)
league(teams, 4, 20)
