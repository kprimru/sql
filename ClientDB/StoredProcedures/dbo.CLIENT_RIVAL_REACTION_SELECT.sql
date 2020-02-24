USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_RIVAL_REACTION_SELECT]
	@ID	INT
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
			CRR_ID, CRR_ID_MASTER, CRR_DATE, CRR_COMMENT,
			CRR_COMPARE, CRR_CLAIM, CRR_REJECT, CRR_PARTNER,
			CRR_CREATE_USER + ' ' +
				CONVERT(VARCHAR(20), CRR_CREATE_DATE, 104) + ' ' + 
				CONVERT(VARCHAR(20), CRR_CREATE_DATE, 108) AS CRR_CREATE,
			CRR_UPDATE_USER + ' ' +
				CONVERT(VARCHAR(20), CRR_UPDATE_DATE, 104) + ' ' + 
				CONVERT(VARCHAR(20), CRR_UPDATE_DATE, 108) AS CRR_UPDATE
		FROM dbo.ClientRivalReaction
		WHERE CRR_ID_RIVAL = @ID AND CRR_ACTIVE = 1
		ORDER BY CRR_DATE DESC
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END