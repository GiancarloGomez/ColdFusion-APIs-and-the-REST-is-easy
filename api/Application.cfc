component {
	this.name 		= "rest_demo";
	this.datasource = "cfartgallery";

	// 2016 performance enhancements
	this.searchImplicitScopes = false;
	this.passArrayByReference = true;

	// Our default serialization options
	// for queries (row, column or struct)
	this.serialization = {
		preserveCaseForStructKey 	: true,
		serializeQueryAs 			: "struct"
	};

	// publish the CFCs only in a particular location
	// ignore a cfc with an error and continue to load
	// auto register application - requires reload in admin
	this.restSettings = {
		cfclocation 		: "v1,v2",
		skipCFCWithError  	: false,
		autoregister 		: true,
		usehost 			: true,
		isDefault 			: true,
		servicemapping 		: "rest_demo"
	};

	// orm settings
	this.ormEnabled		= true;
	this.ormSettings 	= {
		automanageSession		: false,
		cfclocation				: "orm/",
		dbcreate				: "none",
		flushAtRequestEnd		: false,
		logSQL					: false,
		secondaryCacheEnabled	: true,
		cacheConfig 			: "orm/rest_demo.xml"
	};

	public function onApplicationStart() {
		reloadArtists();
		ormReload();
		restReload();
		application.timeStamp 		=
		application.ormTimeStamp 	=
		application.restTimeStamp 	= now();
	}

	public function onRequestStart() {
		if (structKeyExists(url,"reload")){
			applicationStop();
			location("./",false);
		}
		else if (structKeyExists(url,"reload-rest")){
			lock scope="Application" type="exclusive" timeout="10"{
				restReload();
				application.restTimeStamp = now();
			}
			location("./",false);
		}
		else if (structKeyExists(url,"reload-orm")){
			lock scope="Application" type="exclusive" timeout="10"{
				ormReload();
				application.ormTimeStamp = now();
			}
			location("./",false);
		}
		else if (structKeyExists(url,"reload-artists")){
			reloadArtists();
			location("./",false);
		}
	}

	private function restReload(){
		// First we attempt to delete as in the attempt to reload we might get an error stating
		// Multiple default applications cannot be registered for the {{server_name}} host.
		try {
			restDeleteApplication(expandPath("./"));
		} catch (any e) {}
		// https://helpx.adobe.com/coldfusion/cfml-reference/coldfusion-functions/functions-m-r/restinitapplication.html
		// in my tests this does not reload so I attempt to delete previously
		restInitApplication(expandPath("./"), "rest_demo",{
			cfclocation 		: "v1,v2",
			skipCFCWithError  	: false,
			useHost 			: true,
			isDefault 			: true // if this is set to false you have to pass the service mapping
		});
		// other options
		// use ColdFusion Administrator
		// use ColdFusion Admin API
	}

	private function reloadArtists(){
		queryExecute("DELETE FROM artists WHERE artistID > 15");
		queryExecute("ALTER TABLE artists ALTER COLUMN artistID RESTART WITH 16");
	}
}