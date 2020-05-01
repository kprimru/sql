USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_REPORT]
	@ctlist VARCHAR(MAX)
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

		DECLARE @city TABLE
			(
				CCT_ID SMALLINT
			)

		INSERT INTO @city
			SELECT *
			FROM dbo.GET_TABLE_FROM_LIST(@ctlist, ',')

		SELECT
			TO_NAME, COUR_NAME,
			ISNULL(TA_INDEX, '') + ISNULL(CT_PREFIX, '') + ISNULL(CT_NAME, '') + ',' +
			ISNULL(ST_PREFIX + ' ', '') + ISNULL(ST_NAME, '') + ISNULL(' ' + ST_SUFFIX, '') + ',' + TA_HOME,
			(
				SELECT DISTINCT TP_PHONE + ', '
				FROM dbo.TOPersonalTable
				WHERE TP_ID_TO = TO_ID
				FOR XML PATH('')
			) AS TP_PHONE,
			(
				SELECT DIS_STR + '(' + DIS_SERVICE + '), '
				FROM
					dbo.TODistrTable LEFT OUTER JOIN
					dbo.DistrServiceView ON DIS_ID = TD_ID_DISTR
				WHERE TD_ID_TO = TO_ID
				ORDER BY DIS_SERVICE, SYS_ORDER
				FOR XML PATH('')
			) AS DIS_STR
		FROM
			dbo.TOTable INNER JOIN
			dbo.TOAddressTable ON TA_ID_TO = TO_ID INNER JOIN
			dbo.StreetTable ON ST_ID = TA_ID_STREET INNER JOIN
			dbo.CityTable ON CT_ID = ST_ID_CITY INNER JOIN
			@city ON CCT_ID = CT_ID LEFT OUTER JOIN
			dbo.CourierTable ON COUR_ID = TO_ID_COUR
		ORDER BY COUR_NAME, TO_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_REPORT] TO rl_client_r;
GO