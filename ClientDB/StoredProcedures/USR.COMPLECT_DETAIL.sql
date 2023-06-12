﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[COMPLECT_DETAIL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[COMPLECT_DETAIL]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[COMPLECT_DETAIL]
	@UF_ID	INT
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
			F.UF_ID,
			T.UF_FORMAT, 0 AS UF_FORMAT_ERROR,
			T.UF_RIC, CASE T.UF_RIC WHEN 20 THEN 0 ELSE 2 END AS UF_RIC_ERROR,
			ResVersionNumber, CASE IsLatest WHEN 1 THEN 0 ELSE 2 END AS ResVersionError,
			ConsExeVersionName, CASE ConsExeVersionActive WHEN 1 THEN 0 ELSE 2 END AS ConsExeVersionError,
			z.NAME AS KDVersionName, 0/*CASE z.ACTIVE WHEN 1 THEN 0 ELSE 2 END */AS KDVersionError,
			T.UF_COMPLECT_TYPE,
			PRC_NAME AS UF_PROC_NAME, PRC_FREQ AS UF_PROC_FREQ, PRC_CORE AS UF_PROC_CORE,
			PRC_NAME + ' (' + PRC_FREQ_S + ' x' + CONVERT(VARCHAR(20), PRC_CORE) + ')' AS UF_PROC, 0 AS UF_PROC_ERROR,
			dbo.FileSizeToStr(T.UF_RAM) AS UF_RAM, CASE WHEN T.UF_RAM <= 500 THEN 2 WHEN T.UF_RAM > 500 AND T.UF_RAM < 1000 THEN 1 ELSE 0 END AS UF_RAM_ERROR,
			ISNULL(OS_NAME, '') + ISNULL(' (' + OS_CAPACITY + ')', '') AS OS_NAME, 0 AS OS_ERROR, OS_LANG,
			CASE OS_LANG
				WHEN 'Russian' THEN 0
				ELSE 1
			END AS OS_LANG_ERROR,
			OS_COMPATIBILITY,
			CASE OS_COMPATIBILITY
				WHEN 'Не установлен' THEN 0
				ELSE 1
			END AS OS_COMP_ERROR,
			T.UF_BOOT_NAME, T.UF_BOOT_FREE,
			T.UF_BOOT_NAME + ' (' + dbo.FileSizeToStr(T.UF_BOOT_FREE) + ')' AS UF_BOOT, CASE WHEN T.UF_BOOT_FREE <= 1000 THEN 2 WHEN T.UF_BOOT_FREE > 1000 AND T.UF_BOOT_FREE <= 2000 THEN 1 ELSE 0 END AS UF_BOOT_ERROR,
			dbo.FileSizeToStr(T.UF_CONS_FREE) AS UF_CONS_FREE, CASE WHEN T.UF_CONS_FREE <= 2000 THEN 2 WHEN T.UF_CONS_FREE > 2000 AND T.UF_CONS_FREE <= 4000 THEN 1 ELSE 0 END AS UF_CONS_FREE_ERROR,
			T.UF_OFFICE, T.UF_BROWSER, T.UF_MAIL, T.UF_RIGHT,
			T.UF_OD, T.UF_UD, T.UF_TS, T.UF_VM,
			UF_DATE, USRFileKindShortName,
			UF_UPTIME, 0 AS UF_UPTIME_ERROR,
			T.UF_INFO_COD, 0/*CASE WHEN UF_INFO_COD IS NOT NULL THEN 2 ELSE 0 END*/ AS UF_INFO_COD_ERROR,
			T.UF_INFO_CFG, CASE WHEN T.UF_INFO_CFG IS NULL THEN 2 ELSE 0 END AS UF_INFO_CFG_ERROR,
			T.UF_CONSULT_TOR, CASE WHEN T.UF_CONSULT_TOR IS NULL THEN 2 ELSE 0 END AS UF_CONSULT_TOR_ERROR,
			T.UF_EXPCONS, CASE T.UF_EXPCONS_KIND WHEN 'V' THEN 'Разрешен' WHEN 'N' THEN 'Запрещен' ELSE 'Неизвестно' END AS UF_EXPCONS_KIND,
			T.UF_EXPUSERS,
			T.UF_HOTLINE, CASE T.UF_HOTLINE_KIND WHEN 'V' THEN 'Разрешен' WHEN 'N' THEN 'Запрещен' ELSE 'Неизвестно' END AS UF_HOTLINE_KIND,
			T.UF_HOTLINEUSERS,
			CASE T.UF_USERLIST WHEN 1 THEN 'Да' WHEN 0 THEN 'Нет' ELSE 'Неизвестно' END AS UF_USERLIST,
			CASE T.UF_USERLISTONLINE WHEN 1 THEN 'Да' WHEN 0 THEN 'Нет' ELSE 'Неизвестно' END AS UF_USERLISTONLINE,
			T.UF_USERLISTUSERSONLINE,
			T.[UF_START_KEY_WORK_DATE], T.[UF_START_KEY_WORK_CONTENT],
			T.[UF_START_KEY_CONS_DATE], T.[UF_START_KEY_CONS_CONTENT],
			USR.ComplectSize(F.UF_ID) AS UF_COMPLECT_SIZE,
			T.UF_FILE_SYSTEM,
			T.UF_WINE_EXISTS + ' (' + T.UF_WINE_VERSION + ')' AS UF_WINE,
			T.UF_NOWIN_UNNAME + ' (' + T.UF_NOWIN_NAME + '/' + T.UF_NOWIN_EXTEND + ')' AS UF_NOWIN,
			T.UF_TEMP_DIR + ' (' + dbo.FileSizeToStr(T.UF_TEMP_FREE) + ')' AS UF_TEMP, CASE WHEN T.UF_TEMP_FREE <= 1000 THEN 2 WHEN T.UF_TEMP_FREE > 1000 AND T.UF_TEMP_FREE <= 2000 THEN 1 ELSE 0 END AS UF_TEMP_ERROR
		FROM
			USR.USRFile F
			INNER JOIN USR.USRFileTech T ON F.UF_ID = T.UF_ID
			INNER JOIN USR.USRData ON UD_ID = UF_ID_COMPLECT
			INNER JOIN dbo.ResVersionTable ON T.UF_ID_RES = ResVersionID
			INNER JOIN dbo.USRFileKindTable ON USRFileKindID = UF_ID_KIND
			LEFT OUTER JOIN USR.Os ON OS_ID = T.UF_ID_OS
			LEFT OUTER JOIN dbo.ConsExeVersionTable ON ConsExeVersionID = T.UF_ID_CONS
			LEFT OUTER JOIN USR.Processor ON PRC_ID = T.UF_ID_PROC
			LEFT OUTER JOIN dbo.KDVersion z ON z.ID = T.UF_ID_KDVERSION
		WHERE F.UF_ID = @UF_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[COMPLECT_DETAIL] TO rl_tech_info;
GO
