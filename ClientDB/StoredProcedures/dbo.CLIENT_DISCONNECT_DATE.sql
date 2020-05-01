USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DISCONNECT_DATE]
	@ID		NVARCHAR(MAX),
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

		DECLARE @CLIENT	INT

		SELECT @CLIENT = ID
		FROM dbo.TableIDFromXML(@ID)

		SELECT @DATE = dbo.DateOf(MAX(DT))
		FROM
			(
				SELECT RPR_DATE AS DT
				FROM
					dbo.RegProtocol
					INNER JOIN dbo.ClientDistrView WITH(NOEXPAND) ON RPR_ID_HOST = HostID
																AND RPR_DISTR = DISTR
																AND RPR_COMP = COMP
				WHERE  ID_CLIENT = @CLIENT AND RPR_OPER IN ('Отключение', 'Сопровождение отключено')

				UNION ALL

				SELECT DATE
				FROM
					Reg.ProtocolText a
					INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.ID_HOST = b.HostID
																AND a.DISTR = b.DISTR
																AND a.COMP = b.COMP
				WHERE ID_CLIENT = @CLIENT
					AND COMMENT = 'Отключение'
			) AS o_O

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_DISCONNECT_DATE] TO rl_client_disconnect;
GO