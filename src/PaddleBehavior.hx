import luxe.Component;
import luxe.Sprite;

class PaddleBehavior extends Component
{
	// pixel/sec
	public var max_velocity(default,default) : Float = 200.0;
	public var velocity(default,null) : Float;


	public function new(?_options : luxe.options.ComponentOptions = null)
	{
		super(_options);
	}

	inline function clamp()
	{
		entity.pos.y = luxe.utils.Maths.clamp(entity.pos.y, 40, Luxe.screen.h - 40);
	}

	public function move(y:Float)
	{
		// lamt! TEMP!
		velocity = max_velocity;

		entity.pos.y += max_velocity * y;

		clamp();
	}
}