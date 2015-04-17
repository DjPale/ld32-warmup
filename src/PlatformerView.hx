import luxe.Text;
import luxe.States;
import luxe.Sprite;
import luxe.Vector;
import luxe.Input;
import luxe.Entity;

import luxe.importers.tiled.TiledMap;
import luxe.importers.tiled.TiledObjectGroup;
import luxe.tilemaps.Ortho;

import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Polygon;

import Main;

class PlatformerView extends State
{
	var global : GlobalData;
	var batcher : phoenix.Batcher;

	var player : SimpleMoveBehavior;

	var debug : Text;

    var tiled : TiledMap;


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

        Luxe.scene.empty();
        tiled.visual.destroy();
    } //onleave

    function setup()
    {
    	debug = new Text({
    		name: 'DebugText',
    		point_size: 12,
    		pos: new Vector(30,30)
    		});

    	Luxe.input.bind_key('right', Key.key_d);
    	Luxe.input.bind_key('left', Key.key_a);
    	Luxe.input.bind_key('jump', Key.key_w);

        var ship_spr = new Sprite({
            name: 'ship',
            size: new Vector(64, 32),
            pos: new Vector(50, 70)
            });

        ship_spr.add(new ItemBehavior({name:'exit'}));

        ship_spr.events.listen('Pickup',
            function(e:Entity)
            {

                global.views.set('GameView');
            }
            );


    	var player_spr = new Sprite({
    		name: 'player',
    		size: new Vector(16, 32),
    		pos: new Vector(50, 200)
    		});
    	player = player_spr.add(new SimpleMoveBehavior({name:'SimpleMoveBehavior'}));

        tiled = new TiledMap({
            tiled_file_data: Luxe.resources.find_text('assets/test.tmx').text,
            asset_path: 'assets/'
            });

        var map_collision : Array<Shape> = [];
        var shape_drawer = new luxe.collision.ShapeDrawerLuxe();

        tiled.display({ scale: 1, filter:phoenix.Texture.FilterType.nearest });
        for (grp in tiled.tiledmap_data.object_groups)
        {
            if (grp.name == 'Collision')
            {
                for (obj in grp.objects)
                {
                    var p = obj.pos;

                    if (obj.object_type == TiledObjectType.rectangle)
                    {
                        trace(obj.name);
                        var s = Polygon.rectangle(p.x, p.y, obj.width, obj.height, false);
                        map_collision.push(s);
                        //shape_drawer.drawShape(s, new luxe.Color(1, 0, 0, 1));
                    }
                    else if (obj.object_type == TiledObjectType.polygon)
                    {
                        var s = new Polygon(obj.pos.x, obj.pos.y, obj.polyobject.points);
                        map_collision.push(s);
                        //shape_drawer.drawShape(s, new luxe.Color(1, 0, 0, 1));
                    }
                }
            }
        }

        player.shapes = map_collision;
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
    		player.jump();
    	}

    	player.move(dir);

    	//debug.text = 'g=${player.is_grounded()}, p=${player.pos}, a=${player.acceleration}';//' v=${player.velocity}';
        if (player.__cd != null) 
        {
            debug.text = 'uv=' + player.__cd.unitVector + ' sep=' + player.__cd.separation;
        }
        else
        {
            debug.text = '';
        }


        if (player.pos.y > Luxe.screen.h)
        {
            player.pos = new Vector(50, 200);
        }
    }
}