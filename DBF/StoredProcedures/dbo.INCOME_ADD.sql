USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[INCOME_ADD]
	@clientid INT,
	@indate SMALLDATETIME,
	@sum MONEY,
	@paydate SMALLDATETIME,
	@paynum VARCHAR(50),
	@primary BIT = 0,
	@returnvalue BIT = 1

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

		DECLARE @orgid SMALLINT

		SELECT @orgid = CL_ID_ORG
		FROM dbo.ClientTable
		WHERE CL_ID = @clientid

		INSERT INTO dbo.IncomeTable
			(
				IN_ID_CLIENT, IN_DATE, IN_SUM, IN_PAY_DATE,
				IN_PAY_NUM, IN_ID_ORG, IN_PRIMARY
			)
		VALUES
			(
				@clientid, @indate, @sum, @paydate, @paynum, @orgid, @primary
			)

		IF @returnvalue = 1
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INCOME_ADD] TO rl_income_w;
GO