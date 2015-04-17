import luxe.Text;
import luxe.States;
import luxe.Vector;
import luxe.Sprite;
import luxe.Sound;
import luxe.Input;

import luxe.tween.Actuate;

import Main;

class MenuView extends State
{
	var global : GlobalData;
	var batcher : phoenix.Batcher;

	var bg : Sprite;

	public function new(_global:GlobalData, _batcher:phoenix.Batcher)
	{
		super({name:'MenuView'});

		global = _global;
		batcher = _batcher;
	}

	override function onenabled<T>(ignored:T)
    {
    	trace('enable MenuView');
    } //onenabled

    override function ondisabled<T>(ignored:T)
    {
    	trace('disable MenuView');

    } //ondisabled

    override function onenter<T>(ignored:T) 
    {
        trace('enter MenuView');

        setup();
    } //onenter

    override function onleave<T>(ignored:T)
    {
    	trace('leave MenuView');

    	teardown();
    } //onleave

    function setup()
    {
    	Luxe.audio.create('assets/menu.ogg', 'menu').then(
    		function(_) 
    		{ 
    			Luxe.audio.volume('menu', global.volume_bgm);
    			Luxe.audio.loop('menu');
    	});

    	var logo = new Sprite({
    		name: 'logo',
    		pos: new Vector(Luxe.screen.mid.x, 200),
    		centered: true,
    		texture: Luxe.resources.find_texture('assets/logo.png')
    		});

    	logo.color.a = 0;
    	logo.color.tween(1.0, { a: 1.0 });

	    bg = new Sprite({
		name: 'bg',
		texture: Luxe.resources.find_texture('assets/background.png'),
		size: new Vector(Luxe.screen.w, Luxe.screen.w / (Luxe.screen.w / Luxe.screen.h)),
		centered: false,
		depth: 0
		});

		//bg.texture.filter = phoenix.Texture.FilterType.nearest;
		bg.texture.clamp = phoenix.Texture.ClampType.repeat;
		bg.color.a = 0;

		bg.color.tween(3.0, { a: 1.0 });

		var start_txt = new Text({
			name: 'start',
			point_size: 30,
			pos: Luxe.screen.mid,
			text: 'start game',
			align: TextAlign.center,
			});

		start_txt.color.tween(0.4, { a: 0 }).repeat().reflect().ease(luxe.tween.easing.Sine.easeInOut);

    }

    override function onkeyup(e:luxe.KeyEvent)
    {
    	if (e.keycode == Key.enter || e.keycode == Key.space)
    	{
    		global.views.set('PlatformerView');
    	}
    }

    override function update(dt:Float)
    {
    	bg.uv.x += 50 * dt;
    	bg.uv.y += 10 * dt * Math.sin(Luxe.current_time);
    }

    function teardown()
    {
    	Luxe.audio.uncreate('menu');
    	Luxe.scene.empty();
    }
}