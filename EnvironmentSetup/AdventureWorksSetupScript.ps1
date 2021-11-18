# AdventureWorksSQLSnowflakeSetup.ps1
#
# Revision history
# 2021-11-16 Jose Chacón
# - Added SQL Server and Snowflake configure scripts for SSRS and Power BI Labs
# - Added easy to follow flow

##--  SQL Server AdventureWorks2019 Database Setup  --##
function Setup-AdventureWorks-SQL {
	Write-Output "---------------"
	Write-Output "SQL Server connection credentials:"
	$database = "AdventureWorks2019"
	$server = Read-Host -Prompt "Specify SQL Server Instance"
	$sql_credential = (Get-Credential)
	
	Write-Output $server

	##--  Views and Procedure Creation  --##
	Write-Output "Creating SQL Server custom views and procedures for labs..."
	#Invoke-Sqlcmd -ServerInstance $server -Database $database -InputFile "AventureWorksLabsObjectsSQLServer.sql" -Credential $sql_credential -ErrorAction Stop
	Write-Output "Successfully created SQL Server views and procedures."
}

##--  Snowflake Objects and Data Setup  --##
function Setup-AdventureWorks-Snowflake {
	Write-Output "---------------"
	Write-Output "Snowflake connection credentials:"
	$account = Read-Host -Prompt "Specify Snowflake account. If not sure, refer to this page for more information https://docs.snowflake.com/en/user-guide/admin-account-identifier.html"
	$user = Read-Host -Prompt "User"
	$role = Read-Host -Prompt "Role"
	
	Write-Output "Configuring Snowflake AdventureWorks database..."
	snowsql -a $account -u $user -r $role -f "AdventureWorksLabsObjectsSnowflake.sql"
	Write-Output "Finished configuring Snowflake AdventureWorks."
}

##--  Function for different installation options  --##
function Request-Installation-Requirements {
	$installation = Read-Host -Prompt $options_message
	if ($installation -eq "A") {
		Validate-Sql
		Validate-Snowflake
		Setup-AdventureWorks-SQL
		Setup-AdventureWorks-Snowflake
	} elseif ($installation -eq "S") {
		Validate-Sql
		Setup-AdventureWorks-SQL
	} elseif ($installation -eq "F") {
		Validate-Snowflake
		Setup-AdventureWorks-Snowflake
	} else {
		Request-Installation-Requirements
	}
}

##--  Validate SQL Requirements  --##
function Validate-Sql {
	$requiredModule = 'SqlServer'
	if (!(Get-Module -ListAvailable -Name $requiredModule)) {
		$install = Read-Host -Prompt "$($requiredModule) module is required but not installed.  Would you like to install? (y/n)"
		if ($install.ToLower() -eq 'y') {
			try { Install-Module -Name $requiredModule -AllowClobber }
			catch {
				Write-Warning "Error installing $($requiredModule) module: $_"
				Exit 1
			}
			Write-Output "Installed $($requiredModule) module..."
		} else {
			Write-Warning "Cannot continue without $($requiredModule) module.  Aborting..."
			Exit 1
		}
	} else { Write-Output "Confirmed $($requiredModule) module installed..." }
}

##--  Validate Snowflake Requirements  --##
function Validate-Snowflake {
	try {
		if(Get-Command "snowsql" -ErrorAction Stop){Write-Output "Confirmed snowsql command is installed..."}
	}
	catch {
		Write-Output "Snowsql is not installed and cannot continue without it. Please refer to https://docs.snowflake.com/en/user-guide/snowsql.html for more information..."
		Exit 1
	}
}

$welcome_message = "----------------------------------------------------------------------
----------------------------------------------------------------------
Welcome to Mobilize.NET SnowConvert Training Labs AdventureWorks Setup

Before continuing, make sure you satisfy the following requirements:
  - Downloaded the AdventureWorks2019.bak file and restored it to your SQL Server instance. In case you don't have it, you can download it here and follow the restore instructions on that page: https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver15&tabs=ssms
  - Snowsql utility is installed.
  - Access to a Snowflake account with the possibility to create databases and schemas.
	  * If not able to do so, check the Readme.me file on the repository for more details.
"

$options_message = "----------------------------------------------------------------------
Would you like to setup ... ?
[S] SQL Server AdventureWorks Objects
[F] Snowflake AdventureWorks Objects
[A] All
"

Write-Output $welcome_message
$requirements = Read-Host -Prompt "Do you satisfy these requirements? [Y] Yes [N] No?"

if ($requirements.toUpper() -eq "Y") {
	Request-Installation-Requirements
} else {
	Write-Output "All requirements are necessary in order to complete the labs. Please configure all the requirements and try again."
}