USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TO_MASTER_PRINT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[TO_MASTER_PRINT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[TO_MASTER_PRINT]
	@TO_ID	INT
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
				a.TO_NAME
			,	'''' + TO_INN AS CL_INN
			,	(CT_PREFIX + ' ' + CT_NAME + ', ' + ISNULL(ST_PREFIX + ' ', '') + ST_NAME + ISNULL(' ' + ST_SUFFIX, '') + ', ' + TA_HOME) AS TO_ADDRESS
			,
				(
					SELECT TOP 1
						CO_NUM + ' от ' + CONVERT(VARCHAR(20), CO_DATE, 104) +
						' с ' + CONVERT(VARCHAR(20), CO_BEG_DATE, 104) + ISNULL(' по ' + CONVERT(VARCHAR(20), CO_END_DATE, 104), '') +
						'. Тип оплаты: ' + ISNULL(COP_NAME, '')
					FROM
						dbo.ContractTable LEFT OUTER JOIN
						dbo.ContractPayTable ON COP_ID = CO_ID_PAY
					WHERE CO_ID_CLIENT = CL_ID
					ORDER BY CO_ACTIVE DESC, CO_DATE DESC
				) AS CO_NUM
			,	COUR_NAME
			,	(dir.TP_SURNAME + ' ' + dir.TP_NAME + ' ' + dir.TP_OTCH) AS DIR_NAME
			,	dir.POS_NAME AS DIR_POS
			,	dir.TP_PHONE AS DIR_PHONE
			,	(buh.TP_SURNAME + ' ' + buh.TP_NAME + ' ' + buh.TP_OTCH) AS BUH_NAME
			,	buh.POS_NAME AS BUH_POS
			,	buh.TP_PHONE AS BUH_PHONE
			,	(res.TP_SURNAME + ' ' + res.TP_NAME + ' ' + res.TP_OTCH) AS RES_NAME
			,	res.POS_NAME AS RES_POS
			,	res.TP_PHONE AS RES_PHONE
		FROM
			dbo.TOTable a INNER JOIN
			dbo.ClientTable b ON a.TO_ID_CLIENT = b.CL_ID LEFT OUTER JOIN
			dbo.TOAddressTable c ON c.TA_ID_TO = a.TO_ID LEFT OUTER JOIN
			dbo.StreetTable d ON d.ST_ID = c.TA_ID_STREET LEFT OUTER JOIN
			dbo.CityTable e ON e.CT_ID = d.ST_ID_CITY LEFT OUTER JOIN
			dbo.CourierTable f ON f.COUR_ID = a.TO_ID_COUR LEFT OUTER JOIN
			dbo.TOPersonalView dir ON a.TO_ID = dir.TP_ID_TO AND dir.RP_PSEDO = 'LEAD' LEFT OUTER JOIN
			dbo.TOPersonalView buh ON a.TO_ID = buh.TP_ID_TO AND buh.RP_PSEDO = 'BUH' LEFT OUTER JOIN
			dbo.TOPersonalView res ON a.TO_ID = res.TP_ID_TO AND res.RP_PSEDO = 'RES'
		WHERE TO_ID = @TO_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[TO_MASTER_PRINT] TO rl_to_w;
GO
