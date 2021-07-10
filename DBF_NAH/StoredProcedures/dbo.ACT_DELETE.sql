USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:
*/

ALTER PROCEDURE [dbo].[ACT_DELETE]
	@actid INT
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

		DECLARE @CLIENT	INT
		DECLARE @TXT	VARCHAR(MAX)

		EXEC dbo.ACT_PROTOCOL @actid, @CLIENT OUTPUT, @TXT OUTPUT

		EXEC dbo.FINANCING_PROTOCOL_ADD 'ACT', 'Удаление акта', @TXT, @CLIENT, @actid

		DELETE
		FROM dbo.SaldoTable
		WHERE SL_ID_ACT_DIS IN
				(
					SELECT AD_ID
					FROM dbo.ActDistrTable
					WHERE AD_ID_ACT = @actid
				)

		DELETE
		FROM dbo.ActDistrTable
		WHERE AD_ID_ACT = @actid

		DELETE
		FROM dbo.ActTable
		WHERE ACT_ID = @actid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[ACT_DELETE] TO rl_act_d;
GO