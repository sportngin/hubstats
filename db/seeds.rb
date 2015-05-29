deploy_list = [
	["c1a2b37", "sportngin/ngin", "2009-12-03 18:00:00 -0500", "emmasax1"],
	["i32jb9e", "sportngin/linkshare", "2010-05-26 17:00:00 -0500", "aplackner"],
	["w19dkid", "sportngin/active_zuora_v1", "2011-08-21 02:00:00 -0500", "jonkarna"],
	["n83b20c", "sportngin/boss_service", "2006-11-08 05:00:00 -0500", "gorje001"],
	["c92kda8", "sportngin/pocket_ngin", "2008-11-10 12:00:00 -0500", "NickLaMuro"],
	["b91k9dk", "sportngin/user_service", "2010-02-18 11:00:00 -0500", "matthewkrieger"],
	["ieoq630", "sportngin/simple_benchmark", "2007-04-14 11:00:00 -0500", "melcollova"],
	["c1a2b38", "sportngin/ngin", "2009-12-03 18:01:00 -0500", "emmasax1"],
	["c1a2b39", "sportngin/ngin", "2009-12-04 13:00:00 -0500", "lukeludwig"],
	["29xkdi9", "sportngin/tst_dashboard", "2015-01-18 14:00:00 -0500", "mrreynolds"],
	["9xkdjqk", "sportngin/automation", "2015-03-21 07:00:00 -0500", "lackac"],
	["is93h1n", "sportngin/janky", "2014-12-31 09:00:00 -0500", "EvaMartinuzzi"],
	["kdiq13j", "sportngin/ngin", "2013-11-17 04:00:00 -0500", "Olson3R"],
	["ciap1kd", "sportngin/statcore_ice_hockey", "2010-08-29 01:00:00 -0500", "odelltuttle"],
	["iek9s0d", "sportngin/freshbooks.rb", "2015-05-13 12:00:00 -0500", "tombadaczewski"],
	["918240d", "sportngin/pocket_ngin", "2015-04-01 03:00:00 -0500", "plaincheesepizza"],
	["dis8203", "sportngin/sport_ngin_live", "2015-02-27 08:00:00 -0500", "GeoffreyHinck"],
	["2kd9sac", "sportngin/jarvis", "2015-05-26 03:00:00 -0500", "Bleisz22"],
	["0slqi83", "sportngin/utils", "2015-05-27 13:00:00 -0500", "cdelrosario"],
	["c92k102", "sportngin/passenger", "2015-05-27 12:00:00 -0500", "panderson74"]
]

def replace_name_with_id (repo_name)
	return Hubstats::Repo.where(full_name: repo_name).first.id.to_i
end

deploy_list.each do |git_revision, repo_name, deployed_at, deployed_by|
	Hubstats::Deploy.create(git_revision: git_revision, repo_id: replace_name_with_id(repo_name), deployed_at: deployed_at, deployed_by: deployed_by)
end