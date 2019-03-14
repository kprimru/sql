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

CREATE PROCEDURE [dbo].[INCOME_CHECK_INVOICE]
	@incomeid INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @inv INT

	SELECT @inv = IN_ID_INVOICE
	FROM dbo.IncomeTable
	WHERE IN_ID = @incomeid

	IF @inv IS NULL
		BEGIN
			SELECT 1
			WHERE 1 = 0

			RETURN
		END

	SELECT
		(
			SELECT SUM(IN_SUM)
			FROM dbo.IncomeTable
			WHERE IN_ID_INVOICE = @inv
		) AS IN_SUM,
		(
			SELECT SUM(INR_SALL)
			FROM dbo.InvoiceRowTable
			WHERE INR_ID_INVOICE = @inv
		) AS INS_SUM
END
