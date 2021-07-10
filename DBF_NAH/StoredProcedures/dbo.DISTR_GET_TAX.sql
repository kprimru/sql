USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[DISTR_GET_TAX]
	@distrid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TX_PERCENT, TX_ID, TX_CAPTION
	FROM
		dbo.TaxTable a INNER JOIN
		dbo.SaleObjectTable b ON a.TX_ID = b.SO_ID_TAX INNER JOIN
		dbo.DistrView c WITH(NOEXPAND) ON c.SYS_ID_SO = b.SO_ID
	WHERE DIS_ID = @distrid
END
GO
GRANT EXECUTE ON [dbo].[DISTR_GET_TAX] TO rl_client_fin_r;
GO