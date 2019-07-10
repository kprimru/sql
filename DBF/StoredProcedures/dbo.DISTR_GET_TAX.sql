USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			������� �������/������ ��������
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[DISTR_GET_TAX]
	@distrid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TX_PERCENT, TX_ID, TX_CAPTION
	FROM 
		dbo.TaxTable a INNER JOIN
		dbo.SaleObjectTable b ON a.TX_ID = b.SO_ID_TAX INNER JOIN
		dbo.DistrView c ON c.SYS_ID_SO = b.SO_ID
	WHERE DIS_ID = @distrid
END



