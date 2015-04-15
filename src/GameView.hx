import luxe.States;
import luxe.Input;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;
import luxe.Text;

import luxe.tween.Actuate;

import luxe.Particles;
import luxe.options.ParticleOptions;

import luxe.structural.Pool;

import Main;

class GameView extends State
{
	var global : GlobalData;
	var batcher : phoenix.Batcher;
    var controller : EnemyController;
	var explosions : Pool<ParticleSystem>;
    var scores : Pool<Text>;

	var p1 : PaddleBehavior;
	var ball : BallBehavior;

	var bg : Sprite;
    var p1_score : Text;

	var player_depth : Float = 100.0;

	public function new(_global:GlobalData, _batcher:phoenix.Batcher)
	{
		super({ name: 'GameView' });

		global = _global;
		batcher = _batcher;
	}

	override function onenabled<T>(ignored:T)
    {
    	trace('enable GameView');

        start_level(null);
    } //onenabled

    override function ondisabled<T>(ignored:T)
    {
    	trace('disable GameView');
    } //ondisabled

    override function onenter<T>(ignored:T) 
    {
        trace('enter GameView');

        setup();
    } //onenter

    override function onleave<T>(ignored:T)
    {
    	trace('leave GameView');
    } //onleave

    override function update(dt:Float)
    {
    	if (Luxe.input.inputdown('p1.up'))
    	{
    		p1.move(-1 * dt);
    	}
    	else if (Luxe.input.inputdown('p1.down'))
    	{
    		p1.move(1 * dt);
    	}

        if (Luxe.input.inputreleased('restart'))
        {
            start_level(null);
        }

    	bg.uv.y -= 20 * dt;

        controller.update(dt);
    }

    function setup()
    {
    	var p1_spr = new Sprite({
    		name: 'p1',
    		size: new Vector(20, 80),
    		color: new luxe.Color(1, 1, 1, 1),
    		depth: player_depth,
    		});

    	p1_spr.add(new ActorBehavior({name:'ActorBehavior'}));
    	p1 = p1_spr.add(new PaddleBehavior({name:'PaddleBehavior'}));
    	p1_spr.add(new TrailBehavior(new Vector(20, 80), new Color(1, 1, 1, 1)));

    	Luxe.input.bind_key('p1.up', Key.key_w);
        Luxe.input.bind_key('p1.down', Key.key_s);
    	Luxe.input.bind_key('restart', Key.key_r);

    	var ball_spr = new Sprite({
    		name: 'ball',
    		size: new Vector(20, 20),
    		color: new luxe.Color(1, 1, 1, 1),
    		depth: player_depth,
    		});

    	ball = ball_spr.add(new BallBehavior());
    	ball_spr.add(new TrailBehavior(new Vector(20, 20), new Color(1, 1, 1, 1)));

    	ball_spr.events.listen('Ball.Collide', function(b:BallBehavior) { explosion(b.entity); });

    	var ratio = Luxe.screen.w / Luxe.screen.h;

    	bg = new Sprite({
    		name: 'bg',
    		texture: Luxe.resources.find_texture('assets/background.png'),
    		size: new Vector(Luxe.screen.w, Luxe.screen.w / ratio),
    		centered: false,
    		depth: 0
    		});

    	//bg.texture.filter = phoenix.Texture.FilterType.nearest;
    	bg.texture.clamp = phoenix.Texture.ClampType.repeat;

    	explosions = new Pool<ParticleSystem>(4, create_explosion);

        p1_score = new Text({
            name: 'p1.score',
            text: '0',
            pos: new Vector(150, 30),
            point_size: 30,
            depth: 200,
            });

        scores = new Pool<Text>(6, create_score);

        Luxe.events.listen('Enemy.Death', enemy_death);
        Luxe.events.listen('Ball.Disappear', start_level);

        controller = new EnemyController();

        start_level(null);
    }

    function start_level(_)
    {
        global.p1_score = 0;
        p1_score.text = '0';

        ball.pos = Luxe.screen.mid;

        ball.velocity.x = -300;
        ball.velocity.y = 100;

        p1.pos = new Vector(40, Luxe.screen.mid.y);

        controller.start_spawner(1);   
    }

    function create_score(num:Int, total:Int) : Text
    {
        return new Text({
            name: 'score.$num',
            point_size: 30,
            depth: 200,
            visible: false,
            scale: new Vector(),
            align: TextAlign.center
            });
    }

    function create_explosion(num:Int, total:Int) : ParticleSystem
    {
    	var particles = new ParticleSystem({name:'particles.explode.$num'});
    	var emitter : ParticleEmitterOptions = {};

    	emitter.start_color = new luxe.Color(1, 1, 1, 0.8);
    	emitter.name = 'explode1';
    	emitter.pos = new Vector();
    	emitter.gravity = new Vector(0, 100);
    	emitter.speed_random = 10;
    	emitter.pos_random = new Vector(20, 20);
    	emitter.life = 0.5;
    	emitter.depth = 10;
    	emitter.emit_count = 16;
    	emitter.emit_time = 0.02;
    	emitter.start_size = new Vector(2, 2);
    	emitter.end_size = new Vector(0, 0);

    	particles.add_emitter(emitter);
    	particles.stop();

    	return particles;
    }

    function enemy_death(e:EnemyBehavior)
    {
        explosion(e.entity, 1.0);
        Luxe.camera.shake(10);
        score(e.entity, 100);
    }

    function explosion(e:luxe.Entity, ?dur:Float = 0.25)
    {
    	var particles = explosions.get();

		particles.pos = e.pos.clone();
		particles.start(dur);

		trace('xplosion from ' + e.name);
    }

    function score(target:luxe.Entity, amount:Int)
    {
        var txt = scores.get();
        txt.text = Std.string(amount);
        txt.pos = target.pos;
        txt.scale.set_xy(0, 0);
        txt.color.a = 0;
        txt.visible = true;

        txt.color.tween(0.5, { a: 1 });
        Actuate.tween(txt.scale, 0.5, { x: 1.0, y: 1.0 }).ease(luxe.tween.easing.Bounce.easeOut).onComplete(
            function(_)
            {
                Actuate.timer(1).onComplete(
                    function(_)
                    {
                        txt.color.tween(0.5, { a: 0 });
                        Actuate.tween(txt.scale, 0.5, { x: 0, y: 0});
                    }
                );
            }
        );

        global.p1_score += amount;

        p1_score.text = Std.string(global.p1_score);
    }

}