USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[SERVICE_SALARY_SAVE]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@MONTH		UNIQUEIDENTIFIER,
	@SERVICE	INT,
	@POSITION	INT,
	@RATE		INT,
	@INSURANCE	INT = NULL
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

		UPDATE Salary.Service
		SET ID_MONTH		=	@MONTH,
			ID_SERVICE		=	@SERVICE,
			ID_POSITION		=	@POSITION,
			MANAGER_RATE	=	@RATE,
			INSURANCE		=	@INSURANCE
		WHERE ID = @ID

		IF @@ROWCOUNT = 0
		BEGIN
			DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

			INSERT INTO Salary.Service(ID_MONTH, ID_SERVICE, ID_POSITION, MANAGER_RATE, INSURANCE)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@MONTH, @SERVICE, @POSITION, @RATE, @INSURANCE)

			SELECT @ID = ID
			FROM @TBL
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Salary].[SERVICE_SALARY_SAVE] TO rl_salary;
GO