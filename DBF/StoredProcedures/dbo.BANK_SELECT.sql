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

ALTER PROCEDURE [dbo].[BANK_SELECT]
	@active BIT = NULL
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

		SELECT
				BA_ID, BA_BIK, BA_NAME, CT_NAME, CT_ID,
				BA_PHONE, BA_MFO, BA_CALC, BA_LORO
		FROM
			dbo.BankTable bt LEFT OUTER JOIN
			dbo.CityTable ct ON ct.CT_ID = bt.BA_ID_CITY
		WHERE BA_ACTIVE = ISNULL(@active, BA_ACTIVE)
		ORDER BY BA_NAME, CT_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[BANK_SELECT] TO rl_bank_r;
GO
