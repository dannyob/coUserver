part of coUserver;

class Mab extends Shrine
{
	Mab(String id, int x, int y, String streetName) : super(id,x,y, streetName)
	{
		states =
			{
				"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_mab__x1_close_png_1354831238.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_mab__x1_open_png_1354831237.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_mab__x1_open_png_1354831237.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];
	 	type = 'Mab';

	 	description = 'This is a shrine to Mab, the giant who holds sway over the harvest. She honors industriousness, and rightfully so. Sometimes, however, industriousness can turn to greed. This is a problem.';
	}
}

class MabFirebog extends Shrine
{
	MabFirebog(String id, int x, int y, String streetName) : super(id,x,y, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_mab__x1_close_png_1354832830.png",984, 848, 164, 212, 23, false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_mab__x1_open_png_1354832828.png",984, 848, 164, 212, 22, false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_mab__x1_open_png_1354832828.png", 984, 848, 164, 212, 1, false)
		};
		currentState = states['still'];
		type = 'Mab';

		description = 'This is a shrine to Mab, the giant who holds sway over the harvest. She honors industriousness, and rightfully so. Sometimes, however, industriousness can turn to greed. This is a problem.';
	}
}

class MabIx extends Shrine
{
	MabIx(String id, int x, int y, String streetName) : super(id,x,y, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_ix_mab__x1_close_png_1354831294.png",840,864,168,216,20, false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_ix_mab__x1_open_png_1354831292.png",840,1080,168,216,24, false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_ix_mab__x1_open_png_1354831292.png",840,1080,168,216, 1, false)
		};
		currentState = states['still'];
		type = 'Mab';

		description = 'This is a shrine to Mab, the giant who holds sway over the harvest. She honors industriousness, and rightfully so. Sometimes, however, industriousness can turn to greed. This is a problem.';
	}
}

class MabUralia extends Shrine
{
	MabUralia(String id, int x, int y, String streetName) : super(id,x,y, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_mab__x1_close_png_1354831904.png",756, 752, 126, 188, 23, false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_mab__x1_open_png_1354831902.png",756, 752, 128, 188, 22, false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_mab__x1_open_png_1354831902.png", 756, 752, 128, 188, 1, false)
		};
		currentState = states['still'];
		type = 'Mab';

		description = 'This is a shrine to Mab, the giant who holds sway over the harvest. She honors industriousness, and rightfully so. Sometimes, however, industriousness can turn to greed. This is a problem.';
	}
}