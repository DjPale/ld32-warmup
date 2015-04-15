import luxe.Component;
import luxe.Sprite;
import luxe.Vector;
import luxe.components.sprite.SpriteAnimation;

typedef EnemyReadyFunc = Void -> Void;
typedef EnemyMoveFunc = Vector -> Float -> Float -> Float;

class EnemyBehavior extends Component
{
	public var HP(default,null) : Int = 1;
	public var sprite(default,default) : Sprite;
	public var ready(default,default) : EnemyReadyFunc;
	public var speed(default,default) : Float = 50.0;
	public var movement(default,default) : EnemyMoveFunc;
 
	var anim : SpriteAnimation;

	public function new(?_options : luxe.options.ComponentOptions = null, ?_move:EnemyMoveFunc = null, ?_ready:EnemyReadyFunc = null)
	{
		super(_options);

		ready = _ready;
		movement = _move;
	}

	public override function init()
	{
		sprite = cast(entity,Sprite);

		entity.active = false;

		if (ready != null) ready();

		anim = entity.get('SpriteAnimation');
	
		sprite.uv.set(0, 0, 128, 128);

		start_ai(true);
	}

	public function hit(dmg:Int)
	{	
		HP -= dmg;

		if (HP <= 0)
		{
			Luxe.events.fire('Enemy.Death', this);
			sprite.visible = false;
			entity.active = false;
		}
	}

	public function start_ai(?first = false)
	{
		if (!first)
		{
			anim.animation = 'disappear';
			anim.restart();
		}

		luxe.tween.Actuate.timer(2).onComplete(
			function(_) {
				anim.animation = 'appear';
				//anim.set_frame(1);
				anim.restart();

				var t = Luxe.utils.random.float(2, 5);

				luxe.tween.Actuate.timer(t).onComplete(start_ai);
			});
	}

	override function update(dt:Float)
	{
		if (movement != null) 
		{
			var x = Luxe.screen.mid.x + movement(pos, dt, speed);
			var y = pos.y + (speed * dt);

			pos.set_xy(x, y);

			sprite.rotation_z += speed * 0.03;
		}
	}
}
