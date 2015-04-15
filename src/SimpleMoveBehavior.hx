import luxe.Component;
import luxe.Vector;
import luxe.Sprite;
import luxe.Color;
import luxe.utils.Maths;
import luxe.collision.Collision;
import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Polygon;

class SimpleMoveBehavior extends Component
{
	public var velocity(default,null) : Vector = new Vector();
	public var acceleration(default,null) : Vector =  new Vector();

	public var base_scale(default,default) : Float = 160.0;
	public var gravity(default,default) : Vector;
	public var velocity_max(default,default) : Vector;
	public var accel_walk(default,default) : Float;
	public var velocity_jump(default,default) : Float;

	var collider : Shape;
	var sprite : Sprite;

	var shape_drawer : luxe.collision.ShapeDrawerLuxe;

	public function new(?_options:luxe.options.ComponentOptions = null)
	{
		super(_options);

		velocity_max = new Vector(-base_scale, base_scale);
		accel_walk = base_scale * 5.0;
		gravity = new Vector(0, base_scale * 5.0);
		velocity_jump = -base_scale * 2.4;

		shape_drawer = new luxe.collision.ShapeDrawerLuxe();
	}

	override function init()
	{
		sprite = cast entity;

		collider = Polygon.rectangle(0, 0, sprite.size.x, sprite.size.y, true);
	}

	public function move(dir:Int)
	{
		var sgn = 0;
		if (dir > 0) 
		{
			sgn = 1;
		}
		else if (dir < 0)
		{
			sgn = -1;
		}

		acceleration.x = sgn * accel_walk;
	}

	public inline function is_grounded()
	{
		return check_collision(0, 1);
	}

	public function jump()
	{
		if (!is_grounded()) return;

		velocity.y = velocity_jump;
	}

	function check_collision(dx:Float, dy:Float) : Bool
	{
		if (collider == null) return false;

		collider.position = pos.clone();
		collider.position.x += dx;
		collider.position.y += dy;

		var collided = false;

		for (e in Luxe.scene.entities)
		{
			if (e == entity) continue;

			if (Std.is(e, Sprite))
			{
				var spr : Sprite = cast e;

				var tmp = Polygon.rectangle(0, 0, spr.size.x, spr.size.y, true);
				tmp.position = spr.pos;

				var cd = Collision.test(tmp, collider);

				if (cd != null)
				{
					// var sep = cd.separation;

					// pos.x -= sep.x;
					// pos.y -= sep.y;

					collided = true;
				}
			}
		}

		return collided;
	}

	public function move_by(x:Float, y:Float) : Bool
	{
		if (collider == null) return false;
		if (x == 0 && y == 0) return false;

		collider.position = pos.clone();
		collider.position.x += x;
		collider.position.y += y;

		shape_drawer.drawShape(collider, new Color(1,0,0,1), true);

		var collided = false;

		for (e in Luxe.scene.entities)
		{
			if (e == entity) continue;

			if (Std.is(e, Sprite))
			{
				var spr : Sprite = cast e;

				var tmp = Polygon.rectangle(0, 0, spr.size.x, spr.size.y, true);
				tmp.position = spr.pos;

				shape_drawer.drawShape(tmp, new Color(1,0,0,1), true);

				var cd = Collision.test(tmp, collider);

				if (cd != null && cd.overlap != 0)
				{
					var sep = cd.separation;//cd.separation.clone();
					pos.x -= sep.x;
					pos.y -= sep.y;
					collided = true;
				}
			}
		}

		if (!collided)
		{	
			pos.x += x;
			pos.y += y;
		}

		return collided;
	}

	override function update(dt:Float)
	{
		// abrupt stop for now
		if (acceleration.x == 0)
		{
			velocity.x = 0;
		}
		else
		{
			velocity.x += acceleration.x * dt;
			velocity.x = Maths.clamp(velocity.x, velocity_max.x, velocity_max.y);
		}

		var dx = velocity.x * dt;

		velocity.y += gravity.y * dt;
		//velocity.y = Maths.clamp(velocity.y, velocity_max.x, velocity_max.y);
		var dy = velocity.y * dt;

		move_by(dx, dy);

		if (is_grounded())
		{
			velocity.y = 0;
		}
	}
}