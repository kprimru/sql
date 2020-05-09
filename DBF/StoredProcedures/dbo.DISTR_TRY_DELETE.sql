USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
јвтор:		  ƒенисов јлексей
ƒата создани€: 18.11.2008
ќписание:	  ¬озвращает 0, если дистрибутив с
               указанным кодом можно удалить со
               склада, -1 в противном случае
*/

ALTER PROCEDURE [dbo].[DISTR_TRY_DELETE]
	@distrid INT
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

		IF EXISTS(SELECT * FROM dbo.ClientDistrTable WHERE CD_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'ƒанный дистрибутив у какого-то клиента. ”даление невозможно,'
								+ 'пока выбранный дистрибутив распределен клиенту.'
								+ CHAR(13)
			END

		-- добавлено 30.04.2009, ¬.Ѕогдан
		IF EXISTS(SELECT * FROM dbo.BillDistrTable WHERE BD_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '»меетс€ счет, в котором указан данный дистрибутив. ”даление невозможно,'
								+ 'пока выбранный дистрибутив указан в счете.'
								+ CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.ContractDistrTable WHERE COD_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '»меетс€ договор, в котором указан данный дистрибутив. ”даление невозможно,'
								+ 'пока выбранный дистрибутив указан в договоре.'
								+ CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.ActDistrTable WHERE AD_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '»меетс€ акт, в котором указан данный дистрибутив. ”даление невозможно,'
								+ 'пока выбранный дистрибутив указан в акте.'
								+ CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.IncomeDistrTable WHERE ID_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '»меетс€ платеж, в котором указан данный дистрибутив. ”даление невозможно,'
								+ 'пока выбранный дистрибутив указан в платеже.'
								+ CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.InvoiceRowTable WHERE INR_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '»меетс€ счет-фактура, в которой указан данный дистрибутив. ”даление невозможно,'
								+ 'пока выбранный дистрибутив указан в счет-фактуре.'
								+ CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.PrimaryPayTable WHERE PRP_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '»меетс€ первична€ оплата, в которой указан данный дистрибутив. ”даление невозможно,'
								+ 'пока выбранный дистрибутив указан в первичной оплате.'
								+ CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.TODistrTable WHERE TD_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'ƒанный дистрибутив указан у какой-то “ќ. ”даление невозможно,'
								+ 'пока выбранный дистрибутив распределен “ќ.'
								+ CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.SaldoTable WHERE SL_ID_DISTR = @distrid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + '”даление невозможно, так как данный дистрибутив указан в записи о сальдо.'
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
GRANT EXECUTE ON [dbo].[DISTR_TRY_DELETE] TO rl_distr_d;
GO