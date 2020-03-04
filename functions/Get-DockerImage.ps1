# Gets a list of docker images either by name glob, or by Id / partial Id
function Get-DockerImage {
    <#
    .SYNOPSIS
        Gets Docker image information for images on the current host

    .DESCRIPTION
        Query docker for a list of images with the option to filter on Name mask or Partial Id

    .PARAMETER Id
        The target image Id or partial Id

    .PARAMETER Name
        The target image Name or Name mask. Name is considered to be '{Repository}:{Tag}'

    .PARAMETER Force
        Include intermediate images

    .NOTES
        Tags: docker, image, images
        Author: Chad Baldwin (@cl)

    .LINK
        https://github.com/chadbaldwin/Powershell-Docker/blob/master/functions/Get-DockerImage.ps1

    .EXAMPLE
        PS C:\> Get-DockerImage

        Returns all images

    .EXAMPLE
        PS C:\> Get-DockerImage -Force

        Returns all images, including intermediate images

    .EXAMPLE
        PS C:\> Get-DockerImage -Id 3e

        Returns images(s) with Id starting with 3e

    .EXAMPLE
        PS C:\> Get-DockerImage -Name *dotnet*

        Returns images(s) whose name matches *dotnet*
    #>
    [CmdletBinding(DefaultParameterSetName='Default')]

    Param(
        [Parameter(Mandatory=$true, ParameterSetName='ById')]
        [ValidateNotNullOrEmpty()]
        [String]$Id,
        
        [Parameter(Mandatory=$true, ParameterSetName='ByName')]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [Parameter(Mandatory=$false)]
        [Switch]$Force
    );
    
    process {
        if ($Force) {
            $objects = docker image ls -a --no-trunc --format='{{json .}}' | ConvertFrom-Json;
        } else {
            $objects = docker image ls --no-trunc --format='{{json .}}' | ConvertFrom-Json;
        };

        switch ($psCmdlet.ParameterSetName) {
            'ById'    { $returnObjects = $objects | Where-Object ID -like "sha256:$Id*"; }
            'ByName'  { $returnObjects = $objects | Where-Object { $_.Repository+':'+$_.Tag -like "$Name"; }; }
            'Default' { $returnObjects = $objects; }
        };
        
        return $returnObjects;
    };
};