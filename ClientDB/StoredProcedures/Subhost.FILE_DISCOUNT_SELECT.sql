USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[FILE_DISCOUNT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[FILE_DISCOUNT_SELECT]  AS SELECT 1')
GO

ALTER PROCEDURE [Subhost].[FILE_DISCOUNT_SELECT]
	@SUBHOST	NVARCHAR(16),
	@USR		NVARCHAR(128)
WITH EXECUTE AS OWNER
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

		IF @SUBHOST <> 'Н1'
		BEGIN
			RAISERROR ('Вашему подхосту недоступен данный отчет', 16, 1)
			RETURN
		END

		IF OBJECT_ID('tempdb..#r') IS NOT NULL
			DROP TABLE #r

		CREATE TABLE #r
			(
				CL_ID		INT,
				CL_PSEDO	NVARCHAR(128),
				DIS_STR		NVARCHAR(128),
				SST_CAPTION	NVARCHAR(128),
				SN_NAME		NVARCHAR(128),
				DISCOUNT	INT,
				DF_FIXED	MONEY,
				REAL_DISC	DECIMAL(8,4),
				SYS_ORDER	INT,
				DIS_NUM		INT,
				DIS_COMP	TINYINT
			)

		INSERT INTO #r
			EXEC DBF_NAH.dbo.DISTR_FINANCING_REPORT

		SELECT
			CL_PSEDO AS 'Клиент', DIS_STR AS 'Дистрибутив', SST_CAPTION AS 'Тип системы',
			SN_NAME AS 'Тип сети', DISCOUNT AS 'Скидка', DF_FIXED AS 'Фикс.сумма',
			REAL_DISC AS 'Реальная скидка'
		FROM #r
		ORDER BY CL_PSEDO, SYS_ORDER, DIS_NUM, DIS_COMP

		IF OBJECT_ID('tempdb..#r') IS NOT NULL
			DROP TABLE #r

		INSERT INTO Subhost.FilesDownload(ID_SUBHOST, USR, FTYPE)
			SELECT SH_ID, @USR, N'DISCOUNT'
			FROM dbo.Subhost
			WHERE SH_REG = @SUBHOST
				AND @USR IS NOT NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[FILE_DISCOUNT_SELECT] TO rl_web_subhost;
GO
