﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Возвращает 0, если обслуживающую
               организацию с указанным кодом можно
               удалить из справочника (она не
               указана ни у одного клиента),
               -1 в противном случае
*/

ALTER PROCEDURE [dbo].[ORGANIZATION_TRY_DELETE]
	@organizationid SMALLINT
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

		IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_ORG = @organizationid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'Данная организация указана у одного или нескольких клиентов. ' +
								  'Удаление невозможно, пока выбранная организация будет указана хотя ' +
								  'бы у одного кдиента.'
			END

		-- добавлено 29.04.2009, В.Богдан
		IF EXISTS(SELECT * FROM dbo.ActTable WHERE ACT_ID_ORG = @organizationid)
			BEGIN
				SET @res = 1
				SET @txt = @txt	+	'Невозможно удалить организацию, так как существуют ' +
									'выписанные на эту организацию акты.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.BillTable WHERE BL_ID_ORG = @organizationid)
			BEGIN
				SET @res = 1
				SET @txt = @txt	+	'Невозможно удалить организацию, так как существуют ' +
									'выписанные на эту организацию счета.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.IncomeTable WHERE IN_ID_ORG = @organizationid)
			BEGIN
				SET @res = 1
				SET @txt = @txt	+	'Невозможно удалить организацию, так как существуют ' +
									'поступившие на эту организацию платежи.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.InvoiceSaleTable WHERE INS_ID_ORG = @organizationid)
			BEGIN
				SET @res = 1
				SET @txt = @txt	+	'Невозможно удалить организацию, так как существуют ' +
									'выписанные на эту организацию счета-фактуры.' + CHAR(13)
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
GRANT EXECUTE ON [dbo].[ORGANIZATION_TRY_DELETE] TO rl_organization_d;
GO
