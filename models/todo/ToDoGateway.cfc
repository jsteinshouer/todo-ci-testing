/**
 *
 * ToDo Gateway
 *
*/
component output="false" singleton="true" {

	/**
	*
	* Constructor
	*
	* @dsn.inject coldbox:datasource:todo
	*
	*/
	public function init(required dsn) {

		variables.dsn = arguments.dsn;

		return this;
	}

	public function getItems() {
		var qItems = queryExecute("
			SELECT p_todo_id, description
			FROM ToDo 
			WHERE completed_date IS NULL
		",{},{datasource = dsn.name});

		return qItems;
	}


	public function getCompletedItems() {
		var qItems = queryExecute("
			SELECT p_todo_id, description, completed_date
			FROM ToDo 
			WHERE completed_date IS NOT NULL
		",{},{datasource = dsn.name});

		return qItems;
	}
	
}