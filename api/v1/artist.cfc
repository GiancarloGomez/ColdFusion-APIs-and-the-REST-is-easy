component rest="true" restpath="v1/artist" extends="apiAuth" {

	remote struct function getAll()
		httpmethod 		= "GET"
		produces 		= "application/json"
	{
		var response 	= prepareResponse();
		// get artists (if valid request)
		if (validateRequest()){
			response.data 	= entityLoad("Artist",{},"firstName,lastName");
			response.total 	= response.data.len();
		}
		// return response
		return response;
	}

	remote struct function get(
		required numeric artistID restargsource = "path" // path , query , form , matrix , header  or cookie
	)
		httpmethod 		= "GET"
		produces 		= "application/json"
		restpath 		= "{artistID}"
	{
		var response 	= prepareResponse();
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
		httpmethod 	= "POST"
		produces 	= "application/json"
	{
		var response 	= prepareResponse();
		// create artist (if valid request)
		if (validateRequest()){
			response.data = entityNew("Artist",{
				firstName : firstName,
				lastName : lastName,
				address : address,
				city : city,
				state : state,
				postalCode : postalCode,
				email : email,
				phone : phone,
				thePassword : thePassword
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
		produces 		= "application/json"
	{
		var response 	= prepareResponse();
		// update artist (if valid request)
		if (validateRequest()){
			response.data = entityLoadByPK("Artist", arguments.artistID);
			// validate this response
			validateResponse(response);
			// continue with update
			if (!isNull(response.data)){
				response.data.setFirstName(firstName);
				response.data.setLastName(lastName);
				response.data.setAddress(address);
				response.data.setCity(city);
				response.data.setState(state);
				response.data.setPostalCode(postalCode);
				response.data.setEmail(email);
				response.data.setPhone(phone);
				response.data.setThePassword(thePassword);
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
		produces 		= "application/json"
	{
		var response 	= prepareResponse();
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