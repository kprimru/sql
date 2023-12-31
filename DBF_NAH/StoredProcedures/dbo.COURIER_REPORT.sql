USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[COURIER_REPORT]
	@courlist VARCHAR(MAX),
	@count SMALLINT
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

		DECLARE @cour TABLE (CR_ID SMALLINT)

		IF @courlist IS NOT NULL
			INSERT INTO @cour
				SELECT *
				FROM dbo.GET_TABLE_FROM_LIST(@courlist, ',')
		ELSE
			INSERT INTO @cour
				SELECT COUR_ID
				FROM dbo.CourierTable
				ORDER BY COUR_NAME

		DECLARE @courid INT

		SELECT @courid = MIN(CR_ID)
		FROM @cour

		DECLARE @to TABLE(TTO_ID INT)

		WHILE @courid IS NOT NULL
		BEGIN
			INSERT INTO @to (TTO_ID)
				SELECT TOP (@count) TO_ID
				FROM dbo.TOTable
				WHERE TO_ID_COUR = @courid
				ORDER BY NEWID()

			SELECT @courid = MIN(CR_ID)
			FROM @cour
			WHERE @courid < CR_ID
		END

		SELECT *
		FROM
		(
			SELECT
				TO_NUM, TO_NAME, TO_INN AS CL_INN,
				ISNULL(TP_DIR_FAM + ' ', '') + ISNULL(TP_DIR_NAME + ' ', '') + ISNULL(TP_DIR_OTCH, '') AS TP_DIR_NAME, TP_DIR_POS, TP_DIR_PHONE,
				ISNULL(TP_BUH_FAM + ' ', '') + ISNULL(TP_BUH_NAME + ' ', '') + ISNULL(TP_BUH_OTCH, '') AS TP_BUH_NAME, TP_BUH_POS, TP_BUH_PHONE,
				ISNULL(TP_RES_FAM + ' ', '') + ISNULL(TP_RES_NAME + ' ', '') + ISNULL(TP_RES_OTCH, '') AS TP_RES_NAME, TP_RES_POS, TP_RES_PHONE,
				--TP_RES_FAM, TP_RES_NAME, TP_RES_OTCH, TP_RES_POS, TP_RES_PHONE,
				ISNULL(TA_INDEX + ', ', '') + ISNULL(CT_PREFIX, '') + ISNULL(CT_NAME + ', ', '') +
				ISNULL(ST_PREFIX + ' ', '') + ISNULL(ST_NAME, '') + ISNULL(' ' + ST_SUFFIX, '') + ', ' + ISNULL(TA_HOME, '') AS TO_ADDRESS,
				COUR_NAME,
				(
					CASE
						WHEN
							EXISTS
								(
									SELECT *
									FROM	dbo.TODistrView		a INNER JOIN
											dbo.RegNodeTable	b	ON
																a.SYS_REG_NAME = b.RN_SYS_NAME AND
																a.DIS_NUM = b.RN_DISTR_NUM AND
																a.DIS_COMP_NUM = b.RN_COMP_NUM
									WHERE TD_ID_TO = TO_ID
								)
							AND
							NOT EXISTS
								(
									SELECT *
									FROM	dbo.TODistrView		a INNER JOIN
											dbo.RegNodeTable	b	ON
																a.SYS_REG_NAME = b.RN_SYS_NAME AND
																a.DIS_NUM = b.RN_DISTR_NUM AND
																a.DIS_COMP_NUM = b.RN_COMP_NUM
									WHERE TD_ID_TO = TO_ID AND RN_SERVICE = 0
								) THEN '���'
						ELSE ''
					END
				) AS CL_SERVICE,
				REVERSE(STUFF(REVERSE((
					SELECT DIS_STR + ', '
					FROM
						dbo.TODistrTable
						INNER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = TD_ID_DISTR
						INNER JOIN dbo.RegNodeTable ON RN_SYS_NAME = SYS_REG_NAME
													AND RN_DISTR_NUM = DIS_NUM
													AND RN_COMP_NUM = DIS_COMP_NUM
					WHERE TD_ID_TO = TO_ID AND RN_SERVICE = 0
					ORDER BY SYS_ORDER, DIS_NUM FOR XML PATH('')
				)), 1, 2, '')) AS CL_DISTR_LIST
			FROM
				@to INNER JOIN
				dbo.TOTable ON TO_Id = TTO_ID LEFT OUTER JOIN
				(
					SELECT TP_ID_TO AS TP_ID_DIR_TO, TP_SURNAME AS TP_DIR_FAM, TP_NAME AS TP_DIR_NAME, TP_OTCH AS TP_DIR_OTCH, POS_NAME AS TP_DIR_POS, TP_PHONE AS TP_DIR_PHONE
					FROM
						dbo.TOPersonalTable INNER JOIN
						dbo.ReportPositionTable ON RP_ID = TP_ID_RP LEFT OUTER JOIN
						dbo.PositionTable ON POS_ID = TP_ID_POS 
					WHERE RP_PSEDO = 'LEAD'
				) a ON TO_ID = a.TP_ID_DIR_TO LEFT OUTER JOIN
				(
					SELECT TP_ID_TO AS TP_ID_BUH_TO, TP_SURNAME AS TP_BUH_FAM, TP_NAME AS TP_BUH_NAME, TP_OTCH AS TP_BUH_OTCH, POS_NAME AS TP_BUH_POS, TP_PHONE AS TP_BUH_PHONE
					FROM
						dbo.TOPersonalTable INNER JOIN
						dbo.ReportPositionTable ON RP_ID = TP_ID_RP LEFT OUTER JOIN
						dbo.PositionTable ON POS_ID = TP_ID_POS 
					WHERE RP_PSEDO = 'BUH'
				) b ON TO_ID = b.TP_ID_BUH_TO LEFT OUTER JOIN
				(
					SELECT TP_ID_TO AS TP_ID_RES_TO, TP_SURNAME AS TP_RES_FAM, TP_NAME AS TP_RES_NAME, TP_OTCH AS TP_RES_OTCH, POS_NAME AS TP_RES_POS, TP_PHONE AS TP_RES_PHONE
					FROM
						dbo.TOPersonalTable INNER JOIN
						dbo.ReportPositionTable ON RP_ID = TP_ID_RP LEFT OUTER JOIN
						dbo.PositionTable ON POS_ID = TP_ID_POS 
					WHERE RP_PSEDO = 'RES'
				) c ON TO_ID = c.TP_ID_RES_TO LEFT OUTER JOIN
				dbo.CourierTable ON COUR_ID = TO_ID_COUR INNER JOIN
				@cour ON CR_ID = COUR_ID LEFT OUTER JOIN
				dbo.TOAddressTable ON TA_ID_TO = TO_ID LEFT OUTER JOIN
				dbo.StreetTable ON ST_ID = TA_ID_STREET LEFT OUTER JOIN
				dbo.CityTable ON CT_ID = ST_ID_CITY
			WHERE TO_REPORT = 1
		) AS o_O
		WHERE CL_SERVICE = '' AND IsNull(CL_DISTR_LIST, '') != ''
		ORDER BY COUR_NAME, TO_NAME, TO_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[COURIER_REPORT] TO rl_client_w;
GO
