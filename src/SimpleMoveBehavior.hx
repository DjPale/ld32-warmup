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

	public var base_scale(default,default) : Float = 200.0;
	public var gravity(default,default) : Vector;
	public var velocity_x_max(default,default) : Vector;
	public var velocity_y_max(default,default) : Vector;
	public var accel_walk(default,default) : Float;
	public var velocity_jump(default,default) : Float;

	var collider : Shape;
	var sprite : Sprite;

#if debug
	var shape_drawer : luxe.collision.ShapeDrawerLuxe;
#end

	public function new(?_options:luxe.options.ComponentOptions = null)
	{
		super(_options);

		velocity_x_max = new Vector(-base_scale * 1.5, base_scale * 1.5);
		accel_walk = base_scale * 5.0;
		gravity = new Vector(0, base_scale * 5.0);
		velocity_jump = -base_scale * 2.0;
		velocity_y_max = new Vector(-base_scale * 5.0, base_scale * 5.0);
#if debug
		shape_drawer = new luxe.collision.ShapeDrawerLuxe();
#end
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

	public inline function jump()
	{
		if (!is_grounded()) return;

		velocity.y = velocity_jump;
	}

	function check_collision(dx:Float, dy:Float) : Bool
	{
		if (collider == null) return false;

		var x = Math.round(dx);
		var y = Math.round(dy);

		collider.position = pos.clone();
		collider.position.x += x;
		collider.position.y += y;

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

				if (cd != null && cd.unitVector.y > 0)
				{
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

		var dx = x;
		var dy = y;

		collider.position = pos.clone();
		collider.position.x += dx;
		collider.position.y += dy;

#if debug
		shape_drawer.drawShape(tmp, new Color(1,0,0,1), true);
#end
		var collided = false;

		for (e in Luxe.scene.entities)
		{
			if (e == entity) continue;

			if (Std.is(e, Sprite))
			{
				var spr : Sprite = cast e;

				var tmp = Polygon.rectangle(0, 0, spr.size.x, spr.size.y, true);
				tmp.position = spr.pos;
#if debug
				shape_drawer.drawShape(tmp, new Color(1,0,0,1), true);
#end
				var cd = Collision.test(tmp, collider);

				if (cd != null)
				{
					var sep = cd.separation;
					// adjacent but not overlapping
					if (cd.overlap == 0)
					{
						if (cd.unitVector.x > 0 && dx > 0) dx = 0;
						if (cd.unitVector.y < 0 && dy < 0) dy = 0;
						if (cd.unitVector.x < 0 && dx < 0) dx = 0;
						if (cd.unitVector.y > 0 && dy > 0) dy = 0;
						continue;
					}

					// correction needed
					pos.x -= sep.x;
					pos.y -= sep.y;

					collided = true;
				}
			}
		}

		if (!collided)
		{	
			pos.x += dx;
			pos.y += dy;
		}

		// round to nearest int
		pos.x = Math.round(pos.x);
		pos.y = Math.round(pos.y);

		return collided;
	}

	inline function update_movement(dt:Float)
	{
		// abrupt stop for now
		if (acceleration.x == 0)
		{
			velocity.x = 0;
		}
		else
		{
			velocity.x += acceleration.x * dt;
			velocity.x = Maths.clamp(velocity.x, velocity_x_max.x, velocity_x_max.y);
		}

		var dx = velocity.x * dt;

		velocity.y += gravity.y * dt;
		velocity.y = Maths.clamp(velocity.y, velocity_y_max.x, velocity_y_max.y);

		var dy = velocity.y * dt;

		move_by(dx, dy);

		if (is_grounded())
		{
			velocity.y = 0;
		}
	}

	override function update(dt:Float)
	{
		update_movement(dt);
	}
}