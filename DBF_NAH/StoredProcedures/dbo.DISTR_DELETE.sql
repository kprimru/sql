USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[DISTR_DELETE]
	@distrid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.DistrDeliveryHistoryTable
	WHERE DDH_ID_DISTR = @distrid

	DELETE
	FROM dbo.DistrFinancingTable
	WHERE DF_ID_DISTR = @distrid

	DELETE
	FROM dbo.DistrDocumentTable
	WHERE DD_ID_DISTR = @distrid

	DELETE
	FROM dbo.DistrTable
	WHERE DIS_ID = @distrid

	SET NOCOUNT OFF
END






GO
GRANT EXECUTE ON [dbo].[DISTR_DELETE] TO rl_distr_d;
GO