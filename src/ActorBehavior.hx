import luxe.Component;
import luxe.Sprite;
import luxe.Vector;
import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Polygon;

class ActorBehavior extends Component
{
	public var collider(default,null) : Shape;

	var size : Vector;

	public function new(?_size:Vector = null, ?_options:luxe.options.ComponentOptions = null, ?_shape:Shape = null)
	{
		super(_options);

		collider = _shape;
		size = _size;
	}

	override function init()
	{
		if (collider == null)
		{
			if (Std.is(entity, Sprite))
			{
				var spr = cast(entity, Sprite);

				var w = spr.size.x;
				var h = spr.size.y;

				if (size != null)
				{
					w = size.x;
					h = size.y;
				}

				collider = Polygon.rectangle(0, 0, w, h, spr.centered);
				collider.position = pos;
			}
		}
	}
}