USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
јвтор:		  ƒенисов јлексей
ƒата создани€: 25.08.2008
ќписание:	  ¬озвращает 0, если обслуживающую 
               организацию с указанным кодом можно 
               удалить из справочника (она не 
               указана ни у одного клиента), 
               -1 в противном случае
*/

CREATE PROCEDURE [dbo].[ORGANIZATION_TRY_DELETE] 
	@organizationid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_ORG = @organizationid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'ƒанна€ организаци€ указана у одного или нескольких клиентов. ' + 
							  '”даление невозможно, пока выбранна€ организаци€ будет указана хот€ ' +
							  'бы у одного кдиента.'
		END

	-- добавлено 29.04.2009, ¬.Ѕогдан
	IF EXISTS(SELECT * FROM dbo.ActTable WHERE ACT_ID_ORG = @organizationid)
		BEGIN
			SET @res = 1
			SET @txt = @txt	+	'Ќевозможно удалить организацию, так как существуют ' +
								'выписанные на эту организацию акты.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.BillTable WHERE BL_ID_ORG = @organizationid)
		BEGIN
			SET @res = 1
			SET @txt = @txt	+	'Ќевозможно удалить организацию, так как существуют ' +
								'выписанные на эту организацию счета.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.IncomeTable WHERE IN_ID_ORG = @organizationid)
		BEGIN
			SET @res = 1
			SET @txt = @txt	+	'Ќевозможно удалить организацию, так как существуют ' +
								'поступившие на эту организацию платежи.' + CHAR(13)
		END
	IF EXISTS(SELECT * FROM dbo.InvoiceSaleTable WHERE INS_ID_ORG = @organizationid)
		BEGIN
			SET @res = 1
			SET @txt = @txt	+	'Ќевозможно удалить организацию, так как существуют ' +
								'выписанные на эту организацию счета-фактуры.' + CHAR(13)
		END
	--

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF
END
