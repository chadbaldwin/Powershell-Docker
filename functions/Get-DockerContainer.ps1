# Gets a list of docker images either by name glob, or by Id / partial Id
function Get-DockerContainer {
	[CmdletBinding(DefaultParameterSetName="Default")]

	Param(
		[Parameter(Mandatory=$true, ParameterSetName="ById")]   [ValidateNotNullOrEmpty()] [String[]]$Id,
		[Parameter(Mandatory=$true, ParameterSetName="ByName")] [ValidateNotNullOrEmpty()] [String[]]$Name
	);

	$objects = docker container ls --no-trunc --format='{{json .}}' | ConvertFrom-Json;

	switch ($psCmdlet.ParameterSetName) {
		"ById"    { $returnObjects = $objects | ? ID -like "$Id*"; }
		"ByName"  { $returnObjects = $objects | ? Names -like "$Name"; }
		"Default" { $returnObjects = $objects; }
	};
	
	return $returnObjects;
};