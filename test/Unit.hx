
class Unit {

    static function main() {
        var r = new haxe.unit.TestRunner();
        r.add( new TestTokenizer() );
        r.add( new TestPreprocessor() );
    	r.run();
    }
}
