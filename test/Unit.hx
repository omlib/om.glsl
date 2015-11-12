
class Unit {

    static function main() {
        var r = new haxe.unit.TestRunner();
        r.add( new TestLexer() );
    	r.run();
    }
}
