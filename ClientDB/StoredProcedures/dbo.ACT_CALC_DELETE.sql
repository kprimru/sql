USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACT_CALC_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACT_CALC_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACT_CALC_DELETE]
	@ID	UNIQUEIDENTIFIER
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

		IF (SELECT STATUS FROM dbo.ActCalc WHERE ID = @ID) <> 1
			RAISERROR('Уже нельзя удалить заявку', 16, 1)
		ELSE
		BEGIN
			UPDATE dbo.ActCalc
			SET STATUS = 3
			WHERE ID = @ID AND STATUS = 1

			IF @@ROWCOUNT = 0
				RAISERROR('Уже нельзя удалить заявку', 16, 1)
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
GRANT EXECUTE ON [dbo].[ACT_CALC_DELETE] TO rl_act_calc;
GO
