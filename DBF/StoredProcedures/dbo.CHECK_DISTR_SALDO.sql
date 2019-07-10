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
CREATE PROCEDURE [dbo].[CHECK_DISTR_SALDO]
	@cdid VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SL_REST
	FROM 
		dbo.SaldoLastView INNER JOIN
		dbo.ClientDistrTable ON CD_ID_CLIENT = CL_ID 
						AND CD_ID_DISTR = DIS_ID INNER JOIN
		dbo.GET_TABLE_FROM_LIST(@cdid, ',') ON Item = CD_ID	
	WHERE SL_REST <> 0
END