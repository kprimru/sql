USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DISTR_CONNECT_DATE]
	@ID		UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME = NULL OUTPUT
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

		DECLARE @HOST	INT
		DECLARE @DISTR	INT
		DECLARE @COMP	TINYINT

		SELECT @HOST = HostID, @DISTR = DISTR, @COMP = COMP
		FROM dbo.ClientDistrView WITH(NOEXPAND)
		WHERE ID = @ID

		SELECT @DATE = dbo.DateOf(MAX(DT))
		FROM
			(
				SELECT RPR_DATE AS DT
				FROM dbo.RegProtocol
				WHERE RPR_ID_HOST = @HOST AND RPR_DISTR = @DISTR AND RPR_COMP = @COMP
					AND RPR_OPER IN ('НОВАЯ', 'Включение')

				UNION ALL

				SELECT DATE
				FROM Reg.ProtocolText
				WHERE ID_HOST = @HOST AND DISTR = @DISTR AND COMP = @COMP
					AND (COMMENT LIKE '%новая%' OR COMMENT LIKE '%включение%')
			) AS o_O

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_CONNECT_DATE] TO rl_client_distr_connect;
GO