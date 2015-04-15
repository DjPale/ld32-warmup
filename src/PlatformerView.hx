import luxe.Text;
import luxe.States;
import luxe.Sprite;
import luxe.Vector;
import luxe.Input;

import Main;

class PlatformerView extends State
{
	var global : GlobalData;
	var batcher : phoenix.Batcher;

	var player : Sprite;
	var player_move : SimpleMoveBehavior;

	var debug : Text;

	public function new(_global:GlobalData, _batcher:phoenix.Batcher)
	{
		super({name:'PlatformerView'});

		global = _global;
		batcher = _batcher;
	}

	override function onenabled<T>(ignored:T)
    {
    	trace('enable PlatformerView');
    } //onenabled

    override function ondisabled<T>(ignored:T)
    {
    	trace('disable PlatformerView');
    } //ondisabled

    override function onenter<T>(ignored:T) 
    {
        trace('enter PlatformerView');

        setup();
    } //onenter

    override function onleave<T>(ignored:T)
    {
    	trace('leave PlatformerView');
    } //onleave

    function setup()
    {
    	debug = new Text({
    		name: 'DebugText',
    		point_size: 30,
    		pos: new Vector(30,30)
    		});

    	Luxe.input.bind_key('right', Key.key_d);
    	Luxe.input.bind_key('left', Key.key_a);
    	Luxe.input.bind_key('jump', Key.key_w);


    	player = new Sprite({
    		name: 'player',
    		size: new Vector(32, 64),
    		pos: Luxe.screen.mid
    		});
    	player_move = player.add(new SimpleMoveBehavior());

    	new Sprite({
    		name: 'ground',
    		size: new Vector(256, 32),
    		color: new luxe.Color(0.6, 0.6, 0.6, 1),
    		pos: new Vector(Luxe.screen.mid.x, Luxe.screen.mid.y + 64)
    		});

    	new Sprite({
    		name: 'ground2',
    		size: new Vector(64, 128),
    		color: new luxe.Color(0.6, 0.6, 0.6, 1),
    		pos: new Vector(Luxe.screen.mid.x - 196, Luxe.screen.mid.y + 64)
    		});
    }

    override function update(dt:Float)
    {
    	var dir = 0;

    	if (Luxe.input.inputdown('left'))
    	{
    		dir = -1;
    	}

    	if (Luxe.input.inputdown('right'))
    	{
    		dir += 1;
    	}

    	if (Luxe.input.inputdown('jump'))
    	{
    		player_move.jump();
    	}

    	player_move.move(dir);

    	debug.text = 'g=${player_move.is_grounded()}, a=${player_move.acceleration} v=${player_move.velocity}';
    }
}