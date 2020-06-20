# Gets a list of docker images either by name glob, or by Id / partial Id
function Get-DockerContainer {
    <#
    .SYNOPSIS
        Gets Docker container information for containers on the current host

    .DESCRIPTION
        Query docker for a list of containers with the option to filter on Name mask or Partial Id

    .PARAMETER Id
        The target containers Id or partial Id

    .PARAMETER Name
        The target containers Name or mask
        
    .PARAMETER ImageName
        The target containers Image name or mask

    .PARAMETER Force
        Include containers that are not running

    .NOTES
        Tags: docker, container, containers
        Author: Chad Baldwin (@cl)

    .LINK
        https://github.com/chadbaldwin/Powershell-Docker/blob/master/functions/Get-DockerContainer.ps1

    .EXAMPLE
        PS C:\> Get-DockerContainer

        Returns all containers
        
    .EXAMPLE
        PS C:\> Get-DockerContainer -Force

        Returns all containers including containers that are not running

    .EXAMPLE
        PS C:\> Get-DockerContainer -Id 3e

        Returns container(s) with Id starting with 3e

    .EXAMPLE
        PS C:\> Get-DockerContainer -Name *dotnet*

        Returns container(s) whose name matches *dotnet*
    #>
    [CmdletBinding(DefaultParameterSetName='Default')]

    Param(
        [Parameter(Mandatory=$true, ParameterSetName='ById')]
        [ValidateNotNullOrEmpty()]
        [String]$Id,
        
        [Parameter(Mandatory=$true, ParameterSetName='ByName')]
        [ValidateNotNullOrEmpty()]
        [String]$Name,
        
        [Parameter(Mandatory=$true, ParameterSetName='ByImageName')]
        [ValidateNotNullOrEmpty()]
        [String]$ImageName,

        [Parameter(Mandatory=$false)]
        [String]$Status,
        
        [Parameter(Mandatory=$false)]
        [Switch]$Force
    );

    process {
        $baseCommand = 'docker ps --quiet'
        if ($Force) { $baseCommand += ' -a' };
        if ($Status) { $baseCommand += " --filter 'status=$Status'" };
        
        $containerIds = iex $baseCommand;
        
        if ($containerIds) {
            $objects = docker inspect ($containerIds) | ConvertFrom-Json;
        } else {
            return;
        };

        $containers = switch ($psCmdlet.ParameterSetName) {
            'ById'         { $objects | Where-Object ID -like "$Id*"; }
            'ByName'       { $objects | Where-Object Name -like "/$Name"; }
            'ByImageName'  { $objects | Where-Object {$_.Config.Image -like "*$ImageName*"} }
            'Default'      { $objects; }
        };
        
        return $containers;
    };
};

# Enable auto complete parameter values
Register-ArgumentCompleter -CommandName Get-DockerContainer -ParameterName Status -ScriptBlock { 'Created', 'Restarting', 'Running', 'Removing', 'Paused', 'Exited', 'Dead' }
Register-ArgumentCompleter -CommandName Get-DockerContainer -ParameterName Name -ScriptBlock { (Get-DockerContainer -Force).Name.Substring(1) }
Register-ArgumentCompleter -CommandName Get-DockerContainer -ParameterName Id -ScriptBlock { (Get-DockerContainer -Force).Id.Substring(0,12) }
Register-ArgumentCompleter -CommandName Get-DockerContainer -ParameterName ImageName -ScriptBlock { (Get-DockerContainer -Force).Config.Image | Select-Object -Unique }