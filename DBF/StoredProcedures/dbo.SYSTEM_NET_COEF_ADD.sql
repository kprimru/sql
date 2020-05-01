USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

ALTER PROCEDURE [dbo].[SYSTEM_NET_COEF_ADD] 
	@NET		SMALLINT,
	@PERIOD		SMALLINT,
	@COEF		DECIMAL(8, 4),
	@WEIGHT		DECIMAL(8, 4),
	@SUBHOST	DECIMAL(8, 4),
	@ROUND		SMALLINT,
	@ACTIVE		BIT = 1,
	@REPLACE	BIT = 0,
	@RETURN		BIT = 1
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

		INSERT INTO dbo.SystemNetCoef(SNCC_ID_SN, SNCC_ID_PERIOD, SNCC_VALUE, SNCC_WEIGHT, SNCC_SUBHOST, SNCC_ROUND, SNCC_ACTIVE) 
			VALUES (@NET, @PERIOD, @COEF, @WEIGHT, @SUBHOST, @ROUND, @ACTIVE)

		IF @RETURN = 1
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

		IF @replace = 1
		BEGIN
			DECLARE @PR_DATE SMALLDATETIME

			SELECT @PR_DATE = PR_DATE
			FROM dbo.PeriodTable
			WHERE PR_ID = @PERIOD

			INSERT INTO dbo.SystemNetCoef(SNCC_ID_SN, SNCC_ID_PERIOD, SNCC_VALUE, SNCC_WEIGHT, SNCC_SUBHOST, SNCC_ROUND, SNCC_ACTIVE)
				SELECT @NET, PR_ID, @COEF, @WEIGHT, @SUBHOST, @ROUND, @ACTIVE
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
GRANT EXECUTE ON [dbo].[SYSTEM_NET_COEF_ADD] TO rl_system_net_w;
GO