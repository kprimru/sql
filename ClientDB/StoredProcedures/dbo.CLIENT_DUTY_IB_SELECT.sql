USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DUTY_IB_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DUTY_IB_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_DUTY_IB_SELECT]
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
			SystemID, SystemShortName,
			CASE
				WHEN Checked > 0 THEN CONVERT(BIT, 1)
				ELSE CONVERT(BIT, 0)
			END AS Checked
		FROM
			(
				SELECT
					SystemID, SystemShortName, SystemOrder,
					(
						SELECT COUNT(*)
						FROM dbo.ClientDutyIBTable b
						WHERE b.ClientDutyID = @ID
							AND a.SystemID = b.SystemID
					) AS Checked
				FROM dbo.SystemTable a
			) AS o_O
		ORDER BY SystemOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_IB_SELECT] TO rl_client_duty_r;
GO
