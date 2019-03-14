USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	/*
�����:			
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[REG_NODE_REFRESH]	
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @tempregpath VARCHAR(MAX)
	DECLARE @regkeys VARCHAR(MAX)
	DECLARE @regnodepath VARCHAR(MAX)

	SELECT @tempregpath = dbo.GET_SETTING('TEMP_REG_PATH')
	SELECT @regkeys = dbo.GET_SETTING('REG_KEYS')
	SELECT @regnodepath = dbo.GET_SETTING('REG_NODE_PATH')
  
	DECLARE @filename VARCHAR(50)	
	SET @filename = @tempregpath + 'reg' + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(50), GETDATE(), 121), ':', ''), '-', ''), ' ', ''), '.', '') + '.csv'
  
	DECLARE @process VARCHAR(MAX)
	SET @process = @regnodepath + ' ' + @regkeys + @filename

	SELECT @process

	EXEC('EXEC xp_cmdshell ''' + @process + ''', NO_OUTPUT')

	EXEC REG_NODE_LOAD_LOCAL @filename
END
