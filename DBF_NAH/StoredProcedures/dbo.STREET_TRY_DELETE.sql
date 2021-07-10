USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
јвтор:		  ƒенисов јлексей
ƒата создани€: 25.08.2008
ќписание:	  ¬озвращает 0, если улицу с указанным
               кодом можно удалить из справочника
               (на нее не ссылаетс€ ни один адрес),
               -1 в противном случае
*/

ALTER PROCEDURE [dbo].[STREET_TRY_DELETE]
	@streetid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- добавлено 29.04.2009, ¬.Ѕогдан
	IF EXISTS(SELECT * FROM dbo.ClientAddressTable WHERE CA_ID_STREET = @streetid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + 'Ќевозможно удалить улицу, так как она указана в адресах клиентов. '
	  END

	IF EXISTS(SELECT * FROM dbo.OrganizationTable WHERE ORG_ID_STREET = @streetid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + 'Ќевозможно удалить улицу, так как она указана в адресах обслуживающих организаций.'
	  END
	IF EXISTS(SELECT * FROM dbo.OrganizationTable WHERE ORG_S_ID_STREET	 = @streetid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + 'Ќевозможно удалить улицу, так как она указана в адресах обслуживающих организаций.'
	  END

	IF EXISTS(SELECT * FROM dbo.TOAddressTable WHERE TA_ID_STREET	 = @streetid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + 'Ќевозможно удалить улицу, так как она указана в адресах точек обслуживани€.'
	  END
	--

	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END



GO
GRANT EXECUTE ON [dbo].[STREET_TRY_DELETE] TO rl_street_d;
GO