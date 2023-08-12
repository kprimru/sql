USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SERVICE_GRAPH_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SERVICE_GRAPH_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SERVICE_GRAPH_SELECT]
	@SERVICE	INT
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

		DECLARE @DT DATETIME

		SET DATEFIRST 1
		SET @DT = dbo.DateOf(DATEADD(dd, - datepart(dw, GETDATE()) + 1, GETDATE()))

		SELECT
			ClientID, ClientFullName, DayOrder, ClientFullName AS ClientShortName,
			dbo.DateAssign(DATEADD(DAY, DayOrder - 1, @DT), ServiceStart) AS START,
			DATEADD(MINUTE, ServiceTime, dbo.DateAssign(DATEADD(DAY, DayOrder - 1, @DT), ServiceStart)) AS FINISH,
			ServiceTime, CA_STR,
			CASE
				WHEN GR_ERROR IS NULL THEN 0
				ELSE 1
			END AS ERR
		FROM
			dbo.ServiceGraphView
			LEFT OUTER JOIN dbo.ClientAddressView ON CA_ID_CLIENT = ClientID
		WHERE ClientServiceID = @SERVICE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_GRAPH_SELECT] TO rl_service_graph_r;
GO
