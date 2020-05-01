USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Tender].[TENDER_FILTER]
	@CLIENT		NVARCHAR(128),
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@STATUS		UNIQUEIDENTIFIER,
	@LAW		UNIQUEIDENTIFIER,
	@MANAGER	INT
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
			ROW_NUMBER() OVER(ORDER BY ClientID, INFO_DATE DESC) AS RN,
			a.ID, a.ID_CLIENT AS ClientID, CLIENT, b.NAME AS LAW_NAME, c.NAME AS STAT_NAME,
			ISNULL('с ' + CONVERT(NVARCHAR(32), CONTRACT_START, 104) + ' ', '') + ISNULL('по ' + CONVERT(NVARCHAR(32), CONTRACT_FINISH, 104), '') AS CONTRACT_DATA,
			ISNULL('с ' + CONVERT(NVARCHAR(32), ACT_START, 104) + ' ', '') + ISNULL('по ' + CONVERT(NVARCHAR(32), ACT_FINISH, 104), '') AS ACT_DATA,
			ISNULL('с ' + CONVERT(NVARCHAR(32), TENDER_START, 104) + ' ', '') + ISNULL('по ' + CONVERT(NVARCHAR(32), TENDER_FINISH, 104), '') AS TENDER_DATA,
			INFO_DATE, CALL_DATE,
			SURNAME + ' ' + a.NAME + ' ' + PATRON + ' ' + PHONE + ' ' + EMAIL AS FIO,
			ManagerName
		FROM
			Tender.Tender a
			INNER JOIN Tender.Law b ON a.ID_LAW = b.ID
			INNER JOIN Tender.Status c ON a.ID_STATUS = c.ID
			INNER JOIN dbo.ClientView d WITH(NOEXPAND) ON a.ID_CLIENT = d.ClientID
		WHERE a.STATUS = 1
			AND (CLIENT LIKE @CLIENT OR @CLIENT IS NULL)
			AND (a.ID_LAW = @LAW OR @LAW IS NULL)
			AND (a.ID_STATUS = @STATUS OR @STATUS IS NULL)
			AND (INFO_DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (INFO_DATE <= @END OR @END IS NULL)
			AND (d.ManagerID = @MANAGER OR @MANAGER IS NULL)
		ORDER BY ClientID, INFO_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Tender].[TENDER_FILTER] TO rl_tender_r;
GRANT EXECUTE ON [Tender].[TENDER_FILTER] TO rl_tender_u;
GO