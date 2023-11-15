$SQL = @'
SELECT TOP (100) 
       [ID]
      ,[Restaurant]
      ,[Flag]
      ,[Address]
      ,[City]
      ,[State]
      ,[Zip]
      ,CAST([Lon] AS VARCHAR(20)) As [Lon]
	  ,CAST([Lat] AS VARCHAR(20)) AS [Lat]
  FROM [Geospatial].[dbo].[us_fast_food]
 -- FOR JSON PATH
'@ 

#---------------------------------------

Import-Module SQLPS -DisableNameChecking

$instancename = "DESKTOP-156BLFL\SQL_2019"
$server = New-object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instancename

$dbname = "Geospatial"
$db= $server.Databases[$dbname]

$exportfilename = "C:\app\Tor\EXCEL_DEMO_DIR\us_food_restaurants_compressed.json" 

$data = Invoke-Sqlcmd -Query $SQL -ServerInstance "$instancename" -Database $dbname |
                  Select-Object * -ExcludeProperty ItemArray, Table, RowError, RowState, HasErrors |
                  ConvertTo-Json -Depth 1 -Compress

$data

$data |Out-File -FilePath $exportfilename -Encoding utf8 #ascii