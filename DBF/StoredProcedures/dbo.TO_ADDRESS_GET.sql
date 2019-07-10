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

CREATE PROCEDURE [dbo].[TO_ADDRESS_GET] 
	@taid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
			TA_ID, TA_INDEX, TA_HOME, ST_ID, ST_NAME
	FROM dbo.TOAddressView
	WHERE TA_ID = @taid	

	SET NOCOUNT OFF
END