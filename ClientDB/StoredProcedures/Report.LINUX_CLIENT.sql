USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[LINUX_CLIENT]
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

		SELECT ClientFullName AS [Клиент], UF_NAME AS [Файл USR], UF_NOWIN_NAME AS [Название ОС], UF_NOWIN_EXTEND AS [Расширенное название ОС], UF_NOWIN_UNNAME AS [Полное название ОС], UF_DATE AS [Дата файла USR]
		FROM
			(
				SELECT b.ClientFullName, UF_NAME, T.UF_NOWIN_NAME, T.UF_NOWIN_EXTEND, T.UF_NOWIN_UNNAME, MAX(a.UF_DATE) AS UF_DATE
				FROM
					USR.USRFile a
					INNER JOIN USR.USRFileTech t ON a.UF_ID = t.UF_ID
					INNER JOIN dbo.ClientTable b ON a.UF_ID_CLIENT = b.ClientID
					INNER JOIN USR.USRActiveView c ON a.UF_ID = c.UF_ID
				WHERE T.UF_NOWIN_NAME <> '-'
				GROUP BY b.ClientFullName, UF_NAME, T.UF_NOWIN_NAME, T.UF_NOWIN_EXTEND, T.UF_NOWIN_UNNAME
			) AS o_O

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[LINUX_CLIENT] TO rl_report;
GO