USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:			
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[INVOICE_GET_LAST_NUM]
	@date SMALLDATETIME,
	@orgid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @insnum INT

	SELECT @insnum = MAX(INS_NUM) + 1
	FROM dbo.InvoiceSaleTable
	WHERE INS_NUM_YEAR = RIGHT(DATEPART(yy, @date),2)
		AND INS_ID_ORG = @orgid
	

	IF @insnum IS NULL	
		SET @insnum = 1

	SELECT @insnum AS INS_NUM, RIGHT(DATEPART(yy, @date),2) AS INS_NUM_YEAR
END
