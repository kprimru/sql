USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONTRACT_PAY_TRY_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONTRACT_PAY_TRY_DELETE]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Описание:	  Возвращает 0, если тип договора с
                указанным кодом можно удалить
                (на нее не ссылается ни один
                договор клиента),
                -1 в противном случае
*/

ALTER PROCEDURE [dbo].[CONTRACT_PAY_TRY_DELETE]
	@id SMALLINT
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

		DECLARE @res INT
		DECLARE @txt VARCHAR(MAX)

		SET @res = 0
		SET @txt = ''

		IF EXISTS(SELECT * FROM dbo.ContractTable WHERE CO_ID_PAY = @id)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Данный тип указан у одного или нескольких договоров. ' +
							  'Удаление невозможно, пока выбранный тип будет указан хотя ' +
							  'бы в одном договоре.'
		  END

		SELECT @res AS RES, @txt AS TXT


		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CONTRACT_PAY_TRY_DELETE] TO rl_contract_pay_d;
GO
