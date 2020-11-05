create procedure [dbo].[sp_sendToSFTP] @kode varchar(500), @versi varchar(3)
as
declare @dbName					varchar(50)		= 'Apolo'
declare @schemaName				varchar(50)		
declare @tableName				varchar(500)	
declare @columnName				varchar(8000)
declare	@delimiter				char(1)			= '|'
declare	@flagHeader				varchar(3)			
declare @kodeLaporan			varchar(5)	
declare @kodeForm				varchar(10)	
declare @kodeSektor				varchar(10)	
declare @kodeDetail				varchar(5)
declare @jenisBank				varchar(3)	
declare @sandiLJK				char(3)			
declare @posisiLaporan			varchar(8)		= convert(varchar,eomonth(dateadd(m,-1,getdate())),112)
declare @posisiLaporanHeader	varchar(10)		= convert(date,@posisiLaporan)
declare @periodeLaporan			char(1)			
declare @versiLaporan			varchar(3)		= @versi

select 
@schemaName		  = schemaName,
@tableName		  = tableName,
@flagHeader		  = header,
@kodeLaporan	  = kodeLaporan,
@kodeForm		  = kodeForm,
@sandiLJK		  = sandiLJK,
@periodeLaporan	  = periodeLaporan,
@kodeSektor		  = kodeSektor,
@kodeDetail		  = detail,
@jenisBank		  = jenisBank
from fileFormat
where kodeLaporan = @kode

declare @extension				varchar(5)		= 'txt'
declare @localPath				varchar(100)	= 'D:\Apolo\'
declare @fileName				varchar(1000)	= @kodeLaporan+'-'+@kodeForm+'-'+@versiLaporan+'-'+@periodeLaporan+'-'+@posisiLaporan+'-'+@sandiLJK+'-'+@jenisBank+'.'+@extension
declare @query					varchar(8000) 
declare @bcp					varchar(8000)
declare @mkdir					varchar(100)
declare @SFTPPath				varchar(250)	= '/apollo/Restruktur/'
declare @cmd					varchar(1000)
declare @SFTPServer				varchar(250)    = '10.14.19.49'
declare @SFTPUser				varchar(250)    = 'dwh.apollo'
declare @SFTPPWD				varchar(250)    = '7rMM3$U5'
declare @commandString			varchar(8000)

select 
@columnName = (select left(convert(varchar(max),(select 'isnull(convert(varchar(max),ltrim(rtrim(['+COLUMN_NAME+']))),'''')+'''+@delimiter+'''+' from INFORMATION_SCHEMA.COLUMNS
			  where TABLE_SCHEMA = @schemaName and TABLE_NAME = @tableName and COLUMN_NAME not in ('id','status')
			  for xml path(''))),
			  len(convert(varchar(max),(select 'isnull(convert(varchar(max),ltrim(rtrim(['+COLUMN_NAME+']))),'''')+'''+@delimiter+'''+' from INFORMATION_SCHEMA.COLUMNS
			  where TABLE_SCHEMA = @schemaName and TABLE_NAME = @tableName and COLUMN_NAME not in ('id','status')
			  for xml path(''))))-5))

set @query = 'select '''+@flagHeader+@delimiter+@kodeSektor+@delimiter+@sandiLJK+@delimiter+@posisiLaporanHeader+@delimiter+@kodeLaporan+@delimiter+@kodeForm+''' union all select '''+@kodeDetail+@delimiter+'''+'+@columnName+' from '+@dbName+'.'+@schemaName+'.'+@tableName
set @bcp = 'bcp "'+@query+'" queryout '+@localPath+@fileName+' -c -t, -T'
set @mkdir = 'mkdir "'+@localPath+'"'

exec master.dbo.xp_cmdshell @mkdir, no_output
exec master.dbo.xp_cmdshell @bcp, no_output

/*
------------------------------------------------------------------------------FTP--------------------------------------------------------------------------------------------------------------------
--check folder exists or create folder server 10.11.25.175
set @cmd = 'IF not exist "' + @localPath + '" (mkdir "' + @localPath + '")'
exec master.dbo.xp_cmdshell @cmd, no_output

--open ftp
set @cmd = 'echo ' + 'open ' + @FTPServer + '>> "' + @localPath + @workfilename + '"'
exec master.dbo.xp_cmdshell @cmd,no_output

--login username
set @cmd = 'echo ' + @FTPUser + '>> "' + @localPath + @workfilename + '"'
exec master.dbo.xp_cmdshell @cmd,no_output

-- login password
set @cmd = 'echo ' + @FTPPWD + '>> "' + @localPath + @workfilename + '"'
exec master.dbo.xp_cmdshell @cmd,no_output

-- create directory
set @cmd = 'echo ' + 'mkdir "' + @FTPPath + '">> "' + @localPath + @workfilename + '"'
exec master.dbo.xp_cmdshell @cmd,no_output

set @cmd = 'echo ' + 'put "' + @localPath + @FileName + '" "' + @FTPPath + @FileName + '">> "' + @localPath + @workfilename + '"'
exec master.dbo.xp_cmdshell @cmd,no_output

-- close ftp
SET @cmd = 'echo ' + 'quit' + ' >> "' + @localPath + @workfilename + '"'
exec master.dbo.xp_cmdshell @cmd,no_output

-- run ftp
SET @cmd = 'ftp -s:"' + @localPath + @workfilename + '"'
exec master..xp_cmdshell @cmd,no_output
*/

------------------------------------------------------------------------------SFTP--------------------------------------------------------------------------------------------------------------------
--Delete Existing files if they exist
     SET @CommandString = 'del "'+ @localPath + 'SFTPUploadScript.txt"'
    EXEC master..xp_cmdshell @CommandString, no_output
     SET @CommandString = 'del "'+ @localPath + 'SFTPUploadScript.bat"'
    EXEC master..xp_cmdshell @CommandString, no_output

--Create Batch fle with login credentials
     SET @CommandString = 'echo "'+ @localPath +'psftp.exe" ' + @SFTPServer + ' -l ' + @SFTPUser + ' -pw ' + @SFTPPWD + ' -b "' + @localPath + 'SFTPUploadScript.txt" > "' + @localPath + 'SFTPUploadScript.bat"'
    EXEC master..xp_cmdshell @CommandString, no_output

--Create SFTP upload script file
     SET @CommandString = 'echo cd "' + @SFTPPath + '" > "' + @localPath + 'SFTPUploadScript.txt"'
    EXEC master..xp_cmdshell @CommandString, no_output
     SET @CommandString = 'echo put "' + @localPath+@fileName + '" >> "' + @localPath + 'SFTPUploadScript.txt"'
    EXEC master..xp_cmdshell @CommandString, no_output

--Run the Batch File
     SET @CommandString = @localPath + 'SFTPUploadScript.bat'
    EXEC master..xp_cmdshell @CommandString, no_output

--Delete Existing files if they exist
     SET @CommandString = 'del "'+ @localPath + 'SFTPUploadScript.txt"'
    EXEC master..xp_cmdshell @CommandString, no_output
     SET @CommandString = 'del "'+ @localPath + 'SFTPUploadScript.bat"'
    EXEC master..xp_cmdshell @CommandString, no_output
