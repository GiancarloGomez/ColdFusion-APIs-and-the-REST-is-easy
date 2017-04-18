component
  table 		= "Artists"
  entityname 	= "Artist"
  persistent 	= "true"
{
	property name="artistID" 				fieldtype="id" 			generator="native" setter="false";
	property name="firstName"				ormtype="string" 		length="20";
	property name="lastName"				ormtype="string" 		length="20";
	property name="address"					ormtype="string" 		length="50";
	property name="city"					ormtype="string" 		length="20";
	property name="state"					ormtype="string" 		length="2";
	property name="postalCode"				ormtype="string" 		length="10";
	property name="email"					ormtype="string" 		length="50";
	property name="phone"					ormtype="string" 		length="12";
	property name="thePassword"				ormtype="string" 		length="8";
}