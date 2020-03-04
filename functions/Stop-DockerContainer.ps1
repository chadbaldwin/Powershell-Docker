# Stop docker container based on Name, ID or pipeline input
function Stop-DockerContainer {
    <#
    .SYNOPSIS
        Stops a docker container from running

    .DESCRIPTION
        Stop a docker container by using the name, Id, pipeline, or -All to stop everything

    .PARAMETER Id
        The target containers Id or partial Id

    .PARAMETER Name
        The target containers Name or Name mask

    .PARAMETER All
        Used without any other parameters, -All will stop every currently running container on the host

    .PARAMETER InputObject
        Enables piped input from Get-DockerContainer

    .NOTES
        Tags: docker, container, containers
        Author: Chad Baldwin (@cl)

    .LINK
        https://github.com/chadbaldwin/Powershell-Docker/blob/master/functions/Stop-DockerContainer.ps1

    .EXAMPLE
        PS C:\> Stop-DockerContainer -All

        Stops all currently running containers on the host

    .EXAMPLE
        PS C:\> Stop-DockerContainer -Id 3e

        Stops ALL containers whose Id starts with 3e

    .EXAMPLE
        PS C:\> Stop-DockerContainer -Name *dotnet*

        Stops ALL containers whose Name matches *dotnet*

    .EXAMPLE
        PS C:\> Get-DockerContainer -Name *dotnet* | Stop-DockerContainer

        Stops ALL containers whose Name matches *dotnet*
    #>
    [CmdletBinding(DefaultParameterSetName='ById')]

    param(
        [Parameter(Mandatory, ParameterSetName='ById')]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory, ParameterSetName='ByName')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory, ParameterSetName='ByPipeline', ValueFromPipeline)]
        $InputObject,

        [Parameter(Mandatory, ParameterSetName='All')]
        [Switch]$All
    );
    
    process {
        switch ($psCmdlet.ParameterSetName) {
            'ByPipeline' { $containers = $InputObject; }
            'ById'       { $containers = Get-DockerContainer -Id $Id; }
            'ByName'     { $containers = Get-DockerContainer -Name $Name; }
            'All'        { $containers = Get-DockerContainer; }
        };
        
        If (!($containers)) {
            return;
        };
        
        docker stop ($containers.ID);
        return;
    };
};