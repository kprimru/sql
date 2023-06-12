USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_RIVAL_PERSONAL_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_RIVAL_PERSONAL_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_RIVAL_PERSONAL_GET]
	@CR_ID	INT
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
			PositionTypeID, PositionTypeName,
			CONVERT(BIT,
				ISNULL(
					(
						SELECT COUNT(*)
						FROM dbo.ClientRivalPersonal
						WHERE CRP_ID_PERSONAL = PositionTypeID
							AND CRP_ID_RIVAL = @CR_ID
					), 0)
			) AS PositionTypeChecked
		FROM
			dbo.PositionTypeTable
		ORDER BY PositionTypeName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_RIVAL_PERSONAL_GET] TO rl_client_rival_r;
GO
