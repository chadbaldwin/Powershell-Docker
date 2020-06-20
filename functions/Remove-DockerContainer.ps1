# Remove docker container based on Name, ID or pipeline input
function Remove-DockerContainer {
    <#
    .SYNOPSIS
        Removes a docker container

    .DESCRIPTION
        Remove a docker container by using the name, Id, pipeline, or -All to remove everything. By default, only removes stopped containers. Must use -Force to remove running containers.

    .PARAMETER Id
        The target containers Id or partial Id

    .PARAMETER Name
        The target containers Name or Name mask

    .PARAMETER All
        Used without any other parameters, -All will remove every stopped container on the host

    .PARAMETER Force
        Include containers that are running

    .PARAMETER InputObject
        Enables piped input from Get-DockerContainer

    .NOTES
        Tags: docker, container, containers
        Author: Chad Baldwin (@cl)

    .LINK
        https://github.com/chadbaldwin/Powershell-Docker/blob/master/functions/Remove-DockerContainer.ps1

    .EXAMPLE
        PS C:\> Remove-DockerContainer -All

        Remove ALL stopped containers on the host

    .EXAMPLE
        PS C:\> Remove-DockerContainer -Id 3e

        Removes ALL containers whose Id starts with 3e

    .EXAMPLE
        PS C:\> Remove-DockerContainer -Name *dotnet*

        Removes ALL containers whose Name matches *dotnet*

    .EXAMPLE
        PS C:\> Get-DockerContainer -Name *dotnet* | Remove-DockerContainer

        Removes ALL containers whose Name matches *dotnet*
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
        [Switch]$All,

        [Parameter(Mandatory=$false)]
        [Switch]$Force
    );
    
    process {
        $containers = switch ($psCmdlet.ParameterSetName) {
            'ByPipeline' { $InputObject; }
            'ById'       { Get-DockerContainer -Id $Id; }
            'ByName'     { Get-DockerContainer -Name $Name; }
            'All'        { Get-DockerContainer -Force; }
        };
        
        If (!($containers)) {
            return;
        };
        
        if ($Force) {
            docker rm -f ($containers.ID);
        } else {
            docker rm ($containers.ID);
        }
        return;
    };
};

# Enable auto complete parameter values
Register-ArgumentCompleter -CommandName Remove-DockerContainer -ParameterName Name -ScriptBlock { (Get-DockerContainer -Force).Name.Substring(1) }
Register-ArgumentCompleter -CommandName Remove-DockerContainer -ParameterName Id -ScriptBlock { (Get-DockerContainer -Force).Id.Substring(0,12) }