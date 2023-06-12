USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_TRY_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_TRY_DELETE]  AS SELECT 1')
GO



/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_TRY_DELETE]
	@clientid INT
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

		IF EXISTS(SELECT * FROM dbo.ClientDistrTable WHERE CD_ID_CLIENT = @clientid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить клиента, так как ему занесены дистрибутивы.' + CHAR(13)
		  END
		IF EXISTS(SELECT * FROM dbo.ClientAddressTable WHERE CA_ID_CLIENT = @clientid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить клиента, так как ему занесены адреса.' + CHAR(13)
		  END
		IF EXISTS(SELECT * FROM dbo.ContractTable WHERE CO_ID_CLIENT = @clientid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить дистрибутивы, так как ему занесены договора.' + CHAR(13)
		  END
		IF EXISTS(SELECT * FROM dbo.ClientPersonalTable WHERE PER_ID_CLIENT = @clientid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить клиента, так как ему занесены сотрудники.' + CHAR(13)
		  END
		IF EXISTS(SELECT * FROM dbo.TOTable WHERE TO_ID_CLIENT = @clientid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить клиента, так как ему занесены ТО.' + CHAR(13)
		  END

		-- добавлено 30.04.2009, В.Богдан
		IF EXISTS(SELECT * FROM dbo.ActTable WHERE ACT_ID_CLIENT = @clientid)
			BEGIN
				SET @txt = @txt	+	'Невозможно удалить клиента, так как существуют ' +
									'выписанные на него акты.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.BillTable WHERE BL_ID_CLIENT = @clientid)
			BEGIN
				SET @txt = @txt	+	'Невозможно удалить клиента, так как существуют ' +
									'выписанные на него счета.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.IncomeTable WHERE IN_ID_CLIENT = @clientid)
			BEGIN
				SET @txt = @txt	+	'Невозможно удалить клиента, так как существуют ' +
									'поступившие на него платежи.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.InvoiceSaleTable WHERE INS_ID_CLIENT = @clientid)
			BEGIN
				SET @txt = @txt	+	'Невозможно удалить клиента, так как существуют ' +
									'выписанные на него счета-фактуры.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.SaldoTable WHERE SL_ID_CLIENT = @clientid)
			BEGIN
				SET @txt = @txt	+	'Невозможно удалить клиента, так как на него имеются ' +
									'данные о сальдо.' + CHAR(13)
			END
		--

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
GRANT EXECUTE ON [dbo].[CLIENT_TRY_DELETE] TO rl_client_d;
GO
