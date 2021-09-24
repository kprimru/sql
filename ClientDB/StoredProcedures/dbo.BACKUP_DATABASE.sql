USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[BACKUP_DATABASE]
	@PATH NVARCHAR(500)
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

		SET @PATH = @PATH + 'ClientDB' + CONVERT(VARCHAR(50), GETDATE(), 112) + '.bak'

		SET @SQL = 'BACKUP DATABASE  [' + DB_NAME() + '] TO  DISK = ''' + @PATH + N'''
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
GO
GRANT EXECUTE ON [dbo].[BACKUP_DATABASE] TO DBChief;
GRANT EXECUTE ON [dbo].[BACKUP_DATABASE] TO DBTech;
GO
