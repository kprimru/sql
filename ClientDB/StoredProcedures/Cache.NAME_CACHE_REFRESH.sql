USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Cache].[NAME_CACHE_REFRESH]
	@Name	VarChar(250)	= NULL
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
		SET @Name = LTrim(RTrim(@Name));

		IF @Name IS NOT NULL
		BEGIN
			IF NOT EXISTS
				(
					SELECT *
					FROM [Cache].[Persons=Names]
					WHERE [Name] = @Name
				)
				INSERT INTO [Cache].[Persons=Names]([Name])
				VALUES (@Name);
		END ELSE BEGIN
			TRUNCATE TABLE [Cache].[Persons=Names];

			INSERT INTO [Cache].[Persons=Names]([Name])
			SELECT DISTINCT LTrim(RTrim(CP_NAME))
			FROM dbo.ClientTable a
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
			INNER JOIN dbo.ClientPersonal b ON a.ClientID = b.CP_ID_CLIENT
			WHERE a.STATUS = 1 AND CP_NAME <> '' AND CP_NAME <> '-'
		END;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
