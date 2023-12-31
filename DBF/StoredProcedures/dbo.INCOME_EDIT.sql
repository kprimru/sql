USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			������� �������
��������:
*/

ALTER PROCEDURE [dbo].[INCOME_EDIT]
	@inid INT,
	@indate SMALLDATETIME,
	@sum MONEY,
	@paydate SMALLDATETIME,
	@paynum VARCHAR(50),
	@primary BIT
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

		UPDATE dbo.IncomeTable
		SET
			IN_DATE = @indate,
			IN_SUM = @sum,
			IN_PAY_DATE = @paydate,
			IN_PAY_NUM = @paynum,
			IN_PRIMARY = @primary
		WHERE IN_ID = @inid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INCOME_EDIT] TO rl_income_w;
GO
