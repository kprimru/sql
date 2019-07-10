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

CREATE PROCEDURE [dbo].[SYSTEM_NET_SELECT] 
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT SN_NAME, SN_FULL_NAME, SN_COEF, SN_ID 
	FROM dbo.SystemNetTable 
	WHERE SN_ACTIVE = ISNULL(@active, SN_ACTIVE)
	ORDER BY SN_ORDER

	SET NOCOUNT OFF
END








