USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[SERVICE_SALARY_DISTR_IMPORT]
	@ID			UNIQUEIDENTIFIER,
	@CLIENT		NVARCHAR(512),
	@HOST		INT,
	@DISTR		INT,
	@COMP		TINYINT,
	@DISTR_STR	NVARCHAR(256),
	@OPER		NVARCHAR(64),
	@OPER_NOTE	NVARCHAR(256),
	@PRICE_OLD	MONEY,
	@PRICE_NEW	MONEY,
	@WEIGHT_OLD	DECIMAL(8, 4),
	@WEIGHT_NEW	DECIMAL(8, 4)
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

		SET @WEIGHT_OLD = ISNULL(@WEIGHT_OLD, 0)
		SET @WEIGHT_NEW = ISNULL(@WEIGHT_NEW, 0)
		SET @PRICE_OLD = ISNULL(@PRICE_OLD, 0)
		SET @PRICE_NEW = ISNULL(@PRICE_NEW, 0)

		INSERT INTO Salary.ServiceDistr(ID_SALARY, CLIENT, ID_HOST, DISTR, COMP, DISTR_STR, OPER, OPER_NOTE, PRICE_OLD, PRICE_NEW, WEIGHT_OLD, WEIGHT_NEW)
			VALUES(@ID, @CLIENT, @HOST, @DISTR, @COMP, @DISTR_STR, @OPER, @OPER_NOTE, @PRICE_OLD, @PRICE_NEW, @WEIGHT_OLD, @WEIGHT_NEW)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Salary].[SERVICE_SALARY_DISTR_IMPORT] TO rl_salary;
GO
