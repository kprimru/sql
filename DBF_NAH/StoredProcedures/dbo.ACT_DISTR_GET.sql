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

ALTER PROCEDURE [dbo].[ACT_DISTR_GET]
	@adid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		DIS_ID, DIS_STR, AD_PRICE, AD_TAX_PRICE, AD_TOTAL_PRICE,
		PR_ID, PR_DATE
	FROM dbo.ActDistrView
	WHERE AD_ID = @adid
END





GO
GRANT EXECUTE ON [dbo].[ACT_DISTR_GET] TO rl_act_w;
GO