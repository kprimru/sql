USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[XML_BULK_LOAD]
	@File		SYSNAME,
	@Schema		SYSNAME,
	@DataBase	SYSNAME
WITH EXECUTE AS OWNER
AS
BEGIN 
	SET NOCOUNT ON

	-- EXEC dbo.spXMLBulkLoad 'Z:\Path\Data.xml','Z:\Path\Schema.xsd'
	-- EXEC sp_configure 'Ole Automation Procedures', 1; RECONFIGURE WITH OVERRIDE;	

	DECLARE @ErrCode		INT
	DECLARE @OLEXMLBulk		INT
	DECLARE @ErrMethod		SYSNAME
	DECLARE @ErrSource		SYSNAME
	DECLARE @ErrDescript	NVARCHAR(4000)	

	SET @ErrSource = 'D:\TEMP\XMLBulkError.xml'	--  файл ошибки (OPENROWSET требует константу)

	EXEC @ErrCode = sys.sp_OACreate 'SQLXMLBulkLoad.SQLXMLBulkload' ,@OLEXMLBulk OUT

	IF (@ErrCode = 0) 
	BEGIN
		SET	@DataBase = 'Provider=SQLOLEDB;Data Source=PC264-SQL\ALPHA;DataBase=' + @DataBase + ';Integrated Security=SSPI'
		
		EXEC @ErrCode = sys.sp_OASetProperty	@OLEXMLBulk, 'ConnectionString', @DataBase
		IF (@ErrCode != 0) 
		BEGIN 
			SET @ErrMethod = 'ConnectionString'	
			GOTO Error 
		END

		EXEC @ErrCode = sys.sp_OASetProperty	@OLEXMLBulk, 'ErrorLogFile', @ErrSource		
		IF (@ErrCode != 0) 
		BEGIN 
			SET @ErrMethod = 'ErrorLogFile'	
			GOTO Error 
		END

		EXEC @ErrCode = sys.sp_OASetProperty	@OLEXMLBulk ,'CheckConstraints', 1
		IF (@ErrCode != 0) 
		BEGIN 
			SET @ErrMethod = 'CheckConstraints'	
			GOTO Error 
		END

		EXEC @ErrCode = sys.sp_OAMethod		@OLEXMLBulk, 'Execute', NULL, @Schema, @File
		IF (@ErrCode != 0) 
		BEGIN
			SET @ErrMethod = 'Execute'
			DECLARE @Exist INT
			DECLARE @Error XML
			EXEC	master.dbo.xp_FileExist	@ErrSource, @Exist OUT

			IF (@Exist = 1) 
			BEGIN
				SELECT @Error = E.Error
							-- Обход глюка
						+	CASE	
								WHEN RIGHT(E.Error, 1) != '>' THEN 'lt>'
								ELSE ''
							END
				FROM	
					OPENROWSET(BULK 'D:\TEMP\XMLBulkError.xml', SINGLE_NCLOB) E(Error) -- Из @ErrSource файла

				SELECT	@ErrDescript = ISNULL(@ErrDescript,'') + E.Error.value('Description[1]', 'SysName') + ' '
				FROM	@Error.nodes('/Result/Error')E(Error)

				SELECT	@ErrDescript = ISNULL(@ErrDescript,'') + E.Error.value('Description[1]', 'SysName') + ' '
				FROM	@Error.nodes('/Error/Record')E(Error)
			END 
			ELSE
				GOTO Error
		END

		GOTO Destroy

		Error:	
			EXEC @ErrCode = sys.sp_OAGetErrorInfo	@OLEXMLBulk, @ErrSource OUT, @ErrDescript OUT

		Destroy:
			EXEC @ErrCode = sys.sp_OADestroy	@OLEXMLBulk
	END 
	ELSE
		SELECT	 
			@ErrMethod		= 'SQLXMLBulkLoad.SQLXMLBulkload',
			@ErrSource		= 'sp_OACreate',
			@ErrDescript	= 'Ошибка создания OLE объекта'
		-- Вывод ошибок

	IF (@ErrMethod IS NOT NULL) 
	BEGIN
		RAISERROR('Ошибка при выполнении метода "%s" в "%s": %s',18,1,@ErrMethod,@ErrSource,@ErrDescript)
		RETURN	@@Error
	END
END