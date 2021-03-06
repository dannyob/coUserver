library buffs;

import "dart:async";
import "dart:convert";
import "dart:io";

import "package:coUserver/common/util.dart";
import "package:coUserver/common/user.dart";
import "package:coUserver/endpoints/metabolics/metabolics.dart";
import "package:path/path.dart" as path;
import "package:redstone/redstone.dart" as app;
import "package:redstone_mapper_pg/manager.dart";

part "buff.dart";
part "playerbuff.dart";

@app.Group("/buffs")
class BuffManager {
	/// String used for querying for a specific buffs_json cell
	/// Will return a length-1 list of rows from metabolics with only the buffs_json column
	static final String CELL_QUERY = "SELECT buffs_json FROM metabolics AS m"
		" JOIN users AS u ON m.user_id = u.id"
		" WHERE u.email = @email";

	static Map<String, Buff> buffs = new Map();

	static bool get loaded => _loading.isCompleted;
	static final Completer _loading = new Completer();

	static Future<int> loadBuffs() async {
		File file = new File(path.join(serverDir.path, "lib", "buffs", "buffdata.json"));
		JSON.decode(await file.readAsStringSync()).forEach((String id, Map data) {
			buffs[id] = new Buff.fromMap(data, id);;
		});

		_loading.complete();
		Log.verbose('[BuffManager] Loaded ${buffs.length} buffs');
		return buffs.length;
	}

	/// Give a user a buff
	static Future addToUser(String buffId, String email, WebSocket userSocket) async {
		PlayerBuff newBuff = new PlayerBuff(Buff.find(buffId), email);
		userSocket.add(JSON.encode({"buff": newBuff.toMap()}));
		newBuff.startUpdating();
	}

	/// Remove a buff from a user
	static Future removeFromUser(String buffId, String email, WebSocket userSocket) async {
		List<Map<String, dynamic>> matching = (await getPlayerBuffs(email: email))
			.where((Map<String, dynamic> buff) => buff["id"] == buffId);
		if (matching.length > 0) {
			PlayerBuff oldBuff = new PlayerBuff.fromMap(matching.single);
			userSocket.add(JSON.encode({"buff_remove": oldBuff.id}));
			oldBuff.remove();
		}
	}

	/// Start updating all buffs for a user (login)
	static Future startUpdatingUser(String email) async {
		if (email != null) {
			try {
				(await getPlayerBuffs(email: email)).forEach((Map<String, dynamic> buffMap) {
					PlayerBuff buff = new PlayerBuff.fromMap(buffMap);
					buff.startUpdating();
				});
			} catch (e, st) {
				Log.error('Could not resume buffs for <email=$email>', e, st);
			}
		}
	}

	/// Stop updating all buffs for a user (logout)
	static Future stopUpdatingUser(String email) async {
		if (email != null) {
			try {
				(await getPlayerBuffs(email: email)).forEach((Map<String, dynamic> buffMap) {
					PlayerBuff buff = new PlayerBuff.fromMap(buffMap);
					buff.stopUpdating();
				});

				PlayerBuff.cache.remove(email);
			} catch (e, st) {
				Log.error('Could not pause buffs for <email=$email>', e, st);
			}
		}
	}

	/// Whether a player has a buff
	static Future<bool> playerHasBuff(String buffId, String email) async {
		if (PlayerBuff.cache.containsKey(email)) {
			// Check cache
			return (PlayerBuff.getFromCache(buffId, email) != null);
		} else {
			// Check database
			List<Map<String, dynamic>> buffs = await getPlayerBuffs(email: email);
			for (Map buff in buffs) {
				if (buff["id"] == buffId) {
					return true;
				}
			}
			return false;
		}
	}

	/// Get all buffs data for a user
	static Future<List<Map<String, dynamic>>> getPlayerBuffs({String email, String username}) async {
		if (email == null && username != null) {
			email = await User.getEmailFromUsername(username);
		} else if (email == null && username == null) {
			return null;
		}

		PostgreSql dbConn = await dbManager.getConnection();

		Map<String, int> playerBuffsData = new Map();
		List<Map<String, dynamic>> playerBuffsList = new List();

		// Get data from database
		try {
			playerBuffsData = JSON.decode((await getMetabolics(email: email)).buffs_json);
		} catch (e, st) {
			Log.error('Error getting buffs from database for <email=$email>', e, st);
		}

		// Fill in buff information
		try {
			playerBuffsData.forEach((String id, int remaining) {
				playerBuffsList.add(
					PlayerBuff.getFromCache(id, email)?.toMap() ??
					new PlayerBuff(Buff.find(id), email, remaining).toMap()
				);
			});
		} catch (e, st) {
			Log.error('Error getting buff information', e, st);
		}

		dbManager.closeConnection(dbConn);
		return playerBuffsList;
	}

	/// API access to [getPlayerBuffs] by email
	@app.Route("/get/:email")
	Future<List<Map<String, dynamic>>> getPlayerSkillsRoute(String email) async {
		return await getPlayerBuffs(email: email);
	}

	/// API access to [getPlayerBuffs] by username
	@app.Route("/getByUsername/:username")
	Future<List<Map<String, dynamic>>> getPlayerSkillsUsernameRoute(String username) async {
		return await getPlayerBuffs(username: username);
	}
}
