def pause
	gets()
	#sleep(1)
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
    teams[0].h2h[teams[1].name] = "#{score[1][0]}:#{score[1][1]}(H) " + teams[0].h2h[teams[1].name]
    teams[1].h2h[teams[0].name] = "#{score[1][1]}:#{score[1][0]}(A) " + teams[1].h2h[teams[0].name]

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
		puts "#{sprintf("%2d", rank)}. #{sprintf("%12s", t.name)}   #{sprintf("%2d", t.w+t.d+t.l)}  #{sprintf("%2d", t.w)}-#{sprintf("%2d", t.d)}-#{sprintf("%2d", t.l)} #{sprintf("%2d", t.bp)}-#{sprintf("%2d", t.bc)} #{t.pts}"
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
				shift = game == 0 ? (round + day) % 2 : round % 2
				if (game == 0)
					playing_teams[shift] = teams[0]
				else
					playing_teams[shift] = teams[(game * 2 + day) % (teams.count - 1) + 1]
				end
				playing_teams[1 - shift] = teams[(teams.count - 1 - game * 2 + day ) % (teams.count - 1) + 1]
				puts ""
				puts "#{playing_teams[0].name}:#{playing_teams[1].name}"
				if (round > 1 || day > 0)
					lookback = 5
					if (round > 1 || day >= lookback)
						puts "form: #{playing_teams[0].history[-lookback..-1].reverse}:#{playing_teams[1].history[-lookback..-1].reverse}"
					else
						puts "form: #{playing_teams[0].history.reverse}:#{playing_teams[1].history.reverse}"
					end
				end
				if (round > 1)
					puts "h2h: #{playing_teams[0].h2h[playing_teams[1].name]}"
				end
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
					playing_teams[winner].history << 'w'
					playing_teams[1 - winner].history << 'l'
				else
				 	playing_teams[0].pts = playing_teams[0].pts + 1
				 	playing_teams[1].pts = playing_teams[1].pts + 1
					playing_teams[0].d = playing_teams[0].d + 1
					playing_teams[1].d = playing_teams[1].d + 1
					playing_teams[0].history << 'd'
					playing_teams[1].history << 'd'
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
	t.midfield = midfield + Random.rand * 10 - 5
	t.attack = attack + Random.rand * 10 - 5
	t.defense = defense + Random.rand * 10 - 5
    t.history = ""
    t.h2h = Hash.new{ |hash, key| hash[key] = "" }
	t
end


# teams = []
# teams << add_team("YB", 66, 65, 66)
# teams << add_team("Basel", 60, 66, 70)
# teams << add_team("Zurich", 47, 50, 47)
# teams << add_team("St Gall", 62, 62, 58)
# teams << add_team("Luzern", 40, 48, 47)
# teams << add_team("Lugano", 43, 43, 50)
# teams << add_team("Sion", 45, 45, 45)
# teams << add_team("Servette", 58, 58, 50)
# teams << add_team("Thun", 40, 40, 50)
# teams << add_team("Xamax", 37, 45, 52)
# league(teams, 4, 20)

teams = []
teams << add_team("GC", 66, 65, 60)
teams << add_team("Thun", 65, 60, 60)
teams << add_team("Xamax", 58, 62, 62)
teams << add_team("Aarau", 58, 58, 55)
teams << add_team("Winterthur", 50, 53, 53)
teams << add_team("Wil", 48, 53, 53)
teams << add_team("Kriens", 43, 43, 50)
teams << add_team("SLO", 45, 49, 49)
teams << add_team("Schaffhausen", 40, 43, 47)
teams << add_team("Chiasso", 37, 45, 47)
league(teams, 4, 20)
