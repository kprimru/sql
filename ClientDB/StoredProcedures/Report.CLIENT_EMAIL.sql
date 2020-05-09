USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[CLIENT_EMAIL]
	@PARAM	NVARCHAR(MAX) = NULL
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
			rnccv.ClientName AS [Название клиента], rnccv.ManagerName [Руководитель], rnccv.ServiceName AS [СИ],
			rnccv.NT_SHORT AS [Сеть], rnccv.DistrStr AS [Дистрибутив], SST_SHORT AS [Тип системы], rnccv.Complect AS [Комплект], ct.ClientEmail AS [E-Mail],
			CASE
				WHEN ct.ClientEmail = '' OR ct.ClientEmail IS NULL THEN
					CONVERT(BIT, 0)
				WHEN ct.ClientEmail <> '' AND ct.ClientEmail IS NOT NULL THEN
					CONVERT(BIT, 1)
			END AS [Наличие E-Mail]
		FROM
			dbo.RegNodeComplectClientView rnccv
			INNER JOIN dbo.ClientTable ct ON ct.ClientID = rnccv.ClientID
		WHERE DS_REG = 0
		ORDER BY ClientName, Complect, DistrStr, NT_SHORT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[CLIENT_EMAIL] TO rl_report;
GO