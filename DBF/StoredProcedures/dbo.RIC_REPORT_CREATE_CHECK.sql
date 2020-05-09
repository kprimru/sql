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

ALTER PROCEDURE [dbo].[RIC_REPORT_CREATE_CHECK]
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

		IF OBJECT_ID('tempdb..#vmi') IS NOT NULL
			DROP TABLE #vmi

			SELECT
				dbo.GET_SETTING('RIC_NUM') AS RIC_NUM,
				TO_NUM, TO_NAME, ISNULL(TO_INN ,'') AS CL_INN,
				CT_REGION AS CL_REGION,
				CT_NAME AS CL_CITY,

				CASE
					WHEN ISNULL(ST_PREFIX, '') = '' THEN ''
					ELSE ST_PREFIX + ' '
				END + ST_NAME + ',' + TA_HOME AS CL_ADDRESS,
				ISNULL(CL_DIR_NAME, '') AS CL_DIR_NAME, ISNULL(CL_DIR_POS, '') AS CL_DIR_POS, ISNULL(CL_DIR_PHONE, '') AS CL_DIR_PHONE,
				ISNULL(CL_BUH_NAME, '') AS CL_BUH_NAME, ISNULL(CL_BUH_POS, '') AS CL_BUH_POS, ISNULL(CL_BUH_PHONE, '') AS CL_BUH_PHONE,
				ISNULL(CL_RES_NAME, '') AS CL_RES_NAME, ISNULL(CL_RES_POS, '') AS CL_RES_POS, ISNULL(CL_RES_PHONE, '') AS CL_RES_PHONE,
				ISNULL(CL_PER4_NAME, '') AS CL_PER4_NAME, ISNULL(CL_PER4_POS, '') AS CL_PER4_POS, ISNULL(CL_PER4_PHONE, '') AS CL_PER4_PHONE,
				ISNULL(CL_PER5_NAME, '') AS CL_PER5_NAME, ISNULL(CL_PER5_POS, '') AS CL_PER5_POS, ISNULL(CL_PER5_PHONE, '') AS CL_PER5_PHONE,
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
									INNER JOIN dbo.PeriodTable c ON c.PR_ID = b.REG_ID_PERIOD
									INNER JOIN dbo.DistrStatusTable d ON d.DS_ID = b.REG_ID_STATUS
							WHERE TD_ID_TO = TO_ID   AND REG_MAIN = 1 AND d.DS_REG = 0
								AND PR_DATE >= '20120101'
								AND PR_DATE <= @PR_DATE

							UNION

							SELECT DISTINCT HST_REG_NAME, DIS_COMP_NUM, DIS_NUM, SYS_IB
							FROM dbo.TODistrView
							WHERE TD_ID_TO = TO_ID AND TD_FORCED = 1
						) AS o_O
					ORDER BY HST_REG_NAME, DIS_NUM, DIS_COMP_NUM FOR XML PATH('')
				)),1,1,'')), '') AS CL_SYSTEM,
				TO_VMI_COMMENT AS CL_COMMENT
			INTO #vmi
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
		WHERE	TO_REPORT = 1
		ORDER BY TO_NUM


		SELECT 'Слишком длинное название ТО. Максимум 250' AS TO_ERR, TO_NUM, LEN(TO_NAME) AS TO_LEN
		FROM #vmi
		WHERE LEN(TO_NAME) > 250

		UNION ALL

		SELECT 'Слишком длинное название нас.пункта. Максимум - 40', TO_NUM, LEN(CL_CITY)
		FROM #vmi
		WHERE LEN(CL_CITY) > 40

		UNION ALL

		SELECT 'Слишком длинный адрес. Максимум - 250', TO_NUM, LEN(CL_ADDRESS)
		FROM #vmi
		WHERE LEN(CL_ADDRESS) > 250

		UNION ALL

		SELECT 'Слишком длинное ФИО руководителя. Макс - 92', TO_NUM, LEN(CL_DIR_NAME)
		FROM #vmi
		WHERE LEN(CL_DIR_NAME) > 92

		UNION ALL

		SELECT 'Слишком длинное ФИО гл.бухгалтера. Макс - 92', TO_NUM, LEN(CL_BUH_NAME)
		FROM #vmi
		WHERE LEN(CL_BUH_NAME) > 92

		UNION ALL

		SELECT 'Слишком длинное ФИО ответственного. Макс - 92', TO_NUM, LEN(CL_RES_NAME)
		FROM #vmi
		WHERE LEN(CL_RES_NAME) > 92

		UNION ALL

		SELECT 'Слишком длинное ФИО 4-го сотрудника. Макс - 92', TO_NUM, LEN(CL_PER4_NAME)
		FROM #vmi
		WHERE LEN(CL_PER4_NAME) > 92

		UNION ALL

		SELECT 'Слишком длинное ФИО 5-го сотрудника. Макс - 92', TO_NUM, LEN(CL_PER5_NAME)
		FROM #vmi
		WHERE LEN(CL_PER5_NAME) > 92

		UNION ALL

		SELECT 'Слишком длинная должность руководителя. Макс - 100', TO_NUM, LEN(CL_DIR_POS)
		FROM #vmi
		WHERE LEN(CL_DIR_POS) > 100

		UNION ALL

		SELECT 'Слишком длинная должность гл.бухгалтера. Макс - 100', TO_NUM, LEN(CL_BUH_POS)
		FROM #vmi
		WHERE LEN(CL_BUH_POS) > 100

		UNION ALL

		SELECT 'Слишком длинная должность ответственного. Макс - 100', TO_NUM, LEN(CL_RES_POS)
		FROM #vmi
		WHERE LEN(CL_RES_POS) > 100

		UNION ALL

		SELECT 'Слишком длинная должность 4-го сотрудника. Макс - 100', TO_NUM, LEN(CL_PER4_POS)
		FROM #vmi
		WHERE LEN(CL_PER4_POS) > 100

		UNION ALL

		SELECT 'Слишком длинная должность 5-го сотрудника. Макс - 100', TO_NUM, LEN(CL_PER5_POS)
		FROM #vmi
		WHERE LEN(CL_PER5_POS) > 100

		UNION ALL

		SELECT 'Слишком длинный телефон руководителя. Макс - 62', TO_NUM, LEN(CL_DIR_PHONE)
		FROM #vmi
		WHERE LEN(CL_DIR_PHONE) > 62

		UNION ALL

		SELECT 'Слишком длинный телефон гл.бух. Макс - 62', TO_NUM, LEN(CL_BUH_PHONE)
		FROM #vmi
		WHERE LEN(CL_BUH_PHONE) > 62

		UNION ALL

		SELECT 'Слишком длинный телефон ответственного. Макс - 62', TO_NUM, LEN(CL_RES_PHONE)
		FROM #vmi
		WHERE LEN(CL_RES_PHONE) > 62

		UNION ALL

		SELECT 'Слишком длинный телефон 4-го сотрудника. Макс - 62', TO_NUM, LEN(CL_PER4_PHONE)
		FROM #vmi
		WHERE LEN(CL_PER4_PHONE) > 62

		UNION ALL

		SELECT 'Слишком длинный телефон 5-го сотрудника. Макс - 62', TO_NUM, LEN(CL_PER5_PHONE)
		FROM #vmi
		WHERE LEN(CL_PER5_PHONE) > 62

		UNION ALL

		SELECT 'Слишком длинный комментарий. Макс - 250', TO_NUM, LEN(CL_COMMENT)
		FROM #vmi
		WHERE LEN(CL_COMMENT) > 250

		UNION ALL

		SELECT 'Слишком длинная строка систем. Макс - 500', TO_NUM, LEN(CL_SYSTEM)
		FROM #vmi
		WHERE LEN(CL_SYSTEM) > 500

		IF OBJECT_ID('tempdb..#vmi') IS NOT NULL
			DROP TABLE #vmi

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[RIC_REPORT_CREATE_CHECK] TO rl_vmi_report_w;
GO