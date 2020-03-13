USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Cache].[PATRON_CACHE_REFRESH]
	@Patron	VarChar(250)	= NULL
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
		SET @Patron = LTrim(RTrim(@Patron));
	
		IF @Patron IS NOT NULL
		BEGIN
			IF NOT EXISTS
				(
					SELECT *
					FROM [Cache].[Persons=Patrons]
					WHERE [Patron] = @Patron
				)
				INSERT INTO [Cache].[Persons=Patrons]([Patron])
				VALUES (@Patron);
		END ELSE BEGIN
			TRUNCATE TABLE [Cache].[Persons=Patrons];
			
			INSERT INTO [Cache].[Persons=Patrons]([Patron])
			SELECT DISTINCT LTrim(RTrim(CP_PATRON))
			FROM dbo.ClientTable a
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
			INNER JOIN dbo.ClientPersonal b ON a.ClientID = b.CP_ID_CLIENT
			WHERE a.STATUS = 1 AND CP_PATRON <> '' AND CP_PATRON <> '-'	
		END;
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
