USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[MARKET_AREA_SELECT] 
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT MA_ID, MA_NAME, MA_SHORT_NAME 
	FROM dbo.MarketAreaTable 
	WHERE MA_ACTIVE = ISNULL(@active, MA_ACTIVE)
	ORDER BY MA_NAME

	SET NOCOUNT OFF
END




