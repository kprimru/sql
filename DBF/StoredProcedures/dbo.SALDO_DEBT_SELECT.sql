USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SALDO_DEBT_SELECT]
AS
BEGIN  
	SET NOCOUNT ON
	SELECT CL_ID, CL_PSEDO, DIS_ID, DIS_STR, SL_REST, SN_ID, SN_NAME
    FROM 
		dbo.SaldoLastView LEFT OUTER JOIN
        dbo.DistrFinancingTable ON DF_ID_DISTR = DIS_ID LEFT OUTER JOIN
        dbo.SystemNetTable ON SN_ID = DF_ID_NET
    WHERE SL_REST < 0
    ORDER BY CL_PSEDO, CL_ID, DIS_STR
END

