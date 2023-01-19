USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISTRS_CONTRACT_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISTRS_CONTRACT_ADD]  AS SELECT 1')
GO

/*
Автор:			%authorname%
Дата создания:	03.02.2009
Описание:		Добавить (сопоставить)
				дистрибутив в договор
				(договору) из уже имеющихся
				дистрибутивов для данной ТО
*/

ALTER PROCEDURE [dbo].[DISTRS_CONTRACT_ADD]
	@co_id INT,
	@distrs VARCHAR(1000)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF OBJECT_ID('tempdb..#distrstmp') IS NOT NULL
			DROP TABLE #distrstmp

		  CREATE TABLE #distrstmp
			(
			  distr	INT
			)

		IF @distrs IS NOT NULL
			BEGIN
			  --парсить строчку и выбирать нужные значения
			  INSERT INTO #distrstmp
				SELECT DISTINCT * FROM dbo.GET_TABLE_FROM_LIST(@distrs, ',')
			  END

		INSERT INTO dbo.ContractDistrTable SELECT @co_id , distr FROM #distrstmp


		/*IF @returnvalue = 1
		  SELECT SCOPE_IDENTITY() AS NEW_IDEN
		*/

		IF OBJECT_ID('tempdb..#distrstmp') IS NOT NULL
			DROP TABLE #distrstmp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[DISTRS_CONTRACT_ADD] TO rl_client_contract_w;
GO
