USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[SALDO_RECALC_ALL]
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

		DECLARE CLIENT CURSOR LOCAL FOR
			SELECT CL_ID
			FROM dbo.ClientTable
			WHERE EXISTS
					(
						SELECT *
						FROM dbo.SaldoTable
						WHERE SL_ID_CLIENT = CL_ID
					)

		OPEN CLIENT

		DECLARE @clid INT

		FETCH NEXT FROM CLIENT INTO @clid

		WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC dbo.SALDO_RECALC @clid

				FETCH NEXT FROM CLIENT INTO @clid
			END

		CLOSE CLIENT
		DEALLOCATE CLIENT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SALDO_RECALC_ALL] TO rl_saldo_w;
GO
