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

CREATE PROCEDURE [dbo].[BOOK_BUY_MASTER_PRINT]
	@orgid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		ORG_SHORT_NAME, ORG_INN, ORG_KPP, 
		(ORG_BUH_FAM + ' ' + LEFT(ORG_BUH_NAME, 1) + '.' + LEFT(ORG_BUH_OTCH, 1) + '.') AS ORG_BUH_SHORT
	FROM dbo.OrganizationTable
	WHERE ORG_ID = @orgid
END


