USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Удалить из справочника обслуживающую 
               организацию с указанным кодом
*/

CREATE PROCEDURE [dbo].[ORGANIZATION_DELETE] 
	@organizationid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.OrganizationTable 
	WHERE ORG_ID = @organizationid

	SET NOCOUNT OFF
END
