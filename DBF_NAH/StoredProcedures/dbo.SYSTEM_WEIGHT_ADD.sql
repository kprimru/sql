USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[SYSTEM_WEIGHT_ADD]
	@systemid SMALLINT,
	@periodid SMALLINT,
	@weight DECIMAL(8, 4),
	@problem BIT,
	@active BIT = 1,
	@replace BIT = 0,
	@returnvalue BIT = 1
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

		INSERT INTO dbo.SystemWeightTable(SW_ID_SYSTEM, SW_ID_PERIOD, SW_WEIGHT, SW_PROBLEM, SW_ACTIVE)
		VALUES (@systemid, @periodid, @weight, @problem, @active)

		IF @returnvalue = 1
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

		IF @replace = 1
		BEGIN
			DECLARE @PR_DATE SMALLDATETIME

			SELECT @PR_DATE = PR_DATE
			FROM dbo.PeriodTable
			WHERE PR_ID = @periodid

			INSERT INTO dbo.SystemWeightTable(SW_ID_SYSTEM, SW_ID_PERIOD, SW_WEIGHT, SW_PROBLEM, SW_ACTIVE)
				SELECT @systemid, PR_ID, @weight, @problem, 1
				FROM dbo.PeriodTable
				WHERE PR_DATE > @PR_DATE
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
GRANT EXECUTE ON [dbo].[SYSTEM_WEIGHT_ADD] TO rl_system_weight_w;
GO
