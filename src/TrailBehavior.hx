import luxe.Component;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;

class TrailBehavior extends Component
{
	var trail : Array<Sprite> = [];

	var trails : Int = 5;
	var size : Vector;
	var color : Color;

	public function new(_size:Vector, _color:Color, ?_trails:Int = 5, ?_options:luxe.options.ComponentOptions)
	{
		super(_options);

		size = _size;
		trails = _trails;
		color = _color;
	}

	override function init()
	{
		for (i in 0...trails)
		{
			var a = 1.0 - ((1.0 / trails) * i);

			trail.push(new Sprite({
				name: '${entity.name}.trail.$i',
				pos: entity.pos.clone(),
				color: color.clone(),
				size: size,
				centered: true,
				depth: trails - i,
				}));

			trail[i].color.a = a;
		}
	}

	public function visible(show:Bool)
	{
		for (t in trail)
		{
			t.visible = show;
		}

		if (show) update_trail();
	}

	function update_trail()
	{
		var delta_pos = Vector.Subtract(trail[0].pos, pos);

		if (delta_pos.length < 2)
		{
			return;
		}

		for (i in 0...trails)
		{
			trail[i].pos = pos.clone().add(Vector.Multiply(delta_pos.normalized, 5 * (i + 1)));
			trail[i].scale = scale.clone();
			trail[i].rotation = rotation.clone(); 
		} 
	}

	override function update(dt:Float)
	{
		if (trail.length > 0) update_trail();
	}
}