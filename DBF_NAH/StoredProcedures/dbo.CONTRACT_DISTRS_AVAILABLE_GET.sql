USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		Денисов Алексей/Богдан Владимир
Описание:	Выдаёт список дистрибутивов
				договора по заданному контракту
*/

ALTER PROCEDURE [dbo].[CONTRACT_DISTRS_AVAILABLE_GET]
	@co_id INT
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

		SELECT DIS_ID, DIS_STR, DSS_NAME
		FROM dbo.ContractDistrsView
		WHERE CO_ID=@co_id
			AND	NOT EXISTS
				(
					SELECT *
					FROM dbo.ContractDistrTable
					WHERE	COD_ID_DISTR=DIS_ID
						AND	COD_ID_CONTRACT=@co_id
				)
		/*
		UNION

		SELECT c.DIS_ID, c.DIS_STR, a.DSS_NAME
		FROM
			dbo.ContractDistrsView a
			INNER JOIN dbo.DistrView b ON a.DIS_ID = b.DIS_ID
			INNER JOIN dbo.DistrView c ON b.HST_ID = b.HST_ID AND b.DIS_NUM = c.DIS_NUM AND b.DIS_COMP_NUM = c.DIS_COMP_NUM
		WHERE a.CO_ID = @co_id
		*/

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CONTRACT_DISTRS_AVAILABLE_GET] TO rl_client_contract_w;
GRANT EXECUTE ON [dbo].[CONTRACT_DISTRS_AVAILABLE_GET] TO rl_client_w;
GO