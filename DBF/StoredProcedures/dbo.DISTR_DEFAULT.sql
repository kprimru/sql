USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[DISTR_DEFAULT] 
	@sysid INT
AS
BEGIN
	SET NOCOUNT ON

	IF (SELECT SYS_SHORT_NAME FROM dbo.SystemTable WHERE SYS_ID = @sysid) IN ('ГК', 'Флэш', 'Yubikey', 'Лицензия')
		SELECT ISNULL(
			(
				SELECT MAX(DIS_NUM) + 1 AS DIS_NUM
				FROM dbo.DistrTable
				WHERE DIS_ID_SYSTEM = @sysid
			), 1000) AS DIS_NUM
	ELSE
		SELECT NULL AS DIS_NUM

	SET NOCOUNT OFF
END

