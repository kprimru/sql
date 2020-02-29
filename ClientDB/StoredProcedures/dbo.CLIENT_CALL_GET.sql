USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CALL_GET]
	@ID	UNIQUEIDENTIFIER
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

		SELECT 
			CC_ID_CLIENT, CC_DATE, CC_PERSONAL, CC_SERVICE, CC_NOTE, 
			(
				SELECT CT_ID 
				FROM dbo.ClientTrust 
				WHERE CT_ID_CALL = CC_ID
			) AS CT_ID, 
			(
				SELECT CS_ID 
				FROM dbo.ClientSatisfaction
				WHERE CS_ID_CALL = CC_ID
			) AS CS_ID
		FROM dbo.ClientCall
		WHERE CC_ID = @ID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END