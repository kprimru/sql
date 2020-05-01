USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Cache].[POSITION_CACHE_REFRESH]
	@Position	VarChar(250)	= NULL
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
		SET @Position = LTrim(RTrim(@Position));

		IF @Position IS NOT NULL
		BEGIN
			IF NOT EXISTS
				(
					SELECT *
					FROM [Cache].[Persons=Positions]
					WHERE [Position] = @Position
				)
				INSERT INTO [Cache].[Persons=Positions]([Position])
				VALUES (@Position);
		END ELSE BEGIN
			TRUNCATE TABLE [Cache].[Persons=Positions];

			INSERT INTO [Cache].[Persons=Positions]([Position])
			SELECT DISTINCT LTrim(RTrim(CP_POS))
			FROM dbo.ClientTable a
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
			INNER JOIN dbo.ClientPersonal b ON a.ClientID = b.CP_ID_CLIENT
			WHERE a.STATUS = 1 AND CP_POS <> '' AND CP_POS <> '-'
		END;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
