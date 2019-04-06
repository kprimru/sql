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

CREATE PROCEDURE [dbo].[TO_PERSONAL_GET] 
	@tpid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
			TP_ID, TP_SURNAME, TP_NAME, TP_OTCH,	TP_PHONE, TP_PHONE_OLD,
			POS_ID, POS_NAME, RP_ID, RP_NAME
	FROM dbo.TOPersonalView
	WHERE TP_ID = @tpid	

	SET NOCOUNT OFF
END