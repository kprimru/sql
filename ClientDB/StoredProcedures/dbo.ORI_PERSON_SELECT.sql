USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ORI_PERSON_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ORI_PERSON_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ORI_PERSON_SELECT]
	@CLIENT	INT
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

		SELECT OriPersonID, OriPersonName, OriPersonPhone, OriPersonPlace
		FROM dbo.OriPersonTable
		WHERE ClientID = @CLIENT
		ORDER BY OriPersonName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ORI_PERSON_SELECT] TO rl_ori_person_r;
GO
