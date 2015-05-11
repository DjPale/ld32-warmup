import luxe.Entity;
import luxe.Sprite;
import luxe.Vector;
import luxe.structural.Pool;

import luxe.components.sprite.SpriteAnimation;

class EnemyController
{
	var clock : Float;
	var running : Bool;
	var event : Int;

	var enemies : Pool<EnemyBehavior>;

	public function new()
	{
		enemies = new Pool<EnemyBehavior>(16, create_enemy);
	}

	public function start_spawner(level:Int)
	{
		stop();

		clock = 0.0;
		event = 0;

  //   	for (i in 0...5)
		// {
	 //    	var test = enemies.get();
	 //    	test.pos = new Vector(
	 //    		Luxe.utils.random.int(100, Luxe.screen.w - 100),
	 //    		Luxe.utils.random.int(50, Luxe.screen.h - 50));
	 //    	test.ready = function()
	 //    	{
	 //    		test.sprite.visible = true;
	 //    	}
		// }

		running = true;
	}

	public function stop()
	{
		running = false;

		for (e in enemies.items)
		{
			if (e.sprite != null) e.sprite.visible = false;
			if (e.entity != null) 
			{
				e.entity.active = false;
				var trail : TrailBehavior = e.get('TrailBehavior');
				trail.visible(false);
			}
		}
	}

	function check_event()
	{
		if (event == 0 && clock >= 1)
		{
			spawn_enemies(4);
			event++;
			return;
		}
		else if (event == 1 && clock >= 15)
		{
			spawn_enemies(2);
			event++;
			return;
		}
		else if (event == 2 && clock >= 20)
		{
			clock = 0.0;
			event = 0;
		}
	}

	function spawn_enemies(num:Int)
	{
		for (i in 0...num)
		{
			var e = enemies.get();
			e.pos = new Vector(Luxe.screen.mid.x, -(i * 130 + 64));
			e.entity.active = true;
			e.sprite.visible = true;

			var trail : TrailBehavior = e.get('TrailBehavior');
			if (trail != null) trail.visible(true);

			trace('spawn ' + e.entity.name);
		}
	}

	function enemy_move(pos:Vector, dt:Float, speed:Float) : Float
	{
		var x : Float = Math.sin(pos.y / 200.0 + Luxe.time) * speed;

		return x;
	}

	public function update(dt:Float)
	{
		if (!running) return;

		clock += dt;

		check_event();
	}

    function create_enemy(num:Int, total:Int) : EnemyBehavior
    {
    	var e_spr = new Sprite({
    		name: 'Enemy.$num',
    		texture: Luxe.resources.texture('assets/anims.png'),
    		size: new Vector(128,128),
    		//color: new Color().rgb(0x9882AC),
    		depth: 100,
    		visible: false,
    		});

    	Luxe.events.listen('Enemy.Death', function(e:EnemyBehavior) 
    		{ 
    			var trail : TrailBehavior = e.get('TrailBehavior');
    			if (trail != null) trail.visible(false);
    		});

    	e_spr.add(new ActorBehavior(new Vector(64,64), {name:'ActorBehavior'}));
    	e_spr.add(new TrailBehavior(new Vector(64,64), new luxe.Color().rgb(0x556270), 5, {name:'TrailBehavior'}));

    	var anim : SpriteAnimation = e_spr.add(new SpriteAnimation({name:'SpriteAnimation'}));
 		var a = Luxe.resources.json('assets/anims.json').asset.json;
    	anim.add_from_json_object(a.json);

    	var enemy = e_spr.add(new EnemyBehavior({name:'EnemyBehavior'}));
    	enemy.movement = enemy_move;

    	return enemy;
    }
}