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

CREATE PROCEDURE [dbo].[BILL_DISTR_DELETE]
	@blid VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#bill') IS NOT NULL
		DROP TABLE #bill

	CREATE TABLE #bill
		(
			billid INT
		)

	IF @blid IS NOT NULL
		BEGIN
			--������� ������� � �������� ������ ��������
			INSERT INTO #bill
				SELECT DISTINCT * FROM dbo.GET_TABLE_FROM_LIST(@blid, ',')
		END

	DELETE FROM dbo.SaldoTable
	WHERE SL_ID_BILL_DIS IN	(SELECT billid FROM #bill)

	DELETE FROM dbo.BillDistrTable
	WHERE BD_ID IN (SELECT billid FROM #bill)

	IF OBJECT_ID('tempdb..#bill') IS NOT NULL
		DROP TABLE #bill
END






