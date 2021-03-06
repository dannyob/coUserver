library street_entities;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';
import 'package:coUserver/entities/entity.dart';
import 'package:coUserver/common/mapdata/mapdata.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/streets/street_update_handler.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper_pg/manager.dart';

part 'balancer.dart';
part 'migrations.dart';
part 'street_entity.dart';

class StreetEntities {
	static final String TABLE = 'street_entities';

	static Future<List<StreetEntity>> getEntities(String tsid) async {
		try {
			if (tsid == null) {
				throw new ArgumentError('tsid must not be null');
			}
		} catch (e, st) {
			Log.error("Error getting entities for tsid '$tsid'", e, st);
			return new List();
		}

		tsid = tsidL(tsid);

		PostgreSql dbConn = await dbManager.getConnection();

		try {
			String query = 'SELECT * '
				'FROM $TABLE '
				'WHERE tsid = @tsid';

			List<StreetEntity> rows = await dbConn.query(
				query, StreetEntity, {'tsid': tsid});

			return rows;
		} catch (e, st) {
			Log.error('Could not get entities for $tsid', e, st);
			return new List();
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	static Future<StreetEntity> getEntity(String entityId) async {
		PostgreSql dbConn = await dbManager.getConnection();

		try {
			String query = 'SELECT * '
				'FROM $TABLE '
				'WHERE id = @entityId';

			List<StreetEntity> rows = await dbConn.query(
				query, StreetEntity, {'entityId': entityId});

			return rows.single;
		} catch (e, st) {
			Log.error('Could not get street entity $entityId', e, st);
			return null;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	static Future<bool> setEntity(StreetEntity entity, {bool loadNow: true}) async {
		Future<bool> _setInDb(StreetEntity entity) async {
			PostgreSql dbConn = await dbManager.getConnection();

			try {
				String query = 'INSERT INTO $TABLE (id, type, tsid, x, y, metadata_json) '
					'VALUES (@id, @type, @tsid, @x, @y, @metadata_json) '
					'ON CONFLICT (id) DO UPDATE '
					'SET tsid = @tsid, x = @x, y = @y, metadata_json = @metadata_json';

				int result = await dbConn.execute(
					query, encode(entity));

				return (result == 1);
			} catch (e, st) {
				Log.error('Could not edit entity $entity', e, st);
				return false;
			} finally {
				dbManager.closeConnection(dbConn);
			}
		}

		bool _setInMemory(StreetEntity entity) {
			Map<String, dynamic> street = MapData.getStreetByTsid(entity.tsid);
			if (street != null) {
				//if the street isn't currently loaded, then just return
				if (StreetUpdateHandler.streets[street["label"]] == null) {
					return true;
				}

				try {
					// Create NPC
					String id = 'n' + createId(entity.x, entity.x, entity.type, entity.tsid);
					ClassMirror mirror = findClassMirror(entity.type);
					NPC npc = mirror.newInstance(new Symbol(''),
						[entity.id, entity.x, entity.y, street['label']]).reflectee;

					// Load onto street
					StreetUpdateHandler.streets[street["label"]].npcs.addAll({id: npc});
				} catch (e, st) {
					Log.error('Error loading new entity $entity', e, st);
				}
				return true;
			} else {
				return false;
			}
		}

		if (!(await _setInDb(entity))) {
			return false;
		} else if (loadNow) {
			return _setInMemory(entity);
		} else {
			return true;
		}
	}
}
