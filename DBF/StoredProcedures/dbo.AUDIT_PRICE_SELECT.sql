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

CREATE PROCEDURE [dbo].[AUDIT_PRICE_SELECT]	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ER_MSG 
	FROM dbo.AuditPriceView
	ORDER BY ER_MSG

END
