import luxe.Component;
import luxe.Vector;
import luxe.Sprite;
import luxe.Entity;
import luxe.collision.Collision;
import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Polygon;

class ItemBehavior extends Component
{
	var sprite : Sprite;
	var collider : Shape;
	var player : Shape;

	public function new(?_options:luxe.options.ComponentOptions = null)
	{
		super(_options);
	}
	
	override function init()
	{
		sprite = cast entity;

		collider = Polygon.rectangle(entity.pos.x, entity.pos.y, sprite.size.x, sprite.size.y, true);
	}

	inline function find_player()
	{
		for (e in Luxe.scene.entities)
		{
			if (e != null && e.name == 'player')
			{
				var c = e.get('SimpleMoveBehavior');
				if (c != null)
				{
					player = c.collider;
				}
			}
		}
	}

	inline function check_pickup()
	{
		if (player == null)
		{
			find_player();
		}

		if (player != null && collider != null)
		{
			if (Collision.shapeWithShape(player, collider) != null)
			{
				entity.events.fire('Pickup', entity);
			}
		}
	}

	override function update(dt:Float)
	{
		check_pickup();
	}
}