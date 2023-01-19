USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STREET_TRY_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STREET_TRY_DELETE]  AS SELECT 1')
GO


/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Возвращает 0, если улицу с указанным
               кодом можно удалить из справочника
               (на нее не ссылается ни один адрес),
               -1 в противном случае
*/

ALTER PROCEDURE [dbo].[STREET_TRY_DELETE]
	@streetid INT
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

		-- добавлено 29.04.2009, В.Богдан
		IF EXISTS(SELECT * FROM dbo.ClientAddressTable WHERE CA_ID_STREET = @streetid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить улицу, так как она указана в адресах клиентов. '
		  END

		IF EXISTS(SELECT * FROM dbo.OrganizationTable WHERE ORG_ID_STREET = @streetid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить улицу, так как она указана в адресах обслуживающих организаций.'
		  END
		IF EXISTS(SELECT * FROM dbo.OrganizationTable WHERE ORG_S_ID_STREET	 = @streetid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить улицу, так как она указана в адресах обслуживающих организаций.'
		  END

		IF EXISTS(SELECT * FROM dbo.TOAddressTable WHERE TA_ID_STREET	 = @streetid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить улицу, так как она указана в адресах точек обслуживания.'
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
GRANT EXECUTE ON [dbo].[STREET_TRY_DELETE] TO rl_street_d;
GO
