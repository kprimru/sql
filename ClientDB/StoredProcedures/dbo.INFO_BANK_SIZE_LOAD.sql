USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INFO_BANK_SIZE_LOAD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INFO_BANK_SIZE_LOAD]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[INFO_BANK_SIZE_LOAD]
	@DATA	NVARCHAR(MAX)
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

		DECLARE @xml XML
		DECLARE @hdoc INT

		IF OBJECT_ID('tempdb..#ib') IS NOT NULL
			DROP TABLE #ib

		CREATE TABLE #ib
			(
				IB_NAME VARCHAR(50),
				FPATH NVARCHAR(1024),
				FNAME NVARCHAR(256),
				FSIZE BIGINT
			)

		SET @xml = CAST(@DATA AS XML)

		EXEC sp_xml_preparedocument @hdoc OUTPUT, @xml
		-- ToDo поменять формат xml
		INSERT INTO #ib(IB_NAME, FPATH, FNAME, FSIZE)
			SELECT
				c.value('local-name(./..)', 'VARCHAR(50)'),
				c.value('(../@fpath)', 'NVARCHAR(1024)'),
				c.value('(@fname)', 'NVARCHAR(256)'),
				c.value('(@fsize)', 'BIGINT')
			FROM @xml.nodes('/isize/*/*') AS a(c)

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #ib (IB_NAME, FPATH)'
		EXEC (@SQL)

		SET @SQL = 'CREATE INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #ib (FNAME) INCLUDE(FSIZE)'
		EXEC (@SQL)

		INSERT INTO dbo.InfoBankFile(IBF_ID_IB, IBF_NAME)
			SELECT InfoBankID, FNAME
			FROM
				#ib
				INNER JOIN dbo.InfoBankTable ON InfoBankName = IB_NAME
											AND InfoBankPath = FPATH
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.InfoBankFile
					WHERE IBF_ID_IB = InfoBankID AND FNAME = IBF_NAME
				)

		DECLARE @DT	SMALLDATETIME

		SET @DT = CONVERT(SMALLDATETIME, CONVERT(VARCHAR(20), GETDATE(), 112), 112)

		DELETE
		FROM dbo.InfoBankSize
		WHERE EXISTS
			(
				SELECT *
				FROM
					#ib
					INNER JOIN dbo.InfoBankTable ON InfoBankName = IB_NAME
												AND InfoBankPath = FPATH
					INNER JOIN dbo.InfoBankFile ON IBF_ID_IB = InfoBankID
												AND IBF_NAME = FNAME
				WHERE IBF_ID = IBS_ID_FILE AND IBS_SIZE = FSIZE AND IBS_DATE = @DT
			)

		INSERT INTO dbo.InfoBankSize(IBS_ID_FILE, IBS_DATE, IBS_SIZE)
			SELECT IBF_ID, @DT, FSIZE
			FROM
				#ib
				INNER JOIN dbo.InfoBankTable ON InfoBankName = IB_NAME
											AND InfoBankPath = FPATH
				INNER JOIN dbo.InfoBankFile ON IBF_ID_IB = InfoBankID
											AND IBF_NAME = FNAME
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.InfoBankSize
					WHERE IBS_ID_FILE = IBF_ID
						AND IBS_DATE = @DT
				)

		EXEC sp_xml_removedocument @hdoc

		IF OBJECT_ID('tempdb..#ib') IS NOT NULL
			DROP TABLE #ib

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INFO_BANK_SIZE_LOAD] TO rl_info_bank_size_u;
GO
