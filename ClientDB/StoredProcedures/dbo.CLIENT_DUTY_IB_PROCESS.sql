USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DUTY_IB_PROCESS]
	@ClientDutyID INT,
	@IB VARCHAR(MAX)
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

		DECLARE @table TABLE (SysID INT)

		INSERT INTO @table
			SELECT *
			FROM dbo.GET_TABLE_FROM_LIST(@IB, ',')

		DELETE
		FROM dbo.ClientDutyIBTable
		WHERE ClientDutyID = @ClientDutyID
			AND NOT EXISTS
				(
					SELECT *
					FROM @table
					WHERE SysID = SystemID
				)

		INSERT INTO dbo.ClientDutyIBTable(ClientDutyID, SystemID)
			SELECT @ClientDutyID, SysID
			FROM @table
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.ClientDutyIBTable
					WHERE SysID = SystemID
						AND ClientDutyID = @ClientDutyID
				)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_IB_PROCESS] TO rl_client_duty_i;
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_IB_PROCESS] TO rl_client_duty_u;
GO
