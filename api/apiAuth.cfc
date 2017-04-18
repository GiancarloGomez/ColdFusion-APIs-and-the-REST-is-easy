component {

	package struct function prepareResponse(
		numeric version = "1.0"
	){
		return {
			"success" 	: true,
			"version" 	: arguments.version,
			"data" 		: []
		};
	}

	package boolean function validateRequest(){
		var isAuthorized 	= false;
		var headers 		= GetHTTPRequestData().Headers;
		var auth 			= "";
		var user 			= "";
		var password 		= "";
		var response 		= {};

		if (structKeyExists(headers,"Authorization")){
			try {
				// get Authorization header info
				auth = listLast(headers.Authorization," ");
				// convert from base64 to binary and back to string
				auth = toString(toBinary(auth));
				// set our values
				user = listFirst(auth,":");
				password = listLast(auth,":");
				// validate at this point - this is a basic example, tie in anything at this point
				isAuthorized = !compare(user,"123456") ? true : false;
			}

			catch(Any e){
				isAuthorized = false;
			}
		}

		if (!isAuthorized){
			if (cgi.script_name.find(".cfc"))
				cfheader(statusCode:401,statusText:"No valid API key provided");
			else
				throw(errorcode:401, type:"RestException", message:"No valid API key provided");
		}

		return isAuthorized;
	}

	package void function validateResponse(
		required struct response
	){

		if (
			isNull(arguments.response.data) ||
			( isQuery(arguments.response.data) && !arguments.response.data.recordcount ) ||
			( isArray(arguments.response.data) && !arguments.response.data.len() )
		){
			arguments.response.message = "Artist does not exists";
			arguments.response.success = false;
			structDelete(arguments.response,"data");
			if (cgi.script_name.find(".cfc"))
				cfheader(statusCode:404,statusText:arguments.response.message);
			else
				cfthrow(errorcode:404, type:"RestException", message:arguments.response.message);
		}
	}

}