USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Cache].[SURNAME_CACHE_REFRESH]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Cache].[SURNAME_CACHE_REFRESH]  AS SELECT 1')
GO
ALTER PROCEDURE [Cache].[SURNAME_CACHE_REFRESH]
	@Surname	VarChar(250)	= NULL
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
		SET @Surname = LTrim(RTrim(@Surname));

		IF @Surname IS NOT NULL
		BEGIN
			IF NOT EXISTS
				(
					SELECT *
					FROM [Cache].[Persons=Surnames]
					WHERE [Surname] = @Surname
				)
				INSERT INTO [Cache].[Persons=Surnames]([Surname])
				VALUES (@Surname);
		END ELSE BEGIN
			TRUNCATE TABLE [Cache].[Persons=Surnames];

			INSERT INTO [Cache].[Persons=Surnames]([Surname])
			SELECT DISTINCT LTrim(RTrim(CP_SURNAME))
			FROM dbo.ClientTable a
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
			INNER JOIN dbo.ClientPersonal b ON a.ClientID = b.CP_ID_CLIENT
			WHERE a.STATUS = 1 AND CP_SURNAME <> '' AND CP_SURNAME <> '-'
		END;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
