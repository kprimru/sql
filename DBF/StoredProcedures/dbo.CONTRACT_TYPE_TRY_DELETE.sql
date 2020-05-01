USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
јвтор:		  ƒенисов јлексей
ќписание:	  ¬озвращает 0, если тип договора с
                указанным кодом можно удалить
                (на нее не ссылаетс€ ни один
                договор клиента),
                -1 в противном случае
*/

ALTER PROCEDURE [dbo].[CONTRACT_TYPE_TRY_DELETE]
	@contracttypeid SMALLINT
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

		IF EXISTS(SELECT * FROM dbo.ContractTable WHERE CO_ID_TYPE = @contracttypeid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'ƒанный тип указан у одного или нескольких договоров. ' +
							  '”даление невозможно, пока выбранный тип будет указан хот€ ' +
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
GRANT EXECUTE ON [dbo].[CONTRACT_TYPE_TRY_DELETE] TO rl_contract_type_d;
GO