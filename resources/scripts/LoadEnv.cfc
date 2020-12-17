component {

	public function run(){
		properties = propertyFile('../../.env').getAsStruct();

		var javaSystem = createObject("java","java.lang.System");
        for (var key in properties) {
            javaSystem.setProperty( key, properties[ key ] );
        }

        //print.text( getInstance("Formatter").formatJSON(properties) );
	}
}