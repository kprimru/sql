USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STUDY_GET]
	@ID		UNIQUEIDENTIFIER,
	@CLAIM	UNIQUEIDENTIFIER
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
			DATE, ID_PLACE, ID_TEACHER, NEED, RECOMEND, NOTE, TEACHED, ID_TYPE, RIVAL,
			('<LIST>' + 
				(
					SELECT CONVERT(VARCHAR(50), ID_SYSTEM)AS ITEM
					FROM dbo.ClientStudySystem b 
					WHERE a.ID = b.ID_STUDY
					FOR XML PATH('')
				) 
			+ '</LIST>') AS SYSTEM_LIST
		FROM dbo.ClientStudy a
		WHERE ID = @ID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
