import luxe.Component;
import luxe.Vector;
import luxe.Sprite;
import luxe.Rectangle;
import luxe.tween.Actuate;
import luxe.collision.Collision;
import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Polygon;

using StringTools;

class BallBehavior extends Component
{
	public var velocity(default,default) : Vector = new Vector();

	var minPos : Vector;
	var maxPos : Vector;

	var light : Sprite;

	var size : Int = 20;

	var collider : Shape;

	public function new(?_size:Int = 20, ?_options:luxe.options.ComponentOptions = null)
	{
		super(_options);

		size = _size;

		minPos = new Vector(size / 2,size / 2);
		maxPos = Luxe.screen.size.subtract_xyz(size / 2, size / 2, 0);
	}

	override function init()
	{
		light = new Sprite({
			name: 'ball.gradient',
			texture: Luxe.resources.texture('assets/gradient.png'),
			parent: entity,
			color: new luxe.Color(0.8, 0.9, 0.1),
			depth: 10,
			pos: new Vector(size / 2, size / 2),
			scale: new Vector()
			});

		collider = Polygon.square(pos.x, pos.y, size, true);
	}

	inline function collision_fx()
	{
		entity.events.queue('Ball.Collide', this);

		Actuate.tween(scale, 0.25, { x: 0.5, y: 0.5}).ease(luxe.tween.easing.Elastic.easeOut).onComplete(
			function(_)
			{
				Actuate.tween(scale, 0.5, { x: 1.0, y: 1.0}).ease(luxe.tween.easing.Elastic.easeOut);
			});

		Actuate.tween(light.scale, 0.25, { x: 1.0, y: 1.0 }).ease(luxe.tween.easing.Cubic.easeOut).onComplete(
			function(_) 
			{ 
				Actuate.tween(light.scale, 1, { x: 0.0, y: 0.0 }).ease(luxe.tween.easing.Cubic.easeOut);
			});
	}

	inline function check_bounds()
	{
		if ((entity.pos.x < minPos.x && velocity.x < 0) || (velocity.x > 0 && entity.pos.x > maxPos.x))
		{
			velocity.x *= -1;
			//Luxe.events.fire('Ball.Disappear');
			collision_fx();
		}
		else if ((entity.pos.y < minPos.y && velocity.y < 0) || (velocity.y > 0 && entity.pos.y > maxPos.y))
		{
			velocity.y *= -1;
			collision_fx();
		}
	}

	inline function check_collisions()
	{
		if (collider == null) return;

		collider.position = pos;

		for (e in Luxe.scene.entities)
		{
			if (e == entity) continue;

			if (e.active && e.has('ActorBehavior'))
			{
				var actor : ActorBehavior = e.get('ActorBehavior');

				if (actor.collider == null) continue;

				actor.collider.position = e.pos;

				var collision = Collision.shapeWithShape(collider, actor.collider);

				if (collision != null)
				{
					var v = collision.unitVector;

					if (e.name.startsWith('Enemy'))
					{
						trace('hit ' + e.name);
						var enemy : EnemyBehavior = e.get('EnemyBehavior');
						enemy.hit(1);
					}

					trace('collision unit vector = $v | separation = ' + collision.separation);

					if (v.x != 0) velocity.x *= -1;
					if (v.y != 0) velocity.y *= -1;
					collision_fx();

				}
			}
		}
	}

	override function update(dt:Float)
	{
		entity.pos.add_xyz(velocity.x * dt, velocity.y * dt, 0);

		check_bounds();
		check_collisions();
	}
}