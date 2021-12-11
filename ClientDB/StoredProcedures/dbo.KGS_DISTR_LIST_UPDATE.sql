USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[KGS_DISTR_LIST_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[KGS_DISTR_LIST_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[KGS_DISTR_LIST_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100),
	@LIST	NVARCHAR(MAX)
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

		UPDATE dbo.KGSDistrList
		SET KDL_NAME = @NAME,
			KDL_LAST = GETDATE()
		WHERE KDL_ID = @ID

		DECLARE @XML	XML
		DECLARE @HDOC	INT

		SET @XML = CAST(@LIST AS XML)

		EXEC sp_xml_preparedocument @HDOC OUTPUT, @XML

		IF OBJECT_ID('tempdb..#distr_list') IS NOT NULL
			DROP TABLE #distr_list

		CREATE TABLE #distr_list
			(
				SYS_ID	INT,
				DIS_NUM	INT,
				COMP_NUM	TINYINT
			)

		INSERT INTO #distr_list(SYS_ID, DIS_NUM, COMP_NUM)
			SELECT 
				c.value('(@SYS)', 'INT'),
				c.value('(@DISTR)', 'INT'),
				c.value('(@COMP)', 'TINYINT')
			FROM @xml.nodes('/root/*') AS a(c)

		DELETE
		FROM dbo.KGSDistr
		WHERE KD_ID_LIST = @ID
			AND NOT EXISTS
				(
					SELECT *
					FROM #distr_list
					WHERE KD_ID_SYS = SYS_ID
						AND KD_DISTR = DIS_NUM
						AND KD_COMP = COMP_NUM
				)

		INSERT INTO dbo.KGSDistr(KD_ID_LIST, KD_ID_SYS, KD_DISTR, KD_COMP)
			SELECT @ID, SYS_ID, DIS_NUM, COMP_NUM
			FROM #distr_list
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.KgsDistr
					WHERE KD_ID_SYS = SYS_ID
						AND KD_DISTR = DIS_NUM
						AND KD_COMP = COMP_NUM
				)

		IF OBJECT_ID('tempdb..#distr_list') IS NOT NULL
			DROP TABLE #distr_list

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[KGS_DISTR_LIST_UPDATE] TO rl_kgs_distr_u;
GO
