USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================
--	Автор:			Денисов Алексей
--	Дата создания:	25.08.2008
--	Дата изменения:	10.02.2009
--	Описание:		Создает таблицу с данными отчета.
--					Поля таблицы будут при финальном
--					редактировании отделяться запятыми
--	Что нового:		Теперь результат вывода заносится
--					в предварительно очищенную
--					таблицу dbo.VMIReportTable
-- ====================================================

ALTER PROCEDURE [dbo].[RIC_REPORT_CREATE_NEW]
	@PR_ID	SMALLINT
WITH RECOMPILE
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

		DECLARE @PR_DATE SMALLDATETIME

		SELECT @PR_DATE = PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_ID

		DELETE FROM dbo.VMIReportTable

		INSERT INTO dbo.VMIReportTable
			SELECT
				dbo.GET_SETTING('RIC_NUM') AS RIC_NUM,
				TO_NUM, TO_NAME, ISNULL(TO_INN ,'') AS CL_INN,
				CT_REGION AS CL_REGION,
				CT_NAME AS CL_CITY,

				CASE
					WHEN ISNULL(ST_PREFIX, '') = '' THEN ''
					ELSE ST_PREFIX + ' '
				END + ST_NAME +
				CASE
					WHEN ISNULL(ST_SUFFIX, '') = '' THEN ''
					ELSE ' ' + ST_SUFFIX
				END	+ ',' + TA_HOME AS CL_ADDRESS,
				ISNULL(CL_DIR_NAME, ''), ISNULL(CL_DIR_POS, ''), ISNULL(CL_DIR_PHONE, ''),
				ISNULL(CL_BUH_NAME, ''), ISNULL(CL_BUH_POS, ''), ISNULL(CL_BUH_PHONE, ''),
				ISNULL(CL_RES_NAME, ''), ISNULL(CL_RES_POS, ''), ISNULL(CL_RES_PHONE, ''),
				ISNULL(CL_PER4_NAME, ''), ISNULL(CL_PER4_POS, ''), ISNULL(CL_PER4_PHONE, ''),
				ISNULL(CL_PER5_NAME, ''), ISNULL(CL_PER5_POS, ''), ISNULL(CL_PER5_PHONE, ''),
				(
					CASE
						WHEN 
							NOT EXISTS
								(
									SELECT *
									FROM	dbo.TODistrView		a INNER JOIN
											dbo.PeriodRegTable	b	ON
																a.SYS_ID = b.REG_ID_SYSTEM AND
																a.DIS_NUM = b.REG_DISTR_NUM AND
																a.DIS_COMP_NUM = b.REG_COMP_NUM INNER JOIN
											dbo.DistrStatusTable c ON DS_ID = REG_ID_STATUS
									WHERE TO_ID = TD_ID_TO AND DS_REG = 0 AND REG_ID_PERIOD = @PR_ID
								) THEN 'Нет'
						ELSE ''
					END
				) AS CL_SERVICE,
				ISNULL(REVERSE(STUFF(REVERSE((
					SELECT HST_REG_NAME +
							(CASE DIS_COMP_NUM
									WHEN 1 THEN CONVERT(varchar, DIS_NUM)
									ELSE CONVERT(varchar, DIS_NUM) + '/' + CONVERT(varchar, DIS_COMP_NUM)
							END
							) +
							CASE ISNULL(SYS_IB, '')
								WHEN '' THEN ''
								ELSE '/' + SYS_IB
							END + ','
					FROM
						(
							SELECT DISTINCT	HST_REG_NAME, DIS_COMP_NUM, DIS_NUM, SYS_IB
							FROM
								dbo.TODistrView		a		INNER JOIN
								dbo.PeriodRegTable	b	ON	a.DIS_NUM =	b.REG_DISTR_NUM AND
															a.DIS_COMP_NUM = b.REG_COMP_NUM AND
															a.SYS_ID = b.REG_ID_SYSTEM
							WHERE TD_ID_TO = TO_ID AND REG_ID_PERIOD = @PR_ID
								AND (SYS_REPORT = 1 OR REG_MAIN = 1)

							UNION

							SELECT DISTINCT	HST_REG_NAME, DIS_COMP_NUM, DIS_NUM, SYS_IB
							FROM	dbo.TODistrView		a
									INNER JOIN 	dbo.PeriodRegTable	b	ON	a.DIS_NUM =	b.REG_DISTR_NUM AND
																	a.DIS_COMP_NUM = b.REG_COMP_NUM AND
																	a.SYS_ID = b.REG_ID_SYSTEM
									--INNER JOIN dbo.PeriodTable c ON c.PR_ID = b.REG_ID_PERIOD
									INNER JOIN dbo.DistrStatusTable d ON d.DS_ID = b.REG_ID_STATUS
							WHERE TD_ID_TO = TO_ID   AND REG_MAIN = 1 AND d.DS_REG IN (0, 1) AND REG_ID_PERIOD = @PR_ID
								--AND PR_DATE >= '20120101'
								--AND PR_DATE <= @PR_DATE

							UNION

							SELECT DISTINCT HST_REG_NAME, DIS_COMP_NUM, DIS_NUM, SYS_IB
							FROM dbo.TODistrView
							WHERE TD_ID_TO = TO_ID AND TD_FORCED = 1
						) AS o_O
					ORDER BY HST_REG_NAME, DIS_NUM, DIS_COMP_NUM FOR XML PATH('')
				)),1,1,'')), '') AS CL_SYSTEM,
				TO_VMI_COMMENT AS CL_COMMENT
		FROM
				dbo.TOTable				LEFT OUTER JOIN
				dbo.TOAddressTable		ON TO_ID = TA_ID_TO		LEFT OUTER JOIN
				dbo.ClientTable			ON TO_ID_CLIENT=CL_ID	LEFT OUTER JOIN 
				dbo.StreetTable			ON ST_ID = TA_ID_STREET	LEFT OUTER JOIN
				dbo.CityTable			ON CT_ID = ST_ID_CITY	LEFT OUTER JOIN
				(
					SELECT
						TP_ID_TO,
						(TP_SURNAME + ' ' + TP_NAME + ' ' + TP_OTCH) AS CL_DIR_NAME,
						POS_NAME AS CL_DIR_POS,
						TP_PHONE AS CL_DIR_PHONE
					FROM dbo.TOPersonalView
					WHERE RP_PSEDO = 'LEAD'
				) AS DIR ON DIR.TP_ID_TO = TO_ID LEFT OUTER JOIN
				(
					SELECT
						TP_ID_TO,
						(TP_SURNAME + ' ' + TP_NAME + ' ' + TP_OTCH) AS CL_BUH_NAME,
						POS_NAME AS CL_BUH_POS,
						TP_PHONE AS CL_BUH_PHONE
					FROM dbo.TOPersonalView
					WHERE RP_PSEDO = 'BUH'
				) AS BUH ON BUH.TP_ID_TO = TO_ID LEFT OUTER JOIN
				(
					SELECT
						TP_ID_TO,
						(TP_SURNAME + ' ' + TP_NAME + ' ' + TP_OTCH) AS CL_RES_NAME,
						POS_NAME AS CL_RES_POS,
						TP_PHONE AS CL_RES_PHONE
					FROM dbo.TOPersonalView
					WHERE RP_PSEDO = 'RES'
				) AS RES ON RES.TP_ID_TO = TO_ID LEFT OUTER JOIN
				(
					SELECT
						TP_ID_TO,
						(TP_SURNAME + ' ' + TP_NAME + ' ' + TP_OTCH) AS CL_PER4_NAME,
						POS_NAME AS CL_PER4_POS,
						TP_PHONE AS CL_PER4_PHONE
					FROM dbo.TOPersonalView
					WHERE RP_PSEDO = 'PER4'
				) AS PER4 ON PER4.TP_ID_TO = TO_ID LEFT OUTER JOIN
				(
					SELECT
						TP_ID_TO,
						(TP_SURNAME + ' ' + TP_NAME + ' ' + TP_OTCH) AS CL_PER5_NAME,
						POS_NAME AS CL_PER5_POS,
						TP_PHONE AS CL_PER5_PHONE
					FROM dbo.TOPersonalView
					WHERE RP_PSEDO = 'PER5'
				) AS PER5 ON PER5.TP_ID_TO = TO_ID
		WHERE	TO_REPORT = 1 AND TO_DELETED = 0
		ORDER BY TO_NUM

		SELECT
				VMR_RIC_NUM, VMR_TO_NUM, VMR_TO_NAME,
				VMR_INN, VMR_REGION, VMR_CITY, VMR_ADDR,
				VMR_FIO_1, VMR_JOB_1, VMR_TELS_1,
				VMR_FIO_2, VMR_JOB_2, VMR_TELS_2,
				VMR_FIO_3, VMR_JOB_3, VMR_TELS_3,
				VMR_FIO_4, VMR_JOB_4, VMR_TELS_4,
				VMR_FIO_5, VMR_JOB_5, VMR_TELS_5,
				VMR_SERV, VMR_DISTR, VMR_COMMENT
		FROM dbo.VMIReportTable
		ORDER BY VMR_TO_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[RIC_REPORT_CREATE_NEW] TO rl_vmi_report_w;
GO
