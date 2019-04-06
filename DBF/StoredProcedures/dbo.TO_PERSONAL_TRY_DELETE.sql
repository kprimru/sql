USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  Выбрать даанные о сотрудниках указанной ТО.
*/

CREATE PROCEDURE [dbo].[TO_PERSONAL_TRY_DELETE] 
	@personalid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''
		
	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END