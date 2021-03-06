create procedure [dbo].[sp_sendToFTP] @kode varchar(500), @versi varchar(3), @periodeData varchar(10)
as
declare @dbName					varchar(50)		= 'LPS'
declare @schemaName				varchar(50)		
declare @tableName				varchar(500)	
declare @columnName				varchar(8000)
declare	@delimiter				varchar(1)		= '|'
declare	@flagHeader				varchar(1)			
declare @kodeLaporan			varchar(3)	
declare @nomorKepesertaan		varchar(10)		
declare @sandiLJK				char(3)			
declare @posisiLaporan			varchar(8)		= convert(varchar,convert(date,@periodeData),112) 
declare @periodeLaporan			char(1)			
declare @versiLaporan			varchar(3)		= @versi

select 
@schemaName		  = schemaName,
@tableName		  = tableName,
@flagHeader		  = header,
@kodeLaporan	  = kodeLaporan,
@nomorKepesertaan = kodeKepesertaan,
@sandiLJK		  = sandiLJK,
@periodeLaporan	  = periodeLaporan
from fileFormat
where kodeLaporan = @kode

declare @maxPeriodeData table(
	periodeData date
)

insert into @maxPeriodeData
exec('select max(periodeData) from '+@tableName)

select @tableName = case when periodeData = @periodeData then @tableName else @tableName+'History' end
from  @maxPeriodeData

declare @jumlahRecord			bigint
declare @extension				varchar(5)		= 'txt'
declare @localPath				varchar(100)	= 'D:\LPS\'+@posisiLaporan+'\'
declare @fileName				varchar(1000)	= @kodeLaporan+'_'+@nomorKepesertaan+'_'+@sandiLJK+'_'+@posisiLaporan+'_'+@periodeLaporan+'_'+@versiLaporan+'.'+@extension
declare @query					varchar(8000) 
declare @bcp					varchar(8000)
declare @mkdir					varchar(100)
declare @FTPPath				varchar(250)	= 'PSSD/LPS/' + @posisiLaporan + '/'
declare @workfilename			varchar(250)    = 'FTPCMD_' + @fileName
declare @cmd					varchar(1000)
declare @FTPServer				varchar(250)    = '10.11.88.15'
declare @FTPUser				varchar(250)    = 'transit'
declare @FTPPWD					varchar(250)    = 'tr4ns1t!'


select 
@columnName = (select left(convert(varchar(max),(select 'isnull(convert(varchar(max),ltrim(rtrim('+COLUMN_NAME+'))),'''')+'''+@delimiter+'''+' from INFORMATION_SCHEMA.COLUMNS
			  where TABLE_NAME = @tableName and COLUMN_NAME not in ('id','status','nomorCIF','periodeData','kodeUrutan','deskripsi')
			  for xml path(''))),
			  len(convert(varchar(max),(select 'isnull(convert(varchar(max),ltrim(rtrim('+COLUMN_NAME+'))),'''')+'''+@delimiter+'''+' from INFORMATION_SCHEMA.COLUMNS
			  where TABLE_NAME = @tableName and COLUMN_NAME not in ('id','status','nomorCIF','periodeData','kodeUrutan','deskripsi')
			  for xml path(''))))-5))

set @query = 'select '''+@flagHeader+@delimiter+@kodeLaporan+@delimiter+@nomorKepesertaan+@delimiter+@sandiLJK+@delimiter+@posisiLaporan+@delimiter+@periodeLaporan+@delimiter+@versiLaporan+@delimiter+'''+(select convert(varchar,count(0)) from '+@dbName+'.'+@schemaName+'.'+@tableName+
			 ' where periodeData = '''+@periodeData+''') union all select ''D|''+'+@columnName+' from '+@dbName+'.'+@schemaName+'.'+@tableName+' where periodeData = '''+@periodeData+''''
set @bcp = 'bcp "'+@query+'" queryout '+@localPath+@fileName+' -c -t, -T'
set @mkdir = 'mkdir "'+@localPath+'"'

exec master.dbo.xp_cmdshell @mkdir, no_output
exec master.dbo.xp_cmdshell @bcp, no_output

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
