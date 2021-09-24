USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_CALC]
	@CALC_DATA	NVARCHAR(MAX),
	@SERVICE	NVARCHAR(128)
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

		DECLARE @ID UNIQUEIDENTIFIER

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		INSERT INTO dbo.ActCalc(SERVICE, CALC_STATUS)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@SERVICE, 'Не расчитан')

		SELECT @ID = ID FROM @TBL

		DECLARE @XML XML

		SET @XML = CAST(@CALC_DATA AS XML)

		INSERT INTO dbo.ActCalcDetail(ID_MASTER, SYS_REG, DISTR, COMP, MON, CONFRM)
			SELECT @ID,
				c.value('(@sys)', 'NVARCHAR(64)'), c.value('(@distr)', 'INT'),
				c.value('(@comp)', 'INT'), CONVERT(SMALLDATETIME, c.value('(@month)', 'NVARCHAR(64)'), 112),
				CONVERT(BIT, c.value('(@confirm)', 'TINYINT'))
			FROM @xml.nodes('/root/item') AS a(c)

		IF EXISTS
			(
				SELECT *
				FROM dbo.ActCalcDetail
				WHERE ID_MASTER = @ID
					AND CONFRM = 1
			)
		BEGIN
			UPDATE dbo.ActCalc
			SET CONFIRM_NEED = 1
			WHERE ID = @ID

			DECLARE @MSG NVARCHAR(MAX)

			SET @MSG = 'Рассчитанные акты нуждаются в подтверждении (' + @SERVICE + ')'

			EXEC dbo.CLIENT_MESSAGE_SEND NULL, 1, 'boss',  @MSG, 0
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
GRANT EXECUTE ON [dbo].[ACT_CALC] TO rl_act_calc;
GO
