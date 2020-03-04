# Stop docker container based on Name, ID or pipeline input
function Stop-DockerContainer {
	[CmdletBinding(DefaultParameterSetName="ById")]

	param(
		[Parameter(Mandatory=$true, ParameterSetName="ByPipeline", ValueFromPipeline=$true)] $pipelineInput,
		
		[Parameter(Mandatory=$true, ParameterSetName="ById")]   [ValidateNotNullOrEmpty()] [String[]]$Id,
		[Parameter(Mandatory=$true, ParameterSetName="ByName")] [ValidateNotNullOrEmpty()] [String[]]$Name,
		
		[Parameter(Mandatory=$true, ParameterSetName="All")] [Switch]$All
	);
	
	Process {
		switch ($psCmdlet.ParameterSetName) {
			"ByPipeline" { $containers = $pipelineInput }
			"ById"       { $containers = Get-DockerContainer -Id $Id; }
			"ByName"     { $containers = Get-DockerContainer -Name $Name; }
			"All"        { $containers = Get-DockerContainer }
		};
		
		docker stop ($containers.ID);
		return;
	};
};