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
ALTER PROCEDURE [dbo].[SYSTEM_NET_COEF_EDIT] 
	@ID			INT,
	@NET		SMALLINT,
	@PERIOD		SMALLINT,
	@COEF		DECIMAL(8, 4),
	@WEIGHT		DECIMAL(8, 4),
	@SUBHOST	DECIMAL(8, 4),
	@ROUND		SMALLINT,
	@ACTIVE		BIT,
	@REPLACE	BIT
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

		UPDATE dbo.SystemNetCoef
		SET 
			SNCC_ID_SN		= @NET,
			SNCC_ID_PERIOD	= @PERIOD, 
			SNCC_VALUE		= @COEF,
			SNCC_WEIGHT		= @WEIGHT,
			SNCC_SUBHOST	= @SUBHOST,
			SNCC_ROUND		= @ROUND,
			SNCC_ACTIVE		= @ACTIVE
		WHERE SNCC_ID = @ID

		IF @REPLACE = 1
		BEGIN
			DECLARE @PR_DATE SMALLDATETIME

			SELECT @PR_DATE = PR_DATE
			FROM dbo.PeriodTable
			WHERE PR_ID = @PERIOD

			UPDATE dbo.SystemNetCoef
			SET SNCC_VALUE = @COEF,
				SNCC_WEIGHT = @WEIGHT,
				SNCC_SUBHOST = @SUBHOST,
				SNCC_ROUND = @ROUND
			FROM 
				dbo.SystemNetCoef
				INNER JOIN dbo.PeriodTable ON PR_ID = SNCC_ID_PERIOD
			WHERE PR_DATE > @PR_DATE AND SNCC_ID_SN = @NET
		END
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[SYSTEM_NET_COEF_EDIT] TO rl_system_net_w;
GO