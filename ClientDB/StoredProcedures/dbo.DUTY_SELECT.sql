USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DUTY_SELECT]
	@FILTER	VARCHAR(100) = NULL,
	@ACTIVE BIT = 1
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

		SELECT DutyID, DutyName, DutyLogin
		FROM dbo.DutyTable
		WHERE
			(@ACTIVE = 0 OR DutyActive = 1)
			AND
				(
					@FILTER IS NULL
					OR DutyName LIKE @FILTER
					OR DutyLogin LIKE @FILTER
				)
		ORDER BY DutyName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[DUTY_SELECT] TO rl_personal_duty_r;
GO