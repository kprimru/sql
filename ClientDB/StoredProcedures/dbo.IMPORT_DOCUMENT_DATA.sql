USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[IMPORT_DOCUMENT_DATA]
	@DATA		NVARCHAR(MAX),
	@OUT_DATA	NVARCHAR(512) = NULL OUTPUT
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

		DECLARE @XML XML

		SET @XML = CAST(@DATA AS XML)

		DECLARE @REFRESH	INT

		SET @REFRESH = 0

		INSERT INTO dbo.ControlDocument(DATE, RIC, SYS_NUM, DISTR, COMP, IB, IB_NUM, DOC_NAME)
			SELECT DATE, 20, SYS_NUM, DISTR, COMP, IB, IB_NUM, DOC_NAME
			FROM
				(
					SELECT
						c.value('(@sys)[1]', 'INT') AS SYS_NUM,
						c.value('(@distr)[1]', 'INT') AS DISTR,
						c.value('(@comp)[1]', 'INT') AS COMP,
						CONVERT(DATETIME, c.value('(@date)[1]', 'NVARCHAR(64)'), 120) AS DATE,
						c.value('(@ib)[1]', 'NVARCHAR(64)') AS IB,
						c.value('(@ib_num)[1]', 'INT') AS IB_NUM,
						c.value('(doc_name)[1]', 'NVARCHAR(MAX)') AS DOC_NAME
					FROM @XML.nodes('root/document') a(c)
				) AS a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.ControlDocument z
					WHERE z.SYS_NUM = a.SYS_NUM
						AND z.DISTR = a.DISTR
						AND z.COMP = a.COMP
						AND z.DATE = a.DATE
						AND z.IB = a.IB
						AND z.IB_NUM = a.IB_NUM
						AND z.DOC_NAME = a.DOC_NAME
				)

		SET @REFRESH = @REFRESH + @@ROWCOUNT

		SET @OUT_DATA = 'Добавлено ' + CONVERT(NVARCHAR(32), @REFRESH) + ' записей.'

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[IMPORT_DOCUMENT_DATA] TO rl_import_data;
GO