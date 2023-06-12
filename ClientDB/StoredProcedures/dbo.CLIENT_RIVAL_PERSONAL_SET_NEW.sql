USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_RIVAL_PERSONAL_SET_NEW]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_RIVAL_PERSONAL_SET_NEW]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_RIVAL_PERSONAL_SET_NEW]
	@CR_ID	INT,
	@LIST	VARCHAR(MAX)
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

		DECLARE @table TABLE (PT_ID INT)

		INSERT INTO @table
			SELECT *
			FROM dbo.GET_TABLE_FROM_LIST(@LIST, ',')

		DELETE
		FROM dbo.ClientRivalPersonal
		WHERE CRP_ID_RIVAL = @CR_ID
			AND NOT EXISTS
				(
					SELECT *
					FROM @table
					WHERE PT_ID = CRP_ID_PERSONAL
				)

		INSERT INTO dbo.ClientRivalPersonal(CRP_ID_RIVAL, CRP_ID_PERSONAL)
			SELECT DISTINCT @CR_ID, PT_ID
			FROM @table

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
