<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>THE API</title>
	<style>
		body {
			font:normal 14px/1.4 'Operator Mono Ssm', Menlo, Consolas, monospace;
		}
		#dump table { width:100%; }
		#dump table tr {vertical-align: top;}
		#dump table[class*="cfdump"] { font:inherit; }
		header {
			display: flex;
			justify-content: space-between;
		}
		header a {
			background-color: #ddd;
			border:1px solid #ccc;
			box-sizing: border-box;
			color: #111;
			display: block;
			padding:.5em;
			text-align: center;
			text-decoration:none;
			text-transform: uppercase;
			width: calc(25% - 2px);
		}
		header a:hover,header a:active{
			background-color: #ccc;
		}
	</style>
</head>
<body>
	<header>
		<a href="./?reload">Reload App</a>
		<a href="./?reload-rest">Reload Rest</a>
		<a href="./?reload-orm">Reload ORM</a>
		<a href="./?reload-artists">Reload Artists</a>
	</header>
	<div style="text-align: center; margin:1em 0; ">
		<cfoutput>
			<strong>APP :</strong> #dateTimeFormat(application.timeStamp,"short")#
			&bull;
			<strong>ORM :</strong> #dateTimeFormat(application.ormTimeStamp,"short")#
			&bull;
			<strong>REST :</strong> #dateTimeFormat(application.restTimeStamp,"short")#
		</cfoutput>
	</div>
	<div id="dump">
		<cfscript>
			artists = queryExecute("
				SELECT 	firstname || ' ' || lastname || ' <' || email || '>' AS artist
			 	FROM 	artists
			 	ORDER BY artist");
		</cfscript>
		<table>
			<tr>
				<td width="50%"><cfdump var="#artists#" label="Artists" metainfo="false" /></td>
				<td width="50%"><cfdump var="#getApplicationMetadata()#" label="Application Metadata" /></td>
			</tr>
		</table>
	</div>
</body>
</html>