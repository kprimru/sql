USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_WEIGHT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_WEIGHT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SYSTEM_WEIGHT_SELECT]
	@SYSTEM	INT,
	@PERIOD	UNIQUEIDENTIFIER
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

		SELECT SystemShortName, NAME, WEIGHT, WEIGHT2, b.ID, c.SystemID
		FROM
			dbo.SystemWeight a
			INNER JOIN Common.Period b ON a.ID_PERIOD = b.ID
			INNER JOIN dbo.SystemTable c ON a.ID_SYSTEM = c.SystemID
		WHERE (SystemID = @SYSTEM OR @SYSTEM IS NULL)
			AND (ID_PERIOD = @PERIOD OR @PERIOD IS NULL)
			AND START <= DATEADD(MONTH, 3, GETDATE())
		ORDER BY START DESC, SystemOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_WEIGHT_SELECT] TO rl_system_u;
GO
