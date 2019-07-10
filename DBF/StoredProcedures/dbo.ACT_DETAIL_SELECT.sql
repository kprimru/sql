USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:			������� �������/������ ��������
��������:		
*/

CREATE PROCEDURE [dbo].[ACT_DETAIL_SELECT]
	@actid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
			AD_ID, DIS_ID, DIS_STR, TX_ID, TX_NAME, TX_PERCENT,
			AD_PRICE, AD_TAX_PRICE, AD_TOTAL_PRICE, --AD_DATE
			PR_DATE
	FROM 
		dbo.ActDistrView 
	WHERE ACT_ID = @actid
	ORDER BY DIS_STR
END













