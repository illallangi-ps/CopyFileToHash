function Copy-FileToHash
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [object[]]$Path,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$Hash,

        [Parameter(Mandatory=$true)]
        [string]$BasePath
    )

    BEGIN
    {
        $collection = @()
    }

    PROCESS
    {
        foreach ($obj in @($Path))
        {
            $fileName = $obj.ToString()
            if ($obj.GetType().Name -eq "FileInfo")
            {
                $fileName = $obj.FullName
            }
            $collection += [PSCustomObject]@{
                                    Path=$fileName;
                                    Hash=$Hash;
                                }
        }
    }

    END
    {
        New-Item -ItemType Directory -Path $BasePath -Force

        foreach ($i in 1..($collection.Count))
        {
            $obj = $collection[$i - 1]
            if ($obj.Hash -eq $null -or $obj.Hash -eq "")
            {
                $obj=(Get-FileHash -Path $obj.Path -Algorithm SHA256);
            }
            Write-Progress -Activity "Copying File(s) to Hash Location" -Status "$($i)/$($collection.Count): $($obj.Path)" -PercentComplete (($i / $collection.Count) * 100)
            Write-Debug "Copy-FileToHash -BasePath ""$($BasePath)"""
            Write-Debug "                -Path ""$($obj.Path)"""
            Write-Debug "                -Hash ""$($obj.Hash)"""

            Copy-Item -Path $obj.Path -Destination (Join-Path $BasePath "$($obj.Hash.ToLower())$((Get-Item $obj.Path).Extension)") -Force
        }
        Write-Progress -Activity "Copying File(s) to Hash Location" -Completed
    }
}