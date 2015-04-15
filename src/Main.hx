import luxe.Input;
import luxe.States;

typedef GlobalData = {
    views: States,
    p1_score: Int,
    p2_score: Int
}

class Main extends luxe.Game 
{
    var global : GlobalData = { views: null, p1_score: 0, p2_score: 0 };

    override function config(config:luxe.AppConfig) : luxe.AppConfig
    {
        config.window.title = 'Pong Journey';

        return config;
    }

    function setup()
    {
        // Set up batchers, states etc.
        global.views = new States({ name: 'views' });

        //global.views.add(new GameView(global, Luxe.renderer.batcher));
        global.views.add(new PlatformerView(global, Luxe.renderer.batcher));
        //global.views.set('GameView');
        global.views.set('PlatformerView');
    }

    function load_complete(_)
    {
        var enemies = Luxe.resources.find_texture('assets/anims.png');
        enemies.filter = phoenix.Texture.FilterType.nearest;

        setup();
    }

    override function ready()
    {
        Luxe.loadJSON('assets/parcel.json', function(json_asset) 
            {
                var preload = new luxe.Parcel();
                preload.from_json(json_asset.json);

                new luxe.ParcelProgress({
                    parcel: preload,
                    background: new luxe.Color(1, 1, 1, 0.85),
                    oncomplete: load_complete
                    });

                preload.load();
            }
        );
    } //ready

    override function onkeyup( e:KeyEvent ) 
    {
        if (e.keycode == Key.escape) 
        {
            Luxe.shutdown();
        }

    } //onkeyup

    override function update(dt:Float) 
    {
    } //update
    
} //Main
