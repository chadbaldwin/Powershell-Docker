# Gets a list of docker images either by name glob, or by Id / partial Id
function Get-DockerImage {
	[CmdletBinding(DefaultParameterSetName="Default")]

	Param(
		[Parameter(Mandatory=$true, ParameterSetName="ById")]   [ValidateNotNullOrEmpty()] [String[]]$Id,
		[Parameter(Mandatory=$true, ParameterSetName="ByName")] [ValidateNotNullOrEmpty()] [String[]]$Name
	);

	$objects = docker image ls --no-trunc --format='{{json .}}' | ConvertFrom-Json;

	switch ($psCmdlet.ParameterSetName) {
		"ById"    { $returnObjects = $objects | ? ID -like "sha256:$Id*"; }
		"ByName"  { $returnObjects = $objects | ? { $_.Repository+':'+$_.Tag -like "$Name"; } }
		"Default" { $returnObjects = $objects; }
	};
	
	return $returnObjects;
};