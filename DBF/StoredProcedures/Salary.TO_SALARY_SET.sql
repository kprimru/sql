USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[TO_SALARY_SET]
	@TO_ID			INT,
	@TO_SALARY		MONEY
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

        IF @TO_SALARY = 0
            SET @TO_SALARY = NULL;

		UPDATE [dbo].[TOTable] SET
		    [TO_SALARY] = @TO_SALARY
		WHERE [TO_ID] = @TO_ID;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Salary].[TO_SALARY_SET] TO rl_courier_pay;
GO
