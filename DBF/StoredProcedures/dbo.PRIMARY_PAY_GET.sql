USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Дата создания: 02.02.2009
Описание:	  Выбрать данные о фин. установке
*/

CREATE PROCEDURE [dbo].[PRIMARY_PAY_GET] 
	@ppid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	
		DIS_ID, DIS_STR, PRP_DATE, PRP_PRICE, 
		PRP_TAX_PRICE, PRP_TOTAL_PRICE, PRP_DOC,
		PRP_COMMENT, ORG_ID, ORG_PSEDO
			--, TX_ID, TX_PERCENT, TX_NAME, TX_CAPTION
	FROM 
		dbo.PrimaryPayTable INNER JOIN
		dbo.DistrView ON PRP_ID_DISTR = DIS_ID LEFT OUTER JOIN
		dbo.OrganizationTable ON ORG_ID = PRP_ID_ORG
	WHERE PRP_ID = @ppid

	SET NOCOUNT OFF
END
