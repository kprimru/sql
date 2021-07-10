USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
јвтор:		  ƒенисов јлексей
ƒата создани€: 25.08.2008
ќписание:	  ¬озвращает 0, если период можно
               удалить из справочника (на него
               не ссылаетс€ ни одна запись
               из других таблиц),
               -1 в противном случае
*/

ALTER PROCEDURE [dbo].[PERIOD_TRY_DELETE]
	@periodid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.PeriodRegTable WHERE REG_ID_PERIOD = @periodid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + '--'
	  END
	IF EXISTS(SELECT * FROM dbo.PeriodRegNewTable WHERE RNN_ID_PERIOD = @periodid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + CHAR(13) + '--'
	  END

	-- добавлено 29.04.2009, ¬.Ѕогдан
	IF EXISTS(SELECT * FROM dbo.ActDistrTable WHERE AD_ID_PERIOD = @periodid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt	+	'Ќевозможно удалить период, так как существуют ' +
							'выписанные на этот период акты.' + CHAR(13)
	  END
	IF EXISTS(SELECT * FROM dbo.BillTable WHERE BL_ID_PERIOD = @periodid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt +	'Ќевозможно удалить период, так как существуют ' +
							'выписанные на этот период счета.' + CHAR(13)
	  END
	IF EXISTS(SELECT * FROM dbo.InvoiceRowTable WHERE INR_ID_PERIOD = @periodid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt +	'Ќевозможно удалить период, так как существуют ' +
							'выписанные на этот период счета-фактуры.' + CHAR(13)
	  END
	IF EXISTS(SELECT * FROM dbo.IncomeDistrTable WHERE ID_ID_PERIOD = @periodid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt +	'Ќевозможно удалить период, так как существуют ' +
							'платежи по дистрибутивам за этот период.' + CHAR(13)
	  END
	IF EXISTS(SELECT * FROM dbo.PriceSystemTable WHERE PS_ID_PERIOD = @periodid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt +	'Ќевозможно удалить период, так как существуют ' +
							'прейскуранты по дистрибутивам за этот период.' + CHAR(13)
	  END
	IF EXISTS(SELECT * FROM dbo.VMIReportHistoryTable WHERE VRH_ID_PERIOD = @periodid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt +	'Ќевозможно удалить период, так как существует ' +
							'отчет ¬ћ» за этот период.' + CHAR(13)
	  END
	IF EXISTS(SELECT * FROM dbo.ClientHistoryTable WHERE CH_ID_PERIOD = @periodid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt +	'Ќевозможно удалить период, так как существует ' +
							'записи в истории клиента с этим периодом.' + CHAR(13)
	  END
	IF EXISTS(SELECT * FROM dbo.PriceSystemHistoryTable WHERE PSH_ID_PERIOD = @periodid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'Ќевозможно удалить период, так как '
					+ 'имеютс€ записи в истории цен за данный период.'
		END

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END




GO
GRANT EXECUTE ON [dbo].[PERIOD_TRY_DELETE] TO rl_period_d;
GO