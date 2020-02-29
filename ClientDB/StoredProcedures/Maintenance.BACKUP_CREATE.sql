USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[BACKUP_CREATE]
	@PATH	NVARCHAR(512)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @SQL NVARCHAR(MAX)

		SET @PATH = @PATH + N'ClientDB' + CONVERT(NVARCHAR(100), GETDATE(), 112) + N'.bak'

		SET @SQL = N'BACKUP DATABASE  [' + DB_NAME() + N'] TO  DISK = ''' + @PATH + N'''
				WITH  
					INIT ,  
					NOUNLOAD ,  
					NAME = ''ClientDB FULL BACKUP'',
					SKIP ,  
					STATS = 10,  
					NOFORMAT 
			'

		EXEC (@SQL)
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END