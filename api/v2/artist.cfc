component rest="true" restpath="v2/artist" extends="apiAuth" {

	variables.version = "2.0";

	remote struct function getAll()
		httpmethod 		= "GET"
		returnformat 	= "json"
	{
		var response 	= prepareResponse(variables.version);
		var results 	= [];
		// get artists (if valid request)
		if (validateRequest()){
			results 	= entityLoad("Artist",{},"firstName,lastName");
			// lets remove thePassword from each
			for (var result in results){
				response.data.append({
					"postalCode" 	: result.getPostalCode(),
					"city" 			: result.getCity(),
					"lastName" 		: result.getLastName(),
					"address" 		: result.getAddress(),
					"phone" 		: result.getPhone(),
					"state" 		: result.getState(),
					"firstName" 	: result.getFirstName(),
					"email" 		: result.getEmail(),
					"artistID" 		: result.getArtistID()
				});
			}
			response.total 	= response.data.len();
		}
		// return response
		return response;
	}

	remote struct function get(
		required numeric artistID restargsource = "path" // path , query , form , matrix , header  or cookie
	)
		httpmethod 		= "GET"
		restpath 		= "{artistID}"
	{
		var response 	= prepareResponse(variables.version);
		// get the artist (if valid request)
		if (validateRequest()){
			response.data 	= entityLoadByPK("Artist", arguments.artistID);
			// validate this response
			validateResponse(response);
		}
		// return response
		return response;
	}

	remote struct function create(
		required string firstName 		restargsource = "form",
		required string lastName 		restargsource = "form",
		required string address 		restargsource = "form",
		required string city 			restargsource = "form",
		required string state 			restargsource = "form",
		required string postalCode 		restargsource = "form",
		required string email 			restargsource = "form",
		required string phone 			restargsource = "form",
		required string thePassword 	restargsource = "form"
	)
		httpmethod 		= "POST"
	{
		var response 	= prepareResponse(variables.version);
		// create artist (if valid request)
		if (validateRequest()){
			response.data = entityNew("Artist",{
				firstName 	: arguments.firstName,
				lastName 	: arguments.lastName,
				address 	: arguments.address,
				city 		: arguments.city,
				state 		: arguments.state,
				postalCode 	: arguments.postalCode,
				email 		: arguments.email,
				phone 		: arguments.phone,
				thePassword : arguments.thePassword
			});
			transaction { entitySave(response.data); }
		}
		// return response
		return response;
	}

	remote struct function update(
		required numeric artistID 		restargsource = "path",
		required string firstName 		restargsource = "form",
		required string lastName 		restargsource = "form",
		required string address 		restargsource = "form",
		required string city 			restargsource = "form",
		required string state 			restargsource = "form",
		required string postalCode 		restargsource = "form",
		required string email 			restargsource = "form",
		required string phone 			restargsource = "form",
		required string thePassword 	restargsource = "form"
	)
		httpmethod 		= "PUT"
		restpath 		= "{artistID}"
	{
		var response 	= prepareResponse(variables.version);
		// update artist (if valid request)
		if (validateRequest()){
			response.data = entityLoadByPK("Artist", arguments.artistID);
			// validate this response
			validateResponse(response);
			// continue with update
			if (!isNull(response.data)){
				response.data.setFirstName(arguments.firstName);
				response.data.setLastName(arguments.lastName);
				response.data.setAddress(arguments.address);
				response.data.setCity(arguments.city);
				response.data.setState(arguments.state);
				response.data.setPostalCode(arguments.postalCode);
				response.data.setEmail(arguments.email);
				response.data.setPhone(arguments.phone);
				response.data.setThePassword(arguments.thePassword);
				transaction { entitySave(response.data); }
			}
		}
		// return response
		return response;
	}

	remote struct function delete(
		required numeric artistID restargsource = "path"
	)
		httpmethod 		= "DELETE"
		restpath 		= "{artistID}"
	{
		var response 	= prepareResponse(variables.version);
		// delete artist (if valid request)
		if (validateRequest()){
			response.data = entityLoadByPK("Artist", arguments.artistID);
			// validate this response
			validateResponse(response);
			// continue with delete
			if (!isNull(response.data)){
				transaction { entityDelete(response.data); }
				structDelete(response,"success");
				structDelete(response,"data");
				response.deleted 	= true;
				response.id 		= int(arguments.artistID); // so it does not return decimal
			}
		}
		// return response
		return response;
	}
}